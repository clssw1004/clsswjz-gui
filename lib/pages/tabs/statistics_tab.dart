import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../drivers/driver_factory.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../services/monthly_report_service.dart';
import '../../utils/toast_util.dart';
import '../../models/dto/ui_config_dto.dart';
import '../../models/vo/activity_statistic_vo.dart';
import '../../models/vo/activity_definition_vo.dart';
import '../../models/vo/activity_record_vo.dart';
import '../../models/common.dart';
import '../../providers/books_provider.dart';
import '../../providers/statistics_provider.dart';
import '../../theme/theme_spacing.dart';
import '../../widgets/activity/activity_statistic_card.dart';
import '../../widgets/book/book_statistic_card.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/common_empty_view.dart';
import '../../widgets/common/common_loading_view.dart';
import '../../widgets/item_widgets/project_monthly_statistic_chart.dart';
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
  late String _selectedRange;
  DateTimeRange? _customRange;
  List<ActivityStatisticVO> _activityStats = [];
  bool _activityStatsLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedRange = AppConfigManager.instance.uiConfig.statisticsSelectedRange;
    final customStart = AppConfigManager.instance.uiConfig.statisticsCustomRangeStart;
    final customEnd = AppConfigManager.instance.uiConfig.statisticsCustomRangeEnd;
    if (customStart != null && customEnd != null) {
      _customRange = DateTimeRange(
        start: DateTime.fromMillisecondsSinceEpoch(customStart),
        end: DateTime.fromMillisecondsSinceEpoch(customEnd),
      );
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reloadStatistics(context);
      _checkAutoGenerateReport();
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

          final spacing = Theme.of(context).spacing;

          // 构建主界面布局（时间范围选择器始终显示）
          return Column(
            children: [
              Padding(
                padding: spacing.formPadding.copyWith(bottom: 0),
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
              SizedBox(height: spacing.formItemSpacing),
              Expanded(
                child: _buildContentArea(context, statisticsProvider),
              ),
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
      case 'month':
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      case 'week':
        final weekday = now.weekday;
        // 获取本周一（00:00:00）
        final today = DateTime(now.year, now.month, now.day);
        start = today.subtract(Duration(days: weekday - 1));
        end = start.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
      case 'custom':
        if (_customRange != null) {
          start = _customRange!.start;
          end = _customRange!.end;
        }
      case 'all':
      default:
        start = null;
        end = null;
    }
    statisticsProvider.loadStatistics(bookId, start: start, end: end);
    statisticsProvider.loadBookStatisticInfo(bookId, start: start, end: end);
    statisticsProvider.loadProjectMonthlyStatistics(bookId, start: start, end: end);
    _loadActivityStatistics(start, end);
    _saveSelectedRange();
  }

  /// 加载活动统计数据
  Future<void> _loadActivityStatistics(DateTime? start, DateTime? end) async {
    setState(() => _activityStatsLoading = true);
    try {
      final userId = AppConfigManager.instance.userId;

      // 全时间范围时使用宽范围查询
      final s = start ?? DateTime(2000, 1, 1);
      final e = end ?? DateTime(2099, 12, 31);
      final startStr = '${s.year}-${s.month.toString().padLeft(2, '0')}-${s.day.toString().padLeft(2, '0')}';
      final endStr = '${e.year}-${e.month.toString().padLeft(2, '0')}-${e.day.toString().padLeft(2, '0')}';

      // 并行查询活动记录和活动定义
      final results = await Future.wait([
        DriverFactory.driver.listActivityRecords(
          userId,
          startDate: startStr,
          endDate: endStr,
        ),
        DriverFactory.driver.listActivityDefinitions(userId),
      ]);

      final records = results[0] as OperateResult<List<ActivityRecordVO>>;
      final defs = results[1] as OperateResult<List<ActivityDefinitionVO>>;

      // 构建 activityDefId -> 完整定义映射
      final defMap = <String, ActivityDefinitionVO>{};
      for (final d in defs.data ?? []) {
        defMap[d.id] = d;
      }

      if (mounted) {
        // 按 activityDefId 分组统计，无 defId 的 fallback 到 activityName
        final grouped = <String, _ActivityGroup>{};
        for (final r in records.data ?? []) {
          final key = r.activityDefId ?? r.activityName;
          final group = grouped.putIfAbsent(key, () => _ActivityGroup(
            name: r.activityName,
            emoji: r.activityDefId != null ? (defMap[r.activityDefId]?.emoji ?? '') : '',
            definition: r.activityDefId != null ? defMap[r.activityDefId] : null,
          ));
          group.count++;
        }
        final sorted = grouped.values.toList()
          ..sort((a, b) => b.count.compareTo(a.count));
        setState(() {
          _activityStats = sorted.map((g) => ActivityStatisticVO(
            activityName: g.name, count: g.count, emoji: g.emoji, definition: g.definition,
          )).toList();
          _activityStatsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _activityStatsLoading = false);
    }
  }

  /// 检查并自动生成上月报告（新月份首次打开时）
  Future<void> _checkAutoGenerateReport() async {
    final booksProvider = Provider.of<BooksProvider>(context, listen: false);
    final bookId = booksProvider.selectedBook?.id;
    if (bookId == null) return;

    // 只有当月度筛选时（月初首次打开）才自动检查
    // 当前日期 > 1号表示已进入新月份
    final now = DateTime.now();
    if (now.day <= 1) return;

    final lastMonth = now.month - 1;
    final year = lastMonth < 1 ? now.year - 1 : now.year;
    final month = lastMonth < 1 ? 12 : lastMonth;

    final service = MonthlyReportService();
    final noteId = await service.generateReport(bookId, year, month);
    if (noteId != null && mounted) {
      ToastUtil.showSuccess(L10nManager.l10n.reportRegenerated);
    }
  }

  /// 保存选择的时间范围
  Future<void> _saveSelectedRange() async {
    final config = AppConfigManager.instance.uiConfig;
    final newConfig = _createNewConfig(config);
    await AppConfigManager.instance.setUiConfig(newConfig);
  }

  /// 创建新的配置对象
  UiConfigDTO _createNewConfig(UiConfigDTO config) {
    return UiConfigDTO(
      itemTabShowDebt: config.itemTabShowDebt,
      itemTabShowDailyBar: config.itemTabShowDailyBar,
      itemTabShowDailyCalendar: config.itemTabShowDailyCalendar,
      calendarShowIncome: config.calendarShowIncome,
      calendarShowExpense: config.calendarShowExpense,
      itemTabShowUserMonthly: config.itemTabShowUserMonthly,
      itemTabShowProjectMonthly: config.itemTabShowProjectMonthly,
      statisticsShowBookStatistic: config.statisticsShowBookStatistic,
      statisticsShowProjectStatistic: config.statisticsShowProjectStatistic,
      statisticsShowCategoryStatistic: config.statisticsShowCategoryStatistic,
      statisticsShowActivityStatistic: config.statisticsShowActivityStatistic,
      statisticsSelectedRange: _selectedRange,
      statisticsCustomRangeStart: _customRange?.start.millisecondsSinceEpoch,
      statisticsCustomRangeEnd: _customRange?.end.millisecondsSinceEpoch,
      statisticsSelectedProjects: config.statisticsSelectedProjects,
    );
  }

  /// 构建内容区域
  Widget _buildContentArea(BuildContext context, StatisticsProvider statisticsProvider) {
    final l10n = L10nManager.l10n;

    // 加载中显示加载状态
    if (statisticsProvider.isLoading) {
      return const CommonLoadingView();
    }

    // 没有数据时显示空状态
    final categoryList = statisticsProvider.categoryStatisticsList;
    if (categoryList == null || categoryList.isEmpty) {
      return CommonEmptyView(message: l10n.noData);
    }

    // 有数据时显示统计视图
    return _buildStatisticsView(context);
  }

  /// 构建统计视图
  Widget _buildStatisticsView(BuildContext context) {
    final booksProvider = Provider.of<BooksProvider>(context, listen: false);
    final statisticsProvider = Provider.of<StatisticsProvider>(context);
    final config = AppConfigManager.instance.uiConfig;
    final spacing = Theme.of(context).spacing;

    return ListView(
      padding: spacing.contentPadding,
      children: [
        // 账本统计卡片 - 根据配置决定是否显示
        if (config.statisticsShowBookStatistic)
          BookStatisticCard(
            statisticInfo: _selectedRange == 'month'
                ? statisticsProvider.currentMonthStatistic
                : statisticsProvider.allTimeStatistic,
            margin: EdgeInsets.only(bottom: spacing.formGroupSpacing),
            title: _selectedRange == 'month'
                ? L10nManager.l10n.currentMonth
                : L10nManager.l10n.total,
          ),

        // 按项目统计卡片 - 根据配置决定是否显示
        if (config.statisticsShowProjectStatistic)
          Padding(
            padding: EdgeInsets.only(bottom: spacing.formGroupSpacing),
            child: ProjectMonthlyStatisticChart(
              data: statisticsProvider.filteredProjectStatistics,
              loading: statisticsProvider.loadingProjectMonthly,
              accountBook: booksProvider.selectedBook,
            ),
          ),

        // 分类统计卡片 - 根据配置决定是否显示
        if (config.statisticsShowCategoryStatistic) ...[
          const CategoryTabSelector(),
          SizedBox(height: spacing.formGroupSpacing),
          const CategoryStatisticCard(),
        ],

        // 活动统计卡片 - 根据配置决定是否显示
        if (config.statisticsShowActivityStatistic)
          ActivityStatisticCard(
            data: _activityStats,
            loading: _activityStatsLoading,
          ),
      ],
    );
  }
}

/// 活动分组统计辅助类
class _ActivityGroup {
  final String name;
  final String emoji;
  final ActivityDefinitionVO? definition;
  int count = 0;

  _ActivityGroup({required this.name, required this.emoji, this.definition});
}
