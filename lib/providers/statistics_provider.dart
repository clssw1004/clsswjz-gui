import 'package:flutter/material.dart';

import '../enums/account_type.dart';
import '../models/vo/statistic_vo.dart';
import '../services/statistic_service.dart';

/// 统计数据提供者，用于管理统计页面数据
class StatisticsProvider extends ChangeNotifier {
  final StatisticService _statisticService = StatisticService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<CategoryStatisticGroupVO>? _categoryStatisticsList;
  List<CategoryStatisticGroupVO>? get categoryStatisticsList =>
      _categoryStatisticsList;

  String _selectedTab = AccountItemType.expense.code; // 默认显示支出分类
  String get selectedTab => _selectedTab;

  /// 切换显示收入或支出
  void switchTab(String tab) {
    if (_selectedTab != tab &&
        (tab == AccountItemType.income.code ||
            tab == AccountItemType.expense.code)) {
      _selectedTab = tab;
      notifyListeners();
    }
  }

  /// 加载分类统计数据
  Future<void> loadStatistics(String? bookId) async {
    if (bookId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _statisticService.statisticGroupByCategory(bookId);

      if (result.data != null) {
        _categoryStatisticsList = result.data;
      }
    } catch (e) {
      debugPrint('加载分类统计失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 获取当前选中的分类统计组
  CategoryStatisticGroupVO? get selectedGroup {
    if (_categoryStatisticsList == null || _categoryStatisticsList!.isEmpty) {
      return null;
    }

    final itemType = _selectedTab == AccountItemType.income.code
        ? AccountItemType.income
        : AccountItemType.expense;

    return _categoryStatisticsList!.firstWhere(
      (group) => group.itemType == itemType,
      orElse: () => CategoryStatisticGroupVO(
        itemType: itemType,
        categoryGroupList: [],
      ),
    );
  }

  /// 获取当前选中分类的总金额
  double get totalAmount {
    final group = selectedGroup;
    if (group == null || group.categoryGroupList.isEmpty) {
      return 0.0;
    }

    return group.categoryGroupList.fold<double>(
      0.0,
      (sum, item) => sum + item.amount.abs(),
    );
  }

  /// 获取按金额排序的分类列表
  List<CategoryStatisticVO> get sortedCategoryList {
    final group = selectedGroup;
    if (group == null || group.categoryGroupList.isEmpty) {
      return [];
    }

    final sortedList = List<CategoryStatisticVO>.from(group.categoryGroupList)
      ..sort((a, b) => b.amount.abs().compareTo(a.amount.abs()));

    return sortedList;
  }
}
