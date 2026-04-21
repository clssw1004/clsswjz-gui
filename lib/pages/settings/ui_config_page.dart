import 'package:flutter/material.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../models/dto/ui_config_dto.dart';
import '../../widgets/common/common_card_container.dart';

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
  late String _statisticsSelectedRange;
  DateTimeRange? _customRange;

  @override
  void initState() {
    super.initState();
    _showDebt = AppConfigManager.instance.uiConfig.itemTabShowDebt;
    _showDailyStats = AppConfigManager.instance.uiConfig.itemTabShowDailyBar;
    _showDailyCalendar = AppConfigManager.instance.uiConfig.itemTabShowDailyCalendar;
    _showUserMonthly = AppConfigManager.instance.uiConfig.itemTabShowUserMonthly;
    _showProjectMonthly = AppConfigManager.instance.uiConfig.itemTabShowProjectMonthly;
    _statisticsSelectedRange = AppConfigManager.instance.uiConfig.statisticsSelectedRange;
    final customStart = AppConfigManager.instance.uiConfig.statisticsCustomRangeStart;
    final customEnd = AppConfigManager.instance.uiConfig.statisticsCustomRangeEnd;
    if (customStart != null && customEnd != null) {
      _customRange = DateTimeRange(
        start: DateTime.fromMillisecondsSinceEpoch(customStart),
        end: DateTime.fromMillisecondsSinceEpoch(customEnd),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(L10nManager.l10n.uiLayoutSettings),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 记账页设置
            CommonCardContainer(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 16),
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
                ],
              ),
            ),

            // 统计页设置
            CommonCardContainer(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 16),
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
                              DropdownMenuItem(value: 'month', child: Text('本月')),
                              DropdownMenuItem(value: 'year', child: Text('本年')),
                              DropdownMenuItem(value: 'week', child: Text('本周')),
                              DropdownMenuItem(value: 'all', child: Text('全部')),
                              DropdownMenuItem(value: 'custom', child: Text('自定义')),
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
                          if (_statisticsSelectedRange == 'custom' && _customRange != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 12),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 更新UI配置
  Future<void> _updateUiConfig() async {
    final newConfig = UiConfigDTO(
      itemTabShowDebt: _showDebt,
      itemTabShowDailyBar: _showDailyStats,
      itemTabShowDailyCalendar: _showDailyCalendar,
      itemTabShowUserMonthly: _showUserMonthly,
      itemTabShowProjectMonthly: _showProjectMonthly,
      statisticsSelectedRange: _statisticsSelectedRange,
      statisticsCustomRangeStart: _customRange?.start.millisecondsSinceEpoch,
      statisticsCustomRangeEnd: _customRange?.end.millisecondsSinceEpoch,
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
