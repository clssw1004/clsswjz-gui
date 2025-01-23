import 'package:clsswjz/enums/storage_mode.dart';
import 'package:clsswjz/manager/app_config_manager.dart';
import 'package:clsswjz/providers/sync_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../manager/l10n_manager.dart';
import '../../services/auth_service.dart';
import '../../services/health_service.dart';
import '../../utils/device.util.dart';
import '../../utils/toast_util.dart';

import '../../widgets/common/common_select_form_field.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/restart_widget.dart';
import '../../widgets/setting/offline_form.dart';
import '../../widgets/setting/self_host_form.dart';
import '../../theme/theme_spacing.dart';

class ServerConfigPage extends StatefulWidget {
  const ServerConfigPage({super.key});

  @override
  State<ServerConfigPage> createState() => _ServerConfigPageState();
}

class _ServerConfigPageState extends State<ServerConfigPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final bool _isChecking = false;
  bool _serverValid = false;
  StorageMode _storageMode = StorageMode.selfHost;

  Future<void> _checkServer(String serverUrl) async {
    setState(() => _isLoading = true);
    final healthService = HealthService(serverUrl);
    final result = await healthService.checkHealth();
    setState(() {
      _isLoading = false;
      _serverValid = result.ok;
    });
  }

  /// 初始化离线模式
  Future<void> _initOffline(OfflineFormData data) async {
    setState(() => _isLoading = true);
    await AppConfigManager.storageOfflineMode(
      context,
      username: data.username,
      nickname: data.nickname,
      email: data.email ?? '',
      phone: data.phone ?? '',
      bookName: data.bookName,
      bookIcon: data.bookIcon,
    );
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      RestartWidget.restartApp(context);
    }
  }

  Future<void> _initSelfhost(SelfHostFormData data, SelfHostFormType type) async {
    if (_isLoading) {
      return;
    }
    setState(() => _isLoading = true);
    try {
      final deviceInfo = await DeviceUtil.getDeviceInfo(context);
      final authService = AuthService(data.serverUrl);
      final result = await authService.loginOrRegister(type, data, deviceInfo);
      if (result.ok && result.data != null) {
        await AppConfigManager.storgeSelfhostMode(
          data.serverUrl,
          result.data!.userId,
          result.data!.accessToken,
          bookName: data.bookName,
        );
        final syncProvider = Provider.of<SyncProvider>(context, listen: false);
        await syncProvider.syncData();
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          RestartWidget.restartApp(context);
        }
      } else {
        ToastUtil.showError(L10nManager.l10n.loginFailed);
      }
      // } catch (e) {
      //   ToastUtil.showError(L10nManager.l10n.loginError);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).spacing;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(L10nManager.l10n.serverConfig),
        showLanguageSelector: true,
        showThemeSelector: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: spacing.formPadding,
          children: [
            CommonSelectFormField<StorageMode>(
              items: StorageMode.values.toList(),
              value: _storageMode,
              displayMode: DisplayMode.iconText,
              displayField: (item) => item.displayName(context),
              keyField: (item) => item,
              label: L10nManager.l10n.storageMode,
              icon: Icons.storage,
              onChanged: (value) {
                setState(() {
                  _storageMode = value;
                });
              },
            ),
            SizedBox(height: spacing.formItemSpacing),
            if (_storageMode == StorageMode.selfHost)
              SelfHostForm(
                isChecking: _isChecking,
                serverValid: _serverValid,
                isLoading: _isLoading,
                onCheckServer: _checkServer,
                onSubmit: _initSelfhost,
              ),
            if (_storageMode == StorageMode.offline)
              OfflineForm(
                isLoading: _isLoading,
                onSubmit: _initOffline,
              ),
          ],
        ),
      ),
    );
  }
}
