import 'package:clsswjz/enums/storage_mode.dart';
import 'package:clsswjz/manager/app_config_manager.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/health_service.dart';
import '../utils/toast_util.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets/common/common_select_form_field.dart';
import '../widgets/common/common_app_bar.dart';
import '../widgets/common/restart_widget.dart';
import '../widgets/forms/offline_form.dart';
import '../widgets/forms/self_host_form.dart';

class ServerConfigPage extends StatefulWidget {
  const ServerConfigPage({super.key});

  @override
  State<ServerConfigPage> createState() => _ServerConfigPageState();
}

class _ServerConfigPageState extends State<ServerConfigPage> {
  final _formKey = GlobalKey<FormState>();
  String _serverUrl = '';
  String _username = '';
  String _password = '';
  String _nickname = '';
  String _email = '';
  String _phone = '';
  bool _isLoading = false;
  bool _isChecking = false;
  bool _serverValid = false;
  StorageMode _storageMode = StorageMode.offline;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _checkServer() async {
    final l10n = AppLocalizations.of(context)!;
    if (_serverUrl.isEmpty) {
      ToastUtil.showError(l10n.pleaseInput(l10n.serverAddress));
      return;
    }
    setState(() => _isChecking = true);
    try {
      final healthService = HealthService(_serverUrl);
      final result = await healthService.checkHealth();
      if (result.ok && result.data?.status == 'ok') {
        setState(() => _serverValid = true);
        ToastUtil.showSuccess(l10n.serverConnectionSuccess);
      } else {
        setState(() => _serverValid = false);
        ToastUtil.showError(l10n.serverConnectionFailed);
      }
    } catch (e) {
      setState(() => _serverValid = false);
      ToastUtil.showError(l10n.serverConnectionError);
    } finally {
      setState(() => _isChecking = false);
    }
  }

  Future<void> _initOffline() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await AppConfigManager.storageOfflineMode(
          username: _username,
          nickname: _nickname,
          email: _email,
          phone: _phone);
      RestartWidget.restartApp(context);
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      ToastUtil.showError(l10n.initializationFailed);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _initSelfhost() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (!_serverValid) {
      ToastUtil.showError(l10n.pleaseCheckServerFirst);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authService = AuthService(_serverUrl);
      final result = await authService.login(
        _username,
        _password,
      );
      if (result.ok && result.data != null) {
        await AppConfigManager.storgeSelfhostMode(
          _serverUrl,
          result.data!.userId,
          result.data!.accessToken,
        );
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        ToastUtil.showError(l10n.loginFailed);
      }
    } catch (e) {
      ToastUtil.showError(l10n.loginError);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(l10n.serverConfig),
        showLanguageSelector: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            CommonSelectFormField<StorageMode>(
              items: StorageMode.values.toList(),
              value: _storageMode,
              displayMode: DisplayMode.iconText,
              displayField: (item) => item.displayName(context),
              keyField: (item) => item,
              label: l10n.storageMode,
              icon: Icons.storage,
              onChanged: (value) {
                setState(() {
                  _storageMode = value;
                });
              },
            ),
            if (_storageMode == StorageMode.selfHost)
              SelfHostForm(
                serverUrl: _serverUrl,
                username: _username,
                password: _password,
                isChecking: _isChecking,
                serverValid: _serverValid,
                isLoading: _isLoading,
                onServerUrlChanged: (value) =>
                    setState(() => _serverUrl = value),
                onUsernameChanged: (value) => setState(() => _username = value),
                onPasswordChanged: (value) => setState(() => _password = value),
                onCheckServer: _checkServer,
                onSubmit: _initSelfhost,
              ),
            if (_storageMode == StorageMode.offline)
              OfflineForm(
                username: _username,
                nickname: _nickname,
                email: _email,
                phone: _phone,
                isLoading: _isLoading,
                onUsernameChanged: (value) => setState(() => _username = value),
                onNicknameChanged: (value) => setState(() => _nickname = value),
                onEmailChanged: (value) => setState(() => _email = value),
                onPhoneChanged: (value) => setState(() => _phone = value),
                onSubmit: _initOffline,
              ),
          ],
        ),
      ),
    );
  }
}
