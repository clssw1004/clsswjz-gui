import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../manager/l10n_manager.dart';
import '../../providers/books_provider.dart';
import '../../providers/statistics_provider.dart';
import '../../widgets/book/book_statistic_card.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/common_empty_view.dart';
import '../../widgets/common/common_loading_view.dart';
import '../../widgets/statistics/category_tab_selector.dart';
import '../../widgets/statistics/category_statistic_card.dart';
import '../../widgets/statistics/time_range_selector.dart';

/// 统计标签页
class StatisticsTab extends StatefulWidget {
  const StatisticsTab({super.key});

  @override
  State<StatisticsTab> createState() => _StatisticsTabState();
}

class _StatisticsTabState extends State<StatisticsTab> {
  String _selectedRange = 'month';
  DateTimeRange? _customRange;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reloadStatistics(context);
    });
  }

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
    final statisticsProvider =
        Provider.of<StatisticsProvider>(context, listen: false);
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
        end = start
            .add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
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

  /// 构建统计视图
  Widget _buildStatisticsView(BuildContext context) {
    final statisticsProvider = Provider.of<StatisticsProvider>(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 账本统计卡片
        BookStatisticCard(
          statisticInfo: statisticsProvider.currentMonthStatistic,
          margin: const EdgeInsets.only(bottom: 16),
          title: L10nManager.l10n.currentMonth,
        ),

        // 分类统计卡片（可切换图表/列表）
        const CategoryTabSelector(),
        const SizedBox(height: 16),
        const CategoryStatisticCard(),
      ],
    );
  }
}
