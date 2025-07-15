import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../manager/l10n_manager.dart';
import '../../providers/books_provider.dart';
import '../../providers/statistics_provider.dart';
import '../../widgets/book/book_statistic_card.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/common_empty_view.dart';
import '../../widgets/common/common_loading_view.dart';
import '../../widgets/statistics/category_list.dart';
import '../../widgets/statistics/category_pie_chart.dart';
import '../../widgets/statistics/category_tab_selector.dart';

/// 时间范围选择器组件
class TimeRangeSelector extends StatelessWidget {
  final String selectedRange;
  final DateTimeRange? customRange;
  final void Function(String, DateTimeRange?) onChanged;

  const TimeRangeSelector({
    super.key,
    required this.selectedRange,
    required this.customRange,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = L10nManager.l10n;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ranges = [
      'all',
      'year',
      'month',
      'week',
      'custom',
    ];
    final rangeLabels = {
      'all': l10n.timeRangeAll,
      'year': l10n.timeRangeYear,
      'month': l10n.timeRangeMonth,
      'week': l10n.timeRangeWeek,
      'custom': l10n.timeRangeCustom,
    };

    return Card(
      elevation: 0,
      color: colorScheme.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: [
            Icon(Icons.calendar_month_outlined, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              l10n.selectTimeRange,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 16),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedRange,
                borderRadius: BorderRadius.circular(12),
                style: theme.textTheme.bodyMedium,
                dropdownColor: colorScheme.surface,
                items: ranges
                    .map((r) => DropdownMenuItem(
                          value: r,
                          child: Text(rangeLabels[r] ?? r),
                        ))
                    .toList(),
                onChanged: (value) async {
                  if (value == null) return;
                  if (value == 'custom') {
                    final now = DateTime.now();
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(now.year - 10),
                      lastDate: DateTime(now.year + 1, 12, 31),
                      initialDateRange: customRange ?? DateTimeRange(start: now, end: now),
                      builder: (context, child) {
                        return Theme(
                          data: theme.copyWith(
                            colorScheme: colorScheme,
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      onChanged(value, picked);
                    }
                  } else {
                    onChanged(value, null);
                  }
                },
              ),
            ),
            if (selectedRange == 'custom' && customRange != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  '${customRange!.start.year}/${customRange!.start.month}/${customRange!.start.day} - '
                  '${customRange!.end.year}/${customRange!.end.month}/${customRange!.end.day}',
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 统计标签页
class StatisticsTab extends StatefulWidget {
  const StatisticsTab({super.key});

  @override
  State<StatisticsTab> createState() => _StatisticsTabState();
}

class _StatisticsTabState extends State<StatisticsTab> {
  static const _timeRanges = [
    'all',
    'year',
    'month',
    'week',
    'custom',
  ];

  String _selectedRange = 'all';
  DateTimeRange? _customRange;

  @override
  Widget build(BuildContext context) {
    final l10n = L10nManager.l10n;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(l10n.tabStatistics),
        showBackButton: false,
        centerTitle: false,
      ),
      body: Consumer2<BooksProvider, StatisticsProvider>(
        builder: (context, booksProvider, statisticsProvider, child) {
          // 初始化或依赖变化时加载数据
          _loadStatisticsIfNeeded(booksProvider, statisticsProvider);

          // 检查是否有选中的账本
          if (booksProvider.selectedBook == null) {
            return CommonEmptyView(message: l10n.noData);
          }

          // 加载中显示加载状态
          if (statisticsProvider.isLoading) {
            return const CommonLoadingView();
          }

          // 没有数据时显示空状态
          final categoryList = statisticsProvider.categoryStatisticsList;
          if (categoryList == null || categoryList.isEmpty) {
            return CommonEmptyView(message: l10n.noData);
          }

          // 构建统计视图
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: TimeRangeSelector(
                  selectedRange: _selectedRange,
                  customRange: _customRange,
                  onChanged: (range, custom) {
                    setState(() {
                      _selectedRange = range;
                      _customRange = custom;
                    });
                    _reloadStatistics(context);
                  },
                ),
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildStatisticsView(context)),
            ],
          );
        },
      ),
    );
  }

  /// 重新加载统计数据（根据时间范围）
  void _reloadStatistics(BuildContext context) {
    final booksProvider = Provider.of<BooksProvider>(context, listen: false);
    final statisticsProvider = Provider.of<StatisticsProvider>(context, listen: false);
    if (booksProvider.selectedBook == null) return;
    final bookId = booksProvider.selectedBook!.id;
    DateTime? start;
    DateTime? end;
    final now = DateTime.now();
    switch (_selectedRange) {
      case 'year':
        start = DateTime(now.year, 1, 1);
        end = DateTime(now.year, 12, 31, 23, 59, 59);
        break;
      case 'month':
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        break;
      case 'week':
        final weekday = now.weekday;
        start = now.subtract(Duration(days: weekday - 1));
        end = start.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        break;
      case 'custom':
        if (_customRange != null) {
          start = _customRange!.start;
          end = _customRange!.end;
        }
        break;
      case 'all':
      default:
        start = null;
        end = null;
    }
    statisticsProvider.loadStatistics(bookId, start: start, end: end);
    statisticsProvider.loadBookStatisticInfo(bookId, start: start, end: end);
  }

  /// 如果需要，加载统计数据
  void _loadStatisticsIfNeeded(
      BooksProvider booksProvider, StatisticsProvider statisticsProvider) {
    if (booksProvider.selectedBook == null) return;

    final bookId = booksProvider.selectedBook!.id;

    // 加载分类统计数据
    if (statisticsProvider.categoryStatisticsList == null &&
        !statisticsProvider.isLoading) {
      Future.microtask(() {
        statisticsProvider.loadStatistics(bookId);
      });
    }

    // 加载账本统计信息（全部时间范围）
    if (statisticsProvider.allTimeStatistic == null &&
        !statisticsProvider.loadingBookStatistic) {
      Future.microtask(() {
        statisticsProvider.loadBookStatisticInfo(bookId);
      });
    }
  }

  /// 构建统计视图
  Widget _buildStatisticsView(BuildContext context) {
    final statisticsProvider = Provider.of<StatisticsProvider>(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 账本统计卡片
        BookStatisticCard(
          statisticInfo: statisticsProvider.allTimeStatistic,
          margin: const EdgeInsets.only(bottom: 16),
          title: L10nManager.l10n.total,
        ),

        // 分类选择器（收入/支出）
        const CategoryTabSelector(),

        const SizedBox(height: 16),

        // 饼图展示
        const CategoryPieChart(),

        const SizedBox(height: 16),

        // 分类列表
        const CategoryList(),
      ],
    );
  }
}
