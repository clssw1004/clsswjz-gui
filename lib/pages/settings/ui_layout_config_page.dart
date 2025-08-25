import 'package:flutter/material.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../models/dto/ui_config_dto.dart';
import '../../utils/toast_util.dart';
import '../../widgets/common/common_card_container.dart';

/// UI布局配置页面
class UiConfigPage extends StatefulWidget {
  const UiConfigPage({super.key});

  @override
  State<UiConfigPage> createState() => _UiConfigPageState();
}

class _UiConfigPageState extends State<UiConfigPage> {
  late bool _showDebt;

  @override
  void initState() {
    super.initState();
    _showDebt = AppConfigManager.instance.uiConfig.itemTabShowDebt;
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
              padding: const EdgeInsets.all(16),
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
                        activeColor: colorScheme.primary,
                      ),
                    ],
                  ),
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
    );

    await AppConfigManager.instance.setUiConfig(newConfig);

    if (mounted) {
      ToastUtil.showSuccess(L10nManager.l10n.settingsSaved);
    }
  }
}
