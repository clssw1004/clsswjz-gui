import 'package:flutter/material.dart';
import '../manager/dao_manager.dart';
import '../drivers/driver_factory.dart';
import '../enums/operate_type.dart';
import '../events/event_bus.dart';
import '../events/special/event_recurring_config.dart';
import '../manager/app_config_manager.dart';
import '../models/common.dart';
import '../models/dto/recurring_config_filter_dto.dart';
import '../models/vo/recurring_config_vo.dart';
import '../services/recurring_config_service.dart';

/// 固定收支配置状态管理
class RecurringConfigProvider extends ChangeNotifier {
  final List<RecurringConfigVO> _configs = [];
  bool _loading = false;
  String? _error;

  List<RecurringConfigVO> get configs => _configs;
  bool get loading => _loading;
  String? get error => _error;

  /// 加载当前账本的配置列表
  Future<void> loadConfigs(String bookId, {RecurringConfigFilterDTO? filter}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await DriverFactory.driver.listRecurringConfigsWithNames(
        AppConfigManager.instance.userId,
        bookId,
        filter: filter,
      );
      if (result.ok) {
        _configs.clear();
        _configs.addAll(result.data ?? []);
      } else {
        _error = result.message;
      }
    } catch (e) {
      _error = '加载失败：$e';
    }

    _loading = false;
    notifyListeners();
  }

  /// 创建配置
  Future<OperateResult<String>> createConfig(
    String bookId, {
    required String type,
    required double amount,
    String? description,
    required String categoryCode,
    required String fundId,
    String? shopCode,
    String? tagCode,
    String? projectCode,
    required String frequencyType,
    required String frequencyValue,
    required String startDate,
    required String endType,
    String? endDate,
    int? endCount,
  }) async {
    final userId = AppConfigManager.instance.userId;
    final result = await DriverFactory.driver.createRecurringConfig(
      userId, bookId,
      type: type,
      amount: amount,
      description: description,
      categoryCode: categoryCode,
      fundId: fundId,
      shopCode: shopCode,
      tagCode: tagCode,
      projectCode: projectCode,
      frequencyType: frequencyType,
      frequencyValue: frequencyValue,
      startDate: startDate,
      endType: endType,
      endDate: endDate,
      endCount: endCount,
    );
    if (result.ok) {
      await loadConfigs(bookId);
      final config = getConfigById(result.data!);
      if (config != null) {
        EventBus.instance.emit(RecurringConfigChangedEvent(OperateType.create, config));
      }
    }
    return result;
  }

  /// 更新配置
  Future<OperateResult<void>> updateConfig(
    String configId, {
    String? type,
    double? amount,
    String? description,
    String? categoryCode,
    String? fundId,
    String? shopCode,
    String? tagCode,
    String? projectCode,
    String? frequencyType,
    String? frequencyValue,
    String? startDate,
    String? endType,
    String? endDate,
    int? endCount,
    bool? isActive,
    int? generatedCount,
    String? lastGeneratedAt,
    String? bookId,
  }) async {
    final userId = AppConfigManager.instance.userId;
    final result = await DriverFactory.driver.updateRecurringConfig(
      userId, configId,
      type: type,
      amount: amount,
      description: description,
      categoryCode: categoryCode,
      fundId: fundId,
      shopCode: shopCode,
      tagCode: tagCode,
      projectCode: projectCode,
      frequencyType: frequencyType,
      frequencyValue: frequencyValue,
      startDate: startDate,
      endType: endType,
      endDate: endDate,
      endCount: endCount,
      isActive: isActive,
      generatedCount: generatedCount,
      lastGeneratedAt: lastGeneratedAt,
    );
    if (result.ok) {
      if (bookId != null) await loadConfigs(bookId);
      final config = getConfigById(configId);
      if (config != null) {
        EventBus.instance.emit(RecurringConfigChangedEvent(OperateType.update, config));
      }
    }
    return result;
  }

  /// 删除配置
  Future<OperateResult<void>> deleteConfig(String configId, {String? bookId}) async {
    final userId = AppConfigManager.instance.userId;
    final config = getConfigById(configId);

    final result = await DriverFactory.driver.deleteRecurringConfig(userId, configId);
    if (result.ok) {
      if (bookId != null) await loadConfigs(bookId);
      if (config != null) {
        EventBus.instance.emit(RecurringConfigChangedEvent(OperateType.delete, config));
      }
    }
    return result;
  }

  /// 启用/停用
  Future<OperateResult<void>> toggleActive(String configId, bool isActive, {String? bookId}) async {
    final userId = AppConfigManager.instance.userId;
    final result = await DriverFactory.driver.updateRecurringConfig(
      userId, configId,
      isActive: isActive,
    );
    if (result.ok) {
      if (bookId != null) await loadConfigs(bookId);
      final config = getConfigById(configId);
      if (config != null) {
        EventBus.instance.emit(RecurringConfigChangedEvent(OperateType.update, config));
      }
    }
    return result;
  }

  /// 立即生成
  Future<String> generateNow(String configId) async {
    try {
      final configs = await DaoManager.recurringConfigDao.findByIds([configId]);
      if (configs.isEmpty) return '配置不存在';
      final config = configs.first;
      final today = DateTime.now().toIso8601String().substring(0, 10);
      return await RecurringConfigService.generateForConfig(config, today);
    } catch (e) {
      return '生成失败：$e';
    }
  }

  /// 检查并生成所有到期记录
  Future<GenerateResult> checkDueGenerations({String? bookId}) async {
    return RecurringConfigService.generateDueRecords(bookId: bookId);
  }

  /// 跨账本复制
  Future<ConfigCopyResult> copyFromBook(
    String sourceBookId,
    String targetBookId,
    List<String> configIds, {
    bool deactivateOrigin = false,
  }) async {
    return RecurringConfigService.copyConfigs(
      sourceBookId, targetBookId, configIds,
      deactivateOrigin: deactivateOrigin,
    );
  }

  /// 根据ID获取配置
  RecurringConfigVO? getConfigById(String id) {
    try {
      return _configs.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
