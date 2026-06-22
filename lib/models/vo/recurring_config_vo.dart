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

  /// 下次生成日期（基于开始日期+频率的简单计算）
  String? get nextGenerateDateDesc {
    if (!isActive || isExpired) return null;
    // 实际下次生成日期由Service计算，这里提供占位
    if (lastGeneratedAt != null) {
      // 根据上次生成日期和频率计算
      final lastDate = DateTime.tryParse(lastGeneratedAt!.substring(0, 10));
      if (lastDate != null) return _computeNextFrom(lastDate);
    }
    return startDate;
  }

  String _computeNextFrom(DateTime fromDate) {
    if (frequencyType == 'monthly') {
      final days = frequencyValue.split(',').map(int.parse).toList();
      // 计算下个月从fromDate开始的最近日期
      for (var m = 0; m < 2; m++) {
        final month = fromDate.month + m;
        final year = fromDate.year + (month > 12 ? 1 : 0);
        final actualMonth = month > 12 ? month - 12 : month;
        for (final day in days) {
          final maxDay = DateTime(year, actualMonth + 1, 0).day;
          final actualDay = day > maxDay ? maxDay : day;
          final candidate = DateTime(year, actualMonth, actualDay);
          if (candidate.isAfter(fromDate)) {
            return '${candidate.year}-${candidate.month.toString().padLeft(2, '0')}-${candidate.day.toString().padLeft(2, '0')}';
          }
        }
      }
    } else if (frequencyType == 'weekly') {
      final weekDays = frequencyValue.split(',').map(int.parse).toSet();
      for (var i = 1; i <= 7; i++) {
        final candidate = fromDate.add(Duration(days: i));
        if (weekDays.contains(candidate.weekday % 7)) {
          return '${candidate.year}-${candidate.month.toString().padLeft(2, '0')}-${candidate.day.toString().padLeft(2, '0')}';
        }
      }
    }
    return fromDate.toIso8601String().substring(0, 10);
  }

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
