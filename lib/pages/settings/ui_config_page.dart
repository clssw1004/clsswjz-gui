import 'package:flutter/material.dart';
import 'package:clsswjz_gui/database/database.dart';
import 'package:clsswjz_gui/drivers/driver_factory.dart';
import 'package:clsswjz_gui/enums/symbol_type.dart';
import 'package:clsswjz_gui/manager/app_config_manager.dart';
import 'package:clsswjz_gui/manager/l10n_manager.dart';
import 'package:clsswjz_gui/models/dto/ui_config_dto.dart';
import 'package:clsswjz_gui/theme/theme_spacing.dart';
import 'package:clsswjz_gui/widgets/common/common_app_bar.dart';
import 'package:clsswjz_gui/widgets/common/common_card_container.dart';

/// UI布局配置页面
class UiConfigPage extends StatefulWidget {
  const UiConfigPage({super.key});

  @override
  State<UiConfigPage> createState() => _UiConfigPageState();
}

class _UiConfigPageState extends State<UiConfigPage> {
  late bool _showDebt;
  late bool _showDailyStats;
  late bool _showDailyCalendar;
  late bool _showUserMonthly;
  late bool _showProjectMonthly;
  late bool _showStatisticsBookStatistic;
  late bool _showStatisticsProjectStatistic;
  late bool _showStatisticsCategoryStatistic;
  late bool _showStatisticsActivityStatistic;
  late bool _showActivityCheckin;
  late String _statisticsSelectedRange;
  DateTimeRange? _customRange;
  List<String> _selectedProjects = [];
  List<AccountSymbol> _availableProjects = [];
  bool _loadingProjects = true;

  @override
  void initState() {
    super.initState();
    _showDebt = AppConfigManager.instance.uiConfig.itemTabShowDebt;
    _showDailyStats = AppConfigManager.instance.uiConfig.itemTabShowDailyBar;
    _showDailyCalendar =
        AppConfigManager.instance.uiConfig.itemTabShowDailyCalendar;
    _showUserMonthly =
        AppConfigManager.instance.uiConfig.itemTabShowUserMonthly;
    _showProjectMonthly =
        AppConfigManager.instance.uiConfig.itemTabShowProjectMonthly;
    _showStatisticsBookStatistic =
        AppConfigManager.instance.uiConfig.statisticsShowBookStatistic;
    _showStatisticsProjectStatistic =
        AppConfigManager.instance.uiConfig.statisticsShowProjectStatistic;
    _showStatisticsCategoryStatistic =
        AppConfigManager.instance.uiConfig.statisticsShowCategoryStatistic;
    _showStatisticsActivityStatistic =
        AppConfigManager.instance.uiConfig.statisticsShowActivityStatistic;
    _showActivityCheckin =
        AppConfigManager.instance.uiConfig.mineTabShowActivityCheckin;
    _statisticsSelectedRange =
        AppConfigManager.instance.uiConfig.statisticsSelectedRange;
    _selectedProjects =
        List.from(AppConfigManager.instance.uiConfig.statisticsSelectedProjects);
    final customStart =
        AppConfigManager.instance.uiConfig.statisticsCustomRangeStart;
    final customEnd =
        AppConfigManager.instance.uiConfig.statisticsCustomRangeEnd;
    if (customStart != null && customEnd != null) {
      _customRange = DateTimeRange(
        start: DateTime.fromMillisecondsSinceEpoch(customStart),
        end: DateTime.fromMillisecondsSinceEpoch(customEnd),
      );
    }
    _loadProjects();
  }

