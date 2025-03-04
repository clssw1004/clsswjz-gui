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

/// 统计标签页
class StatisticsTab extends StatefulWidget {
  const StatisticsTab({super.key});

  @override
  State<StatisticsTab> createState() => _StatisticsTabState();
}

class _StatisticsTabState extends State<StatisticsTab> {
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
          return _buildStatisticsView(context);
        },
      ),
    );
  }

  /// 如果需要，加载统计数据
  void _loadStatisticsIfNeeded(
      BooksProvider booksProvider, StatisticsProvider statisticsProvider) {
    if (booksProvider.selectedBook == null) return;

    final bookId = booksProvider.selectedBook!.id;

    // 加载分类统计数据
    if (statisticsProvider.categoryStatisticsList == null &&
        !statisticsProvider.isLoading) {
      // 延迟加载，避免在build过程中触发状态更新
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
