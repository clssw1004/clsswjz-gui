import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../manager/l10n_manager.dart';
import '../../providers/books_provider.dart';
import '../../providers/statistics_provider.dart';
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
    final theme = Theme.of(context);
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
    BooksProvider booksProvider, 
    StatisticsProvider statisticsProvider
  ) {
    if (booksProvider.selectedBook == null) return;
    
    if (statisticsProvider.categoryStatisticsList == null && !statisticsProvider.isLoading) {
      // 延迟加载，避免在build过程中触发状态更新
      Future.microtask(() {
        statisticsProvider.loadStatistics(booksProvider.selectedBook!.id);
      });
    }
  }
  
  /// 构建统计视图
  Widget _buildStatisticsView(BuildContext context) {
    final theme = Theme.of(context);
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        // 分类选择器（收入/支出）
        CategoryTabSelector(),
        
        SizedBox(height: 16),
        
        // 饼图展示
        CategoryPieChart(),
        
        SizedBox(height: 16),
        
        // 分类列表
        CategoryList(),
      ],
    );
  }
} 