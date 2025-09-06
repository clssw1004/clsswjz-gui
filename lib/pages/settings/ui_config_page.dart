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

  @override
  void initState() {
    super.initState();
    _showDebt = AppConfigManager.instance.uiConfig.itemTabShowDebt;
    _showDailyStats = AppConfigManager.instance.uiConfig.itemTabShowDailyBar;
    _showDailyCalendar = AppConfigManager.instance.uiConfig.itemTabShowDailyCalendar;
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
    );
    await AppConfigManager.instance.setUiConfig(newConfig);
  }
}
