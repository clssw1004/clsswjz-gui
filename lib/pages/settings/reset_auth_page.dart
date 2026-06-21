import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../enums/self_host_form_type.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../models/self_host_form_data.dart';
import '../../providers/sync_provider.dart';
import '../../services/auth_service.dart';
import '../../theme/theme_spacing.dart';
import '../../utils/device.util.dart';
import '../../utils/http_client.dart';
import '../../utils/toast_util.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/common_text_form_field.dart';
import '../../widgets/common/restart_widget.dart';
import '../../widgets/setting/server_url_field.dart';
import '../../widgets/common/common_dialog.dart';
import '../../widgets/common/progress_indicator_bar.dart';
import '../../theme/theme_radius.dart';

class ResetAuthPage extends StatefulWidget {
  final String serverUrl;

  const ResetAuthPage({
    super.key,
    required this.serverUrl,
  });

  @override
  State<ResetAuthPage> createState() => _ResetAuthPageState();
}

class _ResetAuthPageState extends State<ResetAuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _serverController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _serverController.text = widget.serverUrl;
    _usernameController.text = '';
    _passwordController.text = '';
  }

  @override
  void dispose() {
    _serverController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _showConfirmDialog() async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    int countdown = 5;
    bool canConfirm = false;

    final result = await CommonDialog.show<bool>(
      context: context,
      title: L10nManager.l10n.warning,
      titleStyle: theme.textTheme.titleLarge?.copyWith(
        color: colorScheme.error,
        fontWeight: FontWeight.w600,
      ),
      content: StatefulBuilder(
        builder: (context, setState) {
          if (!canConfirm) {
            Future.delayed(const Duration(seconds: 1), () {
              if (countdown > 0) {
                setState(() => countdown--);
              } else {
                setState(() => canConfirm = true);
              }
            });
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: colorScheme.onErrorContainer,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        L10nManager.l10n.resetAuthConfirmation,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.5,
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(L10nManager.l10n.cancel),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.error,
                      foregroundColor: colorScheme.onError,
                      elevation: 0,
                      disabledBackgroundColor: colorScheme.error.withAlpha(128),
                      disabledForegroundColor:
                          colorScheme.onError.withAlpha(128),
                    ),
                    onPressed: canConfirm
                        ? () => Navigator.of(context).pop(true)
                        : null,
                    child: Text(canConfirm
                        ? L10nManager.l10n.confirm
                        : "${L10nManager.l10n.confirm} (${countdown}s)"),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      showCloseButton: false,
    );
    if (result == true) {
      await _handleSubmit();
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final serverUrl = _serverController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    await AppConfigManager.instance.setServerUrl(serverUrl);
    try {
      final deviceInfo = await DeviceUtil.getDeviceInfo(context);
      final authService = AuthService(serverUrl);
      final result = await authService.loginOrRegister(
          SelfHostFormType.login,
          SelfHostFormData(
              serverUrl: serverUrl, username: username, password: password),
          deviceInfo);
      if (result.ok && result.data != null) {
        await AppConfigManager.storgeSelfhostMode(
          serverUrl: serverUrl,
          userId: result.data!.userId,
          accessToken: result.data!.accessToken,
          clearData: true,
        );
        if (!mounted) return;
        final syncProvider = Provider.of<SyncProvider>(context, listen: false);
        await syncProvider.syncData();
        await AppConfigManager.instance.makeStorageInit();
        if (mounted) {
          RestartWidget.restartApp(context);
        }
      } else {
        ToastUtil.showError(L10nManager.l10n.loginFailed);
      }
    } finally {}
  }

  Future<void> _handleRefreshCredentials() async {
    if (!_formKey.currentState!.validate()) return;

    final serverUrl = _serverController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    try {
      final deviceInfo = await DeviceUtil.getDeviceInfo(context);
      final authService = AuthService(serverUrl);
      final result = await authService.loginOrRegister(
          SelfHostFormType.login,
          SelfHostFormData(
              serverUrl: serverUrl, username: username, password: password),
          deviceInfo);
      if (result.ok && result.data != null) {
        final newToken = result.data!.accessToken;
        await AppConfigManager.instance.setServerUrl(serverUrl);
        await AppConfigManager.instance.setAccessToken(newToken);
        // 刷新 HTTP 客户端使新 token 在后续同步中生效
        await HttpClient.refresh(serverUrl: serverUrl, accessToken: newToken);
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        ToastUtil.showError(L10nManager.l10n.loginFailed);
      }
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final radius = theme.extension<ThemeRadius>()?.radius ?? 12;
    final syncProvider = context.watch<SyncProvider>();

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(L10nManager.l10n.serverConfig),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(theme, colorScheme),
            const SizedBox(height: 16),
            _buildFormCard(theme, colorScheme, radius, syncProvider),
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
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          Icons.fingerprint_rounded,
          size: 24,
          color: colorScheme.onErrorContainer,
        ),
      ),
    );
  }

  Widget _buildFormCard(
    ThemeData theme,
    ColorScheme colorScheme,
    double radius,
    SyncProvider syncProvider,
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
        child: Theme(
          data: theme.copyWith(
            visualDensity: VisualDensity.compact,
            extensions: [
              ThemeSpacing(formItemSpacing: 10, formGroupSpacing: 14),
              if (theme.extension<ThemeRadius>() case final tr?) tr,
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ServerUrlField(controller: _serverController),
                const SizedBox(height: 10),
                CommonTextFormField(
                  controller: _usernameController,
                  labelText: L10nManager.l10n.username,
                  prefixIcon: Icons.person,
                  required: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return L10nManager.l10n
                          .pleaseInput(L10nManager.l10n.username);
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                CommonTextFormField(
                  controller: _passwordController,
                  labelText: L10nManager.l10n.password,
                  prefixIcon: Icons.lock,
                  obscureText: true,
                  required: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return L10nManager.l10n
                          .pleaseInput(L10nManager.l10n.password);
                    }
                    return null;
                  },
                ),
                if (syncProvider.syncing) ...[
                  const SizedBox(height: 14),
                  ProgressIndicatorBar(
                    value: syncProvider.progress,
                    label: syncProvider.currentStep ??
                        L10nManager.l10n.syncing,
                    height: 24,
                  ),
                ],
                const SizedBox(height: 14),
                const Divider(),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonal(
                    onPressed: syncProvider.syncing
                        ? null
                        : _handleRefreshCredentials,
                    child: Text(L10nManager.l10n.reconnect),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed:
                        syncProvider.syncing ? null : _showConfirmDialog,
                    child: syncProvider.syncing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            "${L10nManager.l10n.reset}${L10nManager.l10n.accessToken}&${L10nManager.l10n.syncData}"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
