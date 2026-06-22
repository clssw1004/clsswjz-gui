import '../database/database.dart';
import '../drivers/special/log/builder/book_item.builder.dart';
import '../drivers/special/log/builder/recurring_config.builder.dart';
import '../enums/account_type.dart';
import '../manager/app_config_manager.dart';
import '../manager/dao_manager.dart';

/// 固定收支配置服务
/// 核心业务逻辑：生成到期记录、跨账本复制、日期计算
class RecurringConfigService {
  /// 扫描所有到期配置并生成账目
  /// [bookId] 可选，指定账本；null则扫描所有账本
  static Future<GenerateResult> generateDueRecords({String? bookId}) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final configs = await DaoManager.recurringConfigDao.findActiveByNextDate(today);

    // 如果指定了账本，过滤
    final targetConfigs = bookId != null
        ? configs.where((c) => c.accountBookId == bookId).toList()
        : configs;

    final successIds = <String>[];
    final failIds = <String>[];
    final skipIds = <String>[];

    for (final config in targetConfigs) {
      final result = await generateForConfig(config, today);
      if (result == 'generated') {
        successIds.add(config.id);
      } else if (result == 'skip') {
        skipIds.add(config.id);
      } else {
        failIds.add(config.id);
      }
    }

    return GenerateResult(
      successCount: successIds.length,
      skipCount: skipIds.length,
      failCount: failIds.length,
    );
  }

  /// 生成单条配置的账目
  /// 返回 'generated' / 'skip' / 错误信息
  static Future<String> generateForConfig(RecurringConfig config, String today) async {
    try {
      // 1. 检查是否已过期
      if (!config.isActive) return 'skip';
      if (config.endType == 'date' && config.endDate != null && config.endDate!.compareTo(today) < 0) {
        return 'skip';
      }
      if (config.endType == 'count' && config.endCount != null && config.generatedCount >= config.endCount!) {
        return 'skip';
      }

      // 2. 计算目标日期
      String targetDate;
      if (config.lastGeneratedAt != null) {
        final lastDate = config.lastGeneratedAt!.substring(0, 10);
        final parsedLast = DateTime.tryParse(lastDate);
        if (parsedLast != null) {
          targetDate = computeNextDate(config, fromDate: parsedLast);
          if (targetDate.compareTo(today) > 0) return 'skip'; // 还没到时间
        } else {
          targetDate = today;
        }
      } else {
        // 首次生成：使用 startDate
        if (config.startDate.compareTo(today) > 0) return 'skip'; // 还没到开始日期
        targetDate = _getFirstTargetDate(config, today);
      }

      // 3. 防重复检查：查询该配置该日期是否已生成过
      final existingItems = await DaoManager.itemDao.findBySource(
        'recurring', [config.id]);
      final datePrefix = targetDate.substring(0, 10);
      final alreadyGenerated = existingItems.any((item) =>
          item.accountDate.startsWith(datePrefix));
      if (alreadyGenerated) return 'skip';

      // 4. 生成账目
      final userId = AppConfigManager.instance.userId;
      final amount = config.amount;
      final type = AccountItemType.fromCode(config.type) ?? AccountItemType.expense;

      await ItemCULog.create(
        userId,
        config.accountBookId,
        amount: amount,
        description: config.description,
        type: type,
        categoryCode: config.categoryCode,
        accountDate: '$targetDate 00:00:00',
        fundId: config.fundId,
        shopCode: config.shopCode,
        tagCode: config.tagCode,
        projectCode: config.projectCode,
        source: 'recurring',
        sourceId: config.id,
      ).execute();

      // 5. 更新配置状态
      final newCount = config.generatedCount + 1;
      bool stillActive = config.isActive;

      // 结束条件判定
      if (config.endType == 'count' && config.endCount != null && newCount >= config.endCount!) {
        stillActive = false;
      }
      if (config.endType == 'date' && config.endDate != null && config.endDate!.compareTo(targetDate) < 0) {
        stillActive = false;
      }

      await RecurringConfigCULog.update(
        who: userId,
        id: config.id,
        generatedCount: newCount,
        lastGeneratedAt: '$targetDate 00:00:00',
        isActive: stillActive,
      ).execute();

      return 'generated';
    } catch (e) {
      return 'error: $e';
    }
  }

  /// 计算首次生成的目标日期
  static String _getFirstTargetDate(RecurringConfig config, String today) {
    final parsedStart = DateTime.tryParse(config.startDate);
    if (parsedStart == null) return today;

    if (config.frequencyType == 'monthly') {
      final days = config.frequencyValue.split(',').map(int.parse).toList()..sort();
      // 从 startDate 所在月开始，找第一个 >= startDate 的日期
      return _findNextMonthlyDate(parsedStart, days, parsedStart);
    } else {
      // weekly: 从 startDate 开始找第一个匹配的星期
      final weekDays = config.frequencyValue.split(',').map(int.parse).toSet();
      var candidate = parsedStart;
      for (var i = 0; i < 7; i++) {
        if (weekDays.contains(candidate.weekday % 7)) {
          return _formatDate(candidate);
        }
        candidate = candidate.add(Duration(days: 1));
      }
      return _formatDate(parsedStart);
    }
  }

  /// 计算下次生成日期
  static String computeNextDate(RecurringConfig config, {DateTime? fromDate}) {
    final base = fromDate ?? DateTime.now();
    final today = DateTime.now();

    if (config.frequencyType == 'monthly') {
      final days = config.frequencyValue.split(',').map(int.parse).toList()..sort();
      return _findNextMonthlyDate(base, days, today);
    } else {
      // weekly
      final weekDays = config.frequencyValue.split(',').map(int.parse).toSet();
      for (var i = 1; i <= 7; i++) {
        final candidate = base.add(Duration(days: i));
        if (weekDays.contains(candidate.weekday % 7)) {
          // 如果找到的日期 >= today，直接返回
          if (candidate.compareDates(today) >= 0) {
            return _formatDate(candidate);
          }
        }
      }
      // fallback
      return _formatDate(base.add(const Duration(days: 7)));
    }
  }

  /// 找到从base日期起最近的下一个匹配的月日期
  static String _findNextMonthlyDate(DateTime base, List<int> days, DateTime minDate) {
    // 尝试当月及下个月
    for (var monthOffset = 0; monthOffset < 2; monthOffset++) {
      final month = base.month + monthOffset;
      final year = base.year + (month > 12 ? 1 : 0);
      final actualMonth = month > 12 ? month - 12 : month;
      final maxDay = DateTime(year, actualMonth + 1, 0).day;

      for (final day in days) {
        final actualDay = day > maxDay ? maxDay : day;
        final candidate = DateTime(year, actualMonth, actualDay);
        if (candidate.compareDates(minDate) >= 0) {
          return _formatDate(candidate);
        }
      }
    }
    return _formatDate(base.add(const Duration(days: 30)));
  }

  /// 防重复检查
  static Future<bool> checkDuplicates(RecurringConfig config, String targetDate) async {
    final existingItems = await DaoManager.itemDao.findBySource(
      'recurring', [config.id]);
    final datePrefix = targetDate.substring(0, 10);
    return existingItems.any((item) => item.accountDate.startsWith(datePrefix));
  }

  /// 跨账本复制配置
  static Future<ConfigCopyResult> copyConfigs(
    String sourceBookId,
    String targetBookId,
    List<String> configIds, {
    bool deactivateOrigin = false,
  }) async {
    final userId = AppConfigManager.instance.userId;
    final configs = await DaoManager.recurringConfigDao.findByIds(configIds);
    final mismatches = <ConfigCopyMismatch>[];
    int successCount = 0;
    int failCount = 0;

    for (final config in configs) {
      final result = await _copySingleConfig(userId, sourceBookId, targetBookId, config);
      if (result.success) {
        successCount++;
      } else {
        failCount++;
        mismatches.addAll(result.mismatches);
      }
    }

    // 停用源账本配置
    if (deactivateOrigin && successCount > 0) {
      for (final id in configIds) {
        await RecurringConfigCULog.update(
          who: userId,
          id: id,
          isActive: false,
        ).execute();
      }
    }

    return ConfigCopyResult(
      successCount: successCount,
      failCount: failCount,
      mismatches: mismatches,
    );
  }

  /// 复制单条配置
  static Future<_SingleCopyResult> _copySingleConfig(
    String userId, String sourceBookId, String targetBookId, RecurringConfig config,
  ) async {
    final mismatches = <ConfigCopyMismatch>[];

    // 映射分类
    String? newCategoryCode;
    final sourceCategory = await DaoManager.categoryDao.findByBookAndCode(
      sourceBookId, config.categoryCode);
    if (sourceCategory != null) {
      final targetCategory = await DaoManager.categoryDao.findByBookAndName(
        targetBookId, sourceCategory.name);
      if (targetCategory != null) {
        newCategoryCode = targetCategory.code;
      } else {
        mismatches.add(ConfigCopyMismatch(
          configId: config.id, field: 'category', sourceName: sourceCategory.name,
        ));
      }
    }

    // 映射账户
    String? newFundId;
    final sourceFund = await DaoManager.fundDao.findById(config.fundId);
    if (sourceFund != null) {
      final targetFunds = await DaoManager.fundDao.listByBook(targetBookId);
      final targetFund = targetFunds.cast<AccountFund?>().firstWhere(
        (f) => f?.name == sourceFund.name,
        orElse: () => null,
      );
      if (targetFund != null) {
        newFundId = targetFund.id;
      } else {
        mismatches.add(ConfigCopyMismatch(
          configId: config.id, field: 'fund', sourceName: sourceFund.name,
        ));
      }
    }

    // 映射商户
    String? newShopCode;
    if (config.shopCode != null) {
      final sourceShop = await DaoManager.shopDao.findByBookAndCode(
        sourceBookId, config.shopCode!);
      if (sourceShop != null) {
        final targetShop = await DaoManager.shopDao.findByBookAndName(
          targetBookId, sourceShop.name);
        if (targetShop != null) {
          newShopCode = targetShop.code;
        } else {
          mismatches.add(ConfigCopyMismatch(
            configId: config.id, field: 'shop', sourceName: sourceShop.name,
          ));
        }
      }
    }

    // 如果有必填字段未映射成功则跳过
    if (newCategoryCode == null || newFundId == null) {
      return _SingleCopyResult(success: false, mismatches: mismatches);
    }

    // 创建新配置
    try {
      await RecurringConfigCULog.create(
        who: userId,
        bookId: targetBookId,
        type: config.type,
        amount: config.amount,
        description: config.description,
        categoryCode: newCategoryCode,
        fundId: newFundId,
        shopCode: newShopCode,
        tagCode: config.tagCode,
        projectCode: config.projectCode,
        frequencyType: config.frequencyType,
        frequencyValue: config.frequencyValue,
        startDate: config.startDate,
        endType: config.endType,
        endDate: config.endDate,
        endCount: config.endCount,
      ).execute();
      return _SingleCopyResult(success: true, mismatches: mismatches);
    } catch (e) {
      return _SingleCopyResult(success: false, mismatches: mismatches);
    }
  }

  /// 获取配置生成的账目
  static Future<List<AccountItem>> getGeneratedItems(String configId) async {
    return DaoManager.itemDao.findBySource(
      'recurring', [configId]);
  }
}

/// 生成结果
class GenerateResult {
  final int successCount;
  final int skipCount;
  final int failCount;

  const GenerateResult({
    required this.successCount,
    required this.skipCount,
    required this.failCount,
  });
}

/// 复制结果
class ConfigCopyResult {
  final int successCount;
  final int failCount;
  final List<ConfigCopyMismatch> mismatches;

  const ConfigCopyResult({
    required this.successCount,
    required this.failCount,
    required this.mismatches,
  });
}

/// 映射失败详情
class ConfigCopyMismatch {
  final String configId;
  final String field;
  final String sourceName;

  const ConfigCopyMismatch({
    required this.configId,
    required this.field,
    required this.sourceName,
  });
}

class _SingleCopyResult {
  final bool success;
  final List<ConfigCopyMismatch> mismatches;
  const _SingleCopyResult({required this.success, this.mismatches = const []});
}

/// DateTime 比较扩展
extension _DateTimeCompare on DateTime {
  int compareDates(DateTime other) {
    final d1 = DateTime(year, month, day);
    final d2 = DateTime(other.year, other.month, other.day);
    return d1.compareTo(d2);
  }
}

/// 格式化日期
String _formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
