import 'dart:async';

import 'package:flutter/material.dart';

import '../enums/account_type.dart';
import '../events/event_bus.dart';
import '../events/special/event_book.dart';
import '../models/vo/statistic_vo.dart';
import '../services/statistic_service.dart';

/// 统计数据提供者，用于管理统计页面数据
class StatisticsProvider extends ChangeNotifier {
  final StatisticService _statisticService = StatisticService();
  late final StreamSubscription _bookChangedSubscription;
  late final StreamSubscription _itemChangedSubscription;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<CategoryStatisticGroupVO>? _categoryStatisticsList;
  List<CategoryStatisticGroupVO>? get categoryStatisticsList =>
      _categoryStatisticsList;

  /// 当前统计使用的时间范围
  DateTime? _currentStart;
  DateTime? _currentEnd;
  DateTime? get currentStart => _currentStart;
  DateTime? get currentEnd => _currentEnd;

  String _selectedTab = AccountItemType.expense.code; // 默认显示支出分类
  String get selectedTab => _selectedTab;

  /// 账本统计信息 - 全部时间
  BookStatisticVO? _allTimeStatistic;
  BookStatisticVO? get allTimeStatistic => _allTimeStatistic;

  /// 账本统计信息 - 本月
  BookStatisticVO? _currentMonthStatistic;
  BookStatisticVO? get currentMonthStatistic => _currentMonthStatistic;

  /// 账本统计信息 - 最近一天
  BookStatisticVO? _lastDayStatistic;
  BookStatisticVO? get lastDayStatistic => _lastDayStatistic;

  /// 每日收支统计数据
  List<DailyStatisticVO>? _dailyStatistics;
  List<DailyStatisticVO>? get dailyStatistics => _dailyStatistics;

  /// 是否正在加载每日统计数据
  bool _loadingDailyStatistics = false;
  bool get loadingDailyStatistics => _loadingDailyStatistics;

  /// 当前选中的统计类型（day, month, all）
  String _selectedStatisticType = 'all'; // 默认显示全部时间
  String get selectedStatisticType => _selectedStatisticType;

  /// 是否正在加载账本统计信息
  bool _loadingBookStatistic = false;
  bool get loadingBookStatistic => _loadingBookStatistic;

  StatisticsProvider() {
    // 默认时间范围与页面初始一致：本月
    final now = DateTime.now();
    _currentStart = DateTime(now.year, now.month, 1);
    _currentEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    _bookChangedSubscription = EventBus.instance.on<BookChangedEvent>((event) {
      loadBookStatisticInfo(event.book.id, start: _currentStart, end: _currentEnd);
      loadStatistics(event.book.id, start: _currentStart, end: _currentEnd);
      loadDailyStatistics(event.book.id);
    });

    _itemChangedSubscription = EventBus.instance.on<ItemChangedEvent>((event) {
      loadStatistics(event.item.accountBookId, start: _currentStart, end: _currentEnd);
      loadBookStatisticInfo(event.item.accountBookId, start: _currentStart, end: _currentEnd);
      loadDailyStatistics(event.item.accountBookId);
    });
  }

  @override
  void dispose() {
    _bookChangedSubscription.cancel();
    _itemChangedSubscription.cancel();
    super.dispose();
  }

  /// 切换显示收入或支出
  void switchTab(String tab) {
    if (_selectedTab != tab &&
        (tab == AccountItemType.income.code ||
            tab == AccountItemType.expense.code)) {
      _selectedTab = tab;
      notifyListeners();
    }
  }

  /// 切换统计类型（日、月、全部）
  void switchStatisticType(String type) {
    if (_selectedStatisticType != type &&
        (type == 'day' || type == 'month' || type == 'all')) {
      _selectedStatisticType = type;
      notifyListeners();
    }
  }

  /// 加载分类统计数据
  Future<void> loadStatistics(String? bookId, {DateTime? start, DateTime? end}) async {
    if (bookId == null) return;

    _isLoading = true;
    _currentStart = start;
    _currentEnd = end;
    notifyListeners();

    try {
      final result = await _statisticService.statisticGroupByCategory(bookId, start: start, end: end);

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

  /// 创建默认的统计数据
  BookStatisticVO _createDefaultStatistic(String type) {
    return BookStatisticVO();
  }

  /// 通用方法：加载指定时间范围的账本统计信息
  Future<BookStatisticVO> _loadStatisticData(
    String? bookId,
    String type,
    Future<dynamic> Function(String) apiCall,
  ) async {
    if (bookId == null) return _createDefaultStatistic(type);

    try {
      final result = await apiCall(bookId);

      // 如果请求成功且有数据则使用返回的数据，否则使用默认数据
      return result.ok && result.data != null
          ? result.data
          : _createDefaultStatistic(type);
    } catch (e) {
      // 发生异常时使用默认数据
      return _createDefaultStatistic(type);
    }
  }

  /// 加载所有时间范围的账本统计信息
  Future<void> loadBookStatisticInfo(String? bookId, {DateTime? start, DateTime? end}) async {
    if (bookId == null) return;

    _loadingBookStatistic = true;
    notifyListeners();

    try {
      // 并行加载所有统计数据
      final results = await Future.wait([
        _loadStatisticData(
            bookId, 'all', (id) => _statisticService.getAllTimeStatistic(id, start: start, end: end)),
        _loadStatisticData(
            bookId, 'month', (id) => _statisticService.getCurrentMonthStatistic(id, start: start, end: end)),
        _loadStatisticData(
            bookId, 'day', (id) => _statisticService.getLastDayStatistic(id, start: start, end: end)),
      ]);

      // 直接赋值结果
      _allTimeStatistic = results[0];
      _currentMonthStatistic = results[1];
      _lastDayStatistic = results[2];
    } finally {
      _loadingBookStatistic = false;
      notifyListeners();
    }
  }

  /// 加载当月每日收支统计数据
  Future<void> loadDailyStatistics(String? bookId) async {
    if (bookId == null) return;

    _loadingDailyStatistics = true;
    notifyListeners();

    try {
      final result = await _statisticService.getCurrentMonthDailyStatistic(bookId);
      if (result.ok && result.data != null) {
        _dailyStatistics = result.data;
      } else {
        _dailyStatistics = [];
      }
    } catch (e) {
      debugPrint('加载每日统计数据失败: $e');
      _dailyStatistics = [];
    } finally {
      _loadingDailyStatistics = false;
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
