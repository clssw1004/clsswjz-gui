import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../enums/self_host_form_type.dart';
import '../../enums/storage_mode.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../models/self_host_form_data.dart';
import '../../providers/sync_provider.dart';
import '../../services/auth_service.dart';
import '../../utils/device.util.dart';
import '../../utils/toast_util.dart';

import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/restart_widget.dart';
import '../../widgets/setting/offline_form.dart';
import '../../widgets/setting/self_host_form.dart';
import '../../theme/theme_spacing.dart';
import '../../theme/theme_radius.dart';

class ServerConfigPage extends StatefulWidget {
  const ServerConfigPage({super.key});

  @override
  State<ServerConfigPage> createState() => _ServerConfigPageState();
}

class _ServerConfigPageState extends State<ServerConfigPage> {
  bool _isLoading = false;
  StorageMode _storageMode = StorageMode.selfHost;

  Future<void> _initOffline(OfflineFormData data) async {
    setState(() => _isLoading = true);
    await AppConfigManager.storageOfflineMode(
      username: data.username,
      nickname: data.nickname,
      email: data.email ?? '',
      phone: data.phone ?? '',
      bookName: data.bookName,
      bookIcon: data.bookIcon,
    );
    await AppConfigManager.instance.makeStorageInit();
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      RestartWidget.restartApp(context);
    }
  }

  Future<void> _initSelfhost(
    SelfHostFormData data,
    SelfHostFormType type,
  ) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final deviceInfo = await DeviceUtil.getDeviceInfo(context);
      final authService = AuthService(data.serverUrl);
      final result = await authService.loginOrRegister(type, data, deviceInfo);
      if (result.ok && result.data != null) {
        await AppConfigManager.storgeSelfhostMode(
          serverUrl: data.serverUrl,
          userId: result.data!.userId,
          accessToken: result.data!.accessToken,
          bookName: data.bookName,
        );
        if (!mounted) return;
        final syncProvider = Provider.of<SyncProvider>(context, listen: false);
        await syncProvider.syncPriorityData();
        await AppConfigManager.instance.makeStorageInit();
        if (mounted) {
          RestartWidget.restartApp(context);
        }
      } else {
        ToastUtil.showError(L10nManager.l10n.loginFailed);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.spacing;
    final radius = theme.extension<ThemeRadius>()?.radius ?? 12;
    final canPop = Navigator.canPop(context);

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(L10nManager.l10n.serverConfig),
        showBackButton: canPop,
        showLanguageSelector: true,
        showThemeSelector: true,
      ),
      body: SingleChildScrollView(
        padding: spacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(theme, colorScheme),
            SizedBox(height: spacing.formItemSpacing),
            _buildFormCard(theme, colorScheme, radius),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.cloud_sync_rounded,
          size: 24,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _buildFormCard(
    ThemeData theme,
    ColorScheme colorScheme,
    double radius,
  ) {
    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius * 1.5),
        side: BorderSide(color: colorScheme.outline.withAlpha(25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildModeTiles(theme, colorScheme),
            const SizedBox(height: 16),
            Divider(height: 1, color: colorScheme.outline.withAlpha(20)),
            const SizedBox(height: 16),
            Theme(
              data: theme.copyWith(
                visualDensity: VisualDensity.compact,
                extensions: [
                  ThemeSpacing(
                    formItemSpacing: 10,
                    formGroupSpacing: 14,
                  ),
                  if (theme.extension<ThemeRadius>() case final tr?)
                    tr,
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.06),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: _storageMode == StorageMode.selfHost
                    ? SelfHostForm(
                        key: const ValueKey('selfhost'),
                        isLoading: _isLoading,
                        onSubmit: _initSelfhost,
                      )
                    : OfflineForm(
                        key: const ValueKey('offline'),
                        isLoading: _isLoading,
                        onSubmit: _initOffline,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeTiles(ThemeData theme, ColorScheme colorScheme) {
    const modeData = {
      StorageMode.selfHost: Icons.dns_rounded,
      StorageMode.offline: Icons.phone_android_rounded,
    };

    return Row(
      children: StorageMode.values.map((mode) {
        final isSelected = _storageMode == mode;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: mode == StorageMode.values.last ? 0 : 8,
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => setState(() => _storageMode = mode),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainerHighest.withAlpha(40),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary.withAlpha(80)
                          : colorScheme.outline.withAlpha(40),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        modeData[mode],
                        size: 18,
                        color: isSelected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        mode.displayName(context),
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: isSelected
                              ? colorScheme.onPrimaryContainer
                              : colorScheme.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.w600 : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
