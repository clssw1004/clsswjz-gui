import '../../database/database.dart';
import '../../enums/account_type.dart';

/// 固定收支配置展示对象
class RecurringConfigVO {
  final String id;
  final String accountBookId;
  final String type; // INCOME / EXPENSE
  final double amount;
  final String? description;
  final String categoryCode;
  final String? categoryName;
  final String fundId;
  final String? fundName;
  final String? shopCode;
  final String? shopName;
  final String? tagCode;
  final String? projectCode;
  final String frequencyType; // weekly / monthly
  final String frequencyValue;
  final String startDate;
  final String endType; // infinite / date / count
  final String? endDate;
  final int? endCount;
  final int generatedCount;
  final String? lastGeneratedAt;
  final bool isActive;
  final String createdBy;
  final String updatedBy;
  final int createdAt;
  final int updatedAt;

  RecurringConfigVO({
    required this.id,
    required this.accountBookId,
    required this.type,
    required this.amount,
    this.description,
    required this.categoryCode,
    this.categoryName,
    required this.fundId,
    this.fundName,
    this.shopCode,
    this.shopName,
    this.tagCode,
    this.projectCode,
    required this.frequencyType,
    required this.frequencyValue,
    required this.startDate,
    required this.endType,
    this.endDate,
    this.endCount,
    required this.generatedCount,
    this.lastGeneratedAt,
    required this.isActive,
    required this.createdBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从数据库实体构建
  factory RecurringConfigVO.fromConfig(RecurringConfig config) {
    return RecurringConfigVO(
      id: config.id,
      accountBookId: config.accountBookId,
      type: config.type,
      amount: config.amount,
      description: config.description,
      categoryCode: config.categoryCode,
      fundId: config.fundId,
      shopCode: config.shopCode,
      tagCode: config.tagCode,
      projectCode: config.projectCode,
      frequencyType: config.frequencyType,
      frequencyValue: config.frequencyValue,
      startDate: config.startDate,
      endType: config.endType,
      endDate: config.endDate,
      endCount: config.endCount,
      generatedCount: config.generatedCount,
      lastGeneratedAt: config.lastGeneratedAt,
      isActive: config.isActive,
      createdBy: config.createdBy,
      updatedBy: config.updatedBy,
      createdAt: config.createdAt,
      updatedAt: config.updatedAt,
    );
  }

  /// 带名称的完整构建
  factory RecurringConfigVO.fromConfigWithNames(
    RecurringConfig config, {
    String? categoryName,
    String? fundName,
    String? shopName,
  }) {
    return RecurringConfigVO(
      id: config.id,
      accountBookId: config.accountBookId,
      type: config.type,
      amount: config.amount,
      description: config.description,
      categoryCode: config.categoryCode,
      categoryName: categoryName,
      fundId: config.fundId,
      fundName: fundName,
      shopCode: config.shopCode,
      shopName: shopName,
      tagCode: config.tagCode,
      projectCode: config.projectCode,
      frequencyType: config.frequencyType,
      frequencyValue: config.frequencyValue,
      startDate: config.startDate,
      endType: config.endType,
      endDate: config.endDate,
      endCount: config.endCount,
      generatedCount: config.generatedCount,
      lastGeneratedAt: config.lastGeneratedAt,
      isActive: config.isActive,
      createdBy: config.createdBy,
      updatedBy: config.updatedBy,
      createdAt: config.createdAt,
      updatedAt: config.updatedAt,
    );
  }

  /// 类型枚举
  AccountItemType get accountItemType => AccountItemType.fromCode(type) ?? AccountItemType.expense;

  /// 是否为收入
  bool get isIncome => type == AccountItemType.income.code;

  /// 是否为支出
  bool get isExpense => type == AccountItemType.expense.code;

  /// 频率文字描述
  String get frequencyDesc {
    final days = frequencyValue.split(',');
    if (frequencyType == 'weekly') {
      final weekDays = days.map((d) {
        return switch (d) {
          '0' => '周日',
          '1' => '周一',
          '2' => '周二',
          '3' => '周三',
          '4' => '周四',
          '5' => '周五',
          '6' => '周六',
          _ => d,
        };
      }).join('、');
      return '每周$weekDays';
    } else {
      return '每月${days.join("、")}号';
    }
  }

  /// 结束条件描述
  String get endConditionDesc {
    return switch (endType) {
      'infinite' => '无限持续',
      'date' => '至$endDate',
      'count' => '共${endCount ?? 0}次',
      _ => endType,
    };
  }

  /// 是否已过期（count类型达到上限）
  bool get isExpired {
    if (endType == 'date' && endDate != null) {
      return endDate!.compareTo(DateTime.now().toIso8601String().substring(0, 10)) < 0;
    }
    if (endType == 'count' && endCount != null) {
      return generatedCount >= endCount!;
    }
    return false;
  }

  /// 下次生成日期
  /// 规则：
  ///   1. 最后生成日之后的下一个频率日期
  /// 	 2. 从未来生成日期的起始日到今天之间的最后一次频率日期
  ///   3. 上面两种情况取最近一个 >= 今天的日期
  String? get nextGenerateDateDesc {
    if (!isActive || isExpired) return null;

    // 从哪个日期开始计算下次生成
    final DateTime baseDate;
    if (lastGeneratedAt != null) {
      final d = DateTime.tryParse(lastGeneratedAt!.substring(0, 10));
      baseDate = d ?? DateTime.now();
    } else {
      // 从未生成：从 startDate 或今天，取较晚者
      final sd = DateTime.tryParse(startDate);
      baseDate = (sd != null && sd.isAfter(DateTime.now())) ? sd : DateTime.now();
    }

    final today = DateTime.now();
    final next = _nextOccurrence(baseDate);

    // 如果算出来的日期 >= 今天，直接返回；否则从今天开始重新找
    if (next != null && (next.isAfter(today) || _isSameDay(next, today))) {
      return _fmt(next);
    }
    final fromToday = _nextOccurrence(today);
    return fromToday != null ? _fmt(fromToday) : null;
  }

  /// 计算 [from] 之后第一个匹配的频率日期（不含 from 当天）
  DateTime? _nextOccurrence(DateTime from) {
    if (frequencyType == 'monthly') {
      final days = frequencyValue.split(',').map(int.parse).toList()..sort();
      for (var m = 0; m < 3; m++) {
        final month = from.month + m;
        final year = from.year + ((month - 1) ~/ 12);
        final actualMonth = ((month - 1) % 12) + 1;
        final maxDay = DateTime(year, actualMonth + 1, 0).day;
        for (final day in days) {
          final actualDay = day > maxDay ? maxDay : day;
          final candidate = DateTime(year, actualMonth, actualDay);
          if (candidate.isAfter(from)) return candidate;
        }
      }
    } else if (frequencyType == 'weekly') {
      final weekDays = frequencyValue.split(',').map(int.parse).toSet();
      for (var i = 1; i <= 7; i++) {
        final candidate = from.add(Duration(days: i));
        if (weekDays.contains(candidate.weekday % 7)) return candidate;
      }
    }
    return null;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  RecurringConfigVO copyWith({
    String? id,
    String? accountBookId,
    String? type,
    double? amount,
    String? description,
    String? categoryCode,
    String? categoryName,
    String? fundId,
    String? fundName,
    String? shopCode,
    String? shopName,
    String? tagCode,
    String? projectCode,
    String? frequencyType,
    String? frequencyValue,
    String? startDate,
    String? endType,
    String? endDate,
    int? endCount,
    int? generatedCount,
    String? lastGeneratedAt,
    bool? isActive,
    String? createdBy,
    String? updatedBy,
    int? createdAt,
    int? updatedAt,
  }) {
    return RecurringConfigVO(
      id: id ?? this.id,
      accountBookId: accountBookId ?? this.accountBookId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      categoryCode: categoryCode ?? this.categoryCode,
      categoryName: categoryName ?? this.categoryName,
      fundId: fundId ?? this.fundId,
      fundName: fundName ?? this.fundName,
      shopCode: shopCode ?? this.shopCode,
      shopName: shopName ?? this.shopName,
      tagCode: tagCode ?? this.tagCode,
      projectCode: projectCode ?? this.projectCode,
      frequencyType: frequencyType ?? this.frequencyType,
      frequencyValue: frequencyValue ?? this.frequencyValue,
      startDate: startDate ?? this.startDate,
      endType: endType ?? this.endType,
      endDate: endDate ?? this.endDate,
      endCount: endCount ?? this.endCount,
      generatedCount: generatedCount ?? this.generatedCount,
      lastGeneratedAt: lastGeneratedAt ?? this.lastGeneratedAt,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