  /// 加载项目列表
  Future<void> _loadProjects() async {
    final userId = AppConfigManager.instance.userId;
    final bookId = AppConfigManager.instance.defaultBookId;
    if (bookId == null) {
      setState(() => _loadingProjects = false);
      return;
    }
    try {
      final result = await DriverFactory.driver.listSymbolsByBook(
        userId,
        bookId,
        symbolType: SymbolType.project,
      );
      if (mounted) {
        setState(() {
          _availableProjects = result.data ?? [];
          _loadingProjects = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingProjects = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.spacing;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(L10nManager.l10n.uiLayoutSettings),
      ),
      body: SingleChildScrollView(
        padding: spacing.formPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 记账页设置
            CommonCardContainer(
              padding: spacing.listItemPadding,
              margin: EdgeInsets.only(bottom: spacing.formGroupSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  Row(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        L10nManager.l10n.accountingPage,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 债务展示开关
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              L10nManager.l10n.showDebt,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              L10nManager.l10n.showDebtDescription,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _showDebt,
                        onChanged: (value) {
                          setState(() {
                            _showDebt = value;
                          });
                          _updateUiConfig();
                        },
                        activeThumbColor: colorScheme.primary,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  // 每日收支统计展示开关
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              L10nManager.l10n.showDailyStats,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              L10nManager.l10n.showDailyStatsDescription,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _showDailyStats,
                        onChanged: (value) {
                          setState(() {
                            _showDailyStats = value;
                          });
                          _updateUiConfig();
                        },
                        activeThumbColor: colorScheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 每日收支统计（日历）展示开关
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              L10nManager.l10n.showDailyCalendar,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              L10nManager.l10n.showDailyCalendarDescription,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _showDailyCalendar,
                        onChanged: (value) {
                          setState(() {
                            _showDailyCalendar = value;
                          });
                          _updateUiConfig();
                        },
                        activeThumbColor: colorScheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 按用户当月统计展示开关
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '按用户当月统计',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '显示当月各用户的收入/支出柱状图',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _showUserMonthly,
                        onChanged: (value) {
                          setState(() {
                            _showUserMonthly = value;
                          });
                          _updateUiConfig();
                        },
                        activeThumbColor: colorScheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 按项目当月统计展示开关
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '按项目当月统计',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '显示当月各项目的收入/支出柱状图',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _showProjectMonthly,
                        onChanged: (value) {
                          setState(() {
                            _showProjectMonthly = value;
                          });
                          _updateUiConfig();
                        },
                        activeThumbColor: colorScheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 新版账目表单展示开关
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '新版账目表单',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '使用全新设计的账目新增/编辑页面',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: AppConfigManager.instance.uiConfig.useNewItemForm,
                        onChanged: (value) {
                          final newConfig = UiConfigDTO(
                            itemTabShowDebt: AppConfigManager.instance.uiConfig.itemTabShowDebt,
                            itemTabShowDailyBar: AppConfigManager.instance.uiConfig.itemTabShowDailyBar,
                            itemTabShowDailyCalendar: AppConfigManager.instance.uiConfig.itemTabShowDailyCalendar,
                            calendarShowIncome: AppConfigManager.instance.uiConfig.calendarShowIncome,
                            calendarShowExpense: AppConfigManager.instance.uiConfig.calendarShowExpense,
                            itemTabShowUserMonthly: AppConfigManager.instance.uiConfig.itemTabShowUserMonthly,
                            itemTabShowProjectMonthly: AppConfigManager.instance.uiConfig.itemTabShowProjectMonthly,
                            statisticsShowBookStatistic: AppConfigManager.instance.uiConfig.statisticsShowBookStatistic,
                            statisticsShowProjectStatistic: AppConfigManager.instance.uiConfig.statisticsShowProjectStatistic,
                            statisticsShowCategoryStatistic: AppConfigManager.instance.uiConfig.statisticsShowCategoryStatistic,
                            statisticsShowActivityStatistic: AppConfigManager.instance.uiConfig.statisticsShowActivityStatistic,
                            statisticsSelectedRange: AppConfigManager.instance.uiConfig.statisticsSelectedRange,
                            statisticsCustomRangeStart: AppConfigManager.instance.uiConfig.statisticsCustomRangeStart,
                            statisticsCustomRangeEnd: AppConfigManager.instance.uiConfig.statisticsCustomRangeEnd,
                            statisticsSelectedProjects: AppConfigManager.instance.uiConfig.statisticsSelectedProjects,
                            useNewItemForm: value,
                          );
                          AppConfigManager.instance.setUiConfig(newConfig);
                          setState(() {});
                        },
                        activeThumbColor: colorScheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // 统计页设置
            CommonCardContainer(
              padding: spacing.listItemPadding,
              margin: EdgeInsets.only(bottom: spacing.formGroupSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  Row(
                    children: [
                      Icon(
                        Icons.bar_chart_outlined,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        L10nManager.l10n.tabStatistics,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 默认时间范围选择
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '默认时间范围',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '统计页面默认显示的时间范围',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButton<String>(
                            value: _statisticsSelectedRange,
                            underline: const SizedBox(),
                            items: const [
                              DropdownMenuItem(
                                  value: 'month', child: Text('本月')),
                              DropdownMenuItem(
                                  value: 'year', child: Text('本年')),
                              DropdownMenuItem(
                                  value: 'week', child: Text('本周')),
                              DropdownMenuItem(value: 'all', child: Text('全部')),
                              DropdownMenuItem(
                                  value: 'custom', child: Text('自定义')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                if (value == 'custom') {
                                  _showCustomDateRangePicker();
                                } else {
                                  setState(() {
                                    _statisticsSelectedRange = value;
                                  });
                                  _updateUiConfig();
                                }
                              }
                            },
                          ),
                          if (_statisticsSelectedRange == 'custom' &&
                              _customRange != null)
                            Padding(
                              padding: EdgeInsets.only(right: spacing.formItemSpacing - spacing.listItemSpacing / 2),
                              child: Text(
                                _getCustomRangeText(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 账本统计卡片展示开关
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '账本统计卡片',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '显示收入/支出/余额概览',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _showStatisticsBookStatistic,
                        onChanged: (value) {
                          setState(() {
                            _showStatisticsBookStatistic = value;
                          });
                          _updateUiConfig();
                        },
                        activeThumbColor: colorScheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 按项目统计展示开关
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '按项目统计',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '显示各项目的收支统计',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _showStatisticsProjectStatistic,
                        onChanged: (value) {
                          setState(() {
                            _showStatisticsProjectStatistic = value;
                          });
                          _updateUiConfig();
                        },
                        activeThumbColor: colorScheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 分类统计展示开关
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '分类统计',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '显示分类收支统计',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _showStatisticsCategoryStatistic,
                        onChanged: (value) {
                          setState(() {
                            _showStatisticsCategoryStatistic = value;
                          });
                          _updateUiConfig();
                        },
                        activeThumbColor: colorScheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 活动统计展示开关
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '活动统计',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '按活动名称统计次数',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _showStatisticsActivityStatistic,
                        onChanged: (value) {
                          setState(() {
                            _showStatisticsActivityStatistic = value;
                          });
                          _updateUiConfig();
                        },
                        activeThumbColor: colorScheme.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 项目选择
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '按项目统计展示',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '选择要展示的项目，不选则展示全部',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: _loadingProjects ? null : _showProjectSelector,
                        child: Text(
                          _selectedProjects.isEmpty
                              ? '全部项目'
                              : '已选${_selectedProjects.length}个',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

          // 我的页面设置
          CommonCardContainer(
            padding: spacing.listItemPadding,
            margin: EdgeInsets.only(bottom: spacing.formGroupSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person_outlined,
                        size: 20, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      L10nManager.l10n.minePageSettings,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            L10nManager.l10n.activityCheckinEntry,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            L10nManager.l10n.activityCheckinEntryDescription,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _showActivityCheckin,
                      onChanged: (value) {
                        setState(() {
                          _showActivityCheckin = value;
                        });
                        _updateUiConfig();
                      },
                      activeThumbColor: colorScheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }

  /// 显示项目选择器
  Future<void> _showProjectSelector() async {
    if (_availableProjects.isEmpty) return;

    final result = await showDialog<List<String>>(
      context: context,
      builder: (context) => _ProjectSelectDialog(
        projects: _availableProjects,
        selectedCodes: _selectedProjects,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedProjects = result;
      });
      _updateUiConfig();
    }
  }

  /// 更新UI配置
  Future<void> _updateUiConfig() async {
    final newConfig = UiConfigDTO(
      itemTabShowDebt: _showDebt,
      itemTabShowDailyBar: _showDailyStats,
      itemTabShowDailyCalendar: _showDailyCalendar,
      itemTabShowUserMonthly: _showUserMonthly,
      itemTabShowProjectMonthly: _showProjectMonthly,
      statisticsShowBookStatistic: _showStatisticsBookStatistic,
      statisticsShowProjectStatistic: _showStatisticsProjectStatistic,
      statisticsShowCategoryStatistic: _showStatisticsCategoryStatistic,
      statisticsShowActivityStatistic: _showStatisticsActivityStatistic,
      mineTabShowActivityCheckin: _showActivityCheckin,
      statisticsSelectedRange: _statisticsSelectedRange,
      statisticsCustomRangeStart: _customRange?.start.millisecondsSinceEpoch,
      statisticsCustomRangeEnd: _customRange?.end.millisecondsSinceEpoch,
      statisticsSelectedProjects: _selectedProjects,
    );
    await AppConfigManager.instance.setUiConfig(newConfig);
  }

  /// 显示自定义日期范围选择器
  Future<void> _showCustomDateRangePicker() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: now,
      initialDateRange: _customRange,
    );
    if (picked != null) {
      setState(() {
        _customRange = picked;
        _statisticsSelectedRange = 'custom';
      });
      _updateUiConfig();
    }
  }

  /// 获取自定义日期范围的显示文本
  String _getCustomRangeText() {
    if (_customRange == null) {
      return '自定义';
    }
    final start = _customRange!.start;
    final end = _customRange!.end;
    final startStr = '${start.year}/${start.month}/${start.day}';
    final endStr = '${end.year}/${end.month}/${end.day}';
    return '$startStr - $endStr';
  }
}

/// 项目选择对话框
class _ProjectSelectDialog extends StatefulWidget {
  final List<AccountSymbol> projects;
  final List<String> selectedCodes;

  const _ProjectSelectDialog({
    required this.projects,
    required this.selectedCodes,
  });

  @override
  State<_ProjectSelectDialog> createState() => _ProjectSelectDialogState();
}

class _ProjectSelectDialogState extends State<_ProjectSelectDialog> {
  late List<String> _selectedCodes;

  @override
  void initState() {
    super.initState();
    _selectedCodes = List.from(widget.selectedCodes);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('选择项目'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 全选/清空按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedCodes = widget.projects.map((p) => p.code).toList();
                    });
                  },
                  child: const Text('全选'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedCodes = [];
                    });
                  },
                  child: const Text('清空'),
                ),
              ],
            ),
            const Divider(),
            // 项目列表
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.projects.length,
                itemBuilder: (context, index) {
                  final project = widget.projects[index];
                  final isSelected = _selectedCodes.contains(project.code);
                  return CheckboxListTile(
                    title: Text(project.name),
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          _selectedCodes.add(project.code);
                        } else {
                          _selectedCodes.remove(project.code);
                        }
                      });
                    },
                    dense: true,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(L10nManager.l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_selectedCodes),
          child: Text(L10nManager.l10n.confirm),
        ),
      ],
    );
  }
}
