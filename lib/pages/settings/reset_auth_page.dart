import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../enums/self_host_form_type.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../models/self_host_form_data.dart';
import '../../providers/sync_provider.dart';
import '../../services/auth_service.dart';
import '../../utils/device.util.dart';
import '../../utils/toast_util.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/common_text_form_field.dart';
import '../../theme/theme_spacing.dart';
import '../../widgets/common/restart_widget.dart';
import '../../widgets/setting/server_url_field.dart';
import '../../widgets/common/common_dialog.dart';
import '../../widgets/common/progress_indicator_bar.dart';

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
    // 从配置中获取并设置用户名和密码
    _usernameController.text = ''; // 用户名通常需要用户重新输入
    _passwordController.text = ''; // 密码通常需要用户重新输入
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
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

    // 先保存服务器URL配置
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
        final syncProvider = Provider.of<SyncProvider>(context, listen: false);
        await syncProvider.syncData();
        await AppConfigManager.instance.makeStorageInit();
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
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

    // 先保存服务器URL配置
    try {
      final deviceInfo = await DeviceUtil.getDeviceInfo(context);
      final authService = AuthService(serverUrl);
      final result = await authService.loginOrRegister(
          SelfHostFormType.login,
          SelfHostFormData(
              serverUrl: serverUrl, username: username, password: password),
          deviceInfo);
      if (result.ok && result.data != null) {
        await AppConfigManager.instance.setServerUrl(serverUrl);
        await AppConfigManager.instance
            .setAccessToken(result.data!.accessToken);
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
    final syncProvider = context.watch<SyncProvider>();
    final spacing = Theme.of(context).spacing;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(L10nManager.l10n.serverConfig),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ServerUrlField(
                controller: _serverController,
              ),
              SizedBox(height: spacing.formItemSpacing),
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
              SizedBox(height: spacing.formItemSpacing),
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
              SizedBox(height: spacing.formGroupSpacing),
              if (syncProvider.syncing)
                if (syncProvider.syncing)
                  ProgressIndicatorBar(
                    value: syncProvider.progress,
                    label: syncProvider.currentStep ?? L10nManager.l10n.syncing,
                    height: 24,
                  ),
              SizedBox(height: spacing.formGroupSpacing),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonal(
                      onPressed: syncProvider.syncing
                          ? null
                          : _handleRefreshCredentials,
                      child: Text('刷新凭证'),
                    ),
                  ),
                  const SizedBox(height: 12),
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
            ],
          ),
        ),
      ),
    );
  }
}
