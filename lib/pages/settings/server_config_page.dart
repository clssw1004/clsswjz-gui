import 'package:clsswjz/enums/storage_mode.dart';
import 'package:clsswjz/manager/app_config_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../services/auth_service.dart';
import '../../services/health_service.dart';
import '../../utils/toast_util.dart';

import '../../widgets/common/common_select_form_field.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/restart_widget.dart';
import '../../widgets/forms/offline_form.dart';
import '../../widgets/forms/self_host_form.dart';
import '../../theme/theme_spacing.dart';

class ServerConfigPage extends StatefulWidget {
  const ServerConfigPage({super.key});

  @override
  State<ServerConfigPage> createState() => _ServerConfigPageState();
}

class _ServerConfigPageState extends State<ServerConfigPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _serverUrlController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _nicknameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bookNameController;
  String _serverUrl = 'http://192.168.2.147:3000';
  String _username = 'cuiwei';
  String _password = 'cuiwei';
  String _nickname = '崔伟';
  String _email = 'cuiwei@clsswjz.com';
  String _phone = '13800138000';
  String _bookName = '崔伟的账本';
  String _bookIcon = Icons.book_outlined.codePoint.toString();
  bool _isLoading = false;
  bool _isChecking = false;
  bool _serverValid = false;
  StorageMode _storageMode = StorageMode.offline;

  @override
  void initState() {
    super.initState();
    _serverUrlController = TextEditingController(text: _serverUrl);
    _usernameController = TextEditingController(text: _username);
    _passwordController = TextEditingController(text: _password);
    _nicknameController = TextEditingController(text: _nickname);
    _emailController = TextEditingController(text: _email);
    _phoneController = TextEditingController(text: _phone);
    _bookNameController = TextEditingController(text: _bookName);
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bookNameController.dispose();
    super.dispose();
  }

  Future<Map<String, String>> _getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    try {
      if (Theme.of(context).platform == TargetPlatform.android) {
        final androidInfo = await deviceInfo.androidInfo;
        return {
          'clientId': androidInfo.id,
          'clientName': '${androidInfo.brand} ${androidInfo.model}',
        };
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return {
          'clientId': iosInfo.identifierForVendor ?? 'unknown',
          'clientName': '${iosInfo.name} ${iosInfo.model}',
        };
      } else if (Theme.of(context).platform == TargetPlatform.windows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        return {
          'clientId': windowsInfo.deviceId,
          'clientName': '${windowsInfo.computerName} (Windows)',
        };
      } else if (Theme.of(context).platform == TargetPlatform.macOS) {
        final macOsInfo = await deviceInfo.macOsInfo;
        return {
          'clientId': macOsInfo.systemGUID ?? 'unknown',
          'clientName': '${macOsInfo.computerName} (macOS)',
        };
      } else if (Theme.of(context).platform == TargetPlatform.linux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        return {
          'clientId': linuxInfo.machineId ?? 'unknown',
          'clientName': '${linuxInfo.name} (Linux)',
        };
      }
      return {
        'clientId': 'unknown',
        'clientName': 'Unknown Device',
      };
    } catch (e) {
      return {
        'clientId': 'unknown',
        'clientName': 'Unknown Device',
      };
    }
  }

  Future<void> _checkServer() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final healthService = HealthService(_serverUrl);
    final result = await healthService.checkHealth();
    setState(() {
      _isLoading = false;
      _serverValid = result.ok;
    });

    if (result.ok) {
      ToastUtil.showSuccess(l10n.serverConnectionSuccess);
    } else {
      ToastUtil.showError(result.message ?? l10n.serverConnectionFailed);
    }
  }

  Future<void> _initOffline() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await AppConfigManager.storageOfflineMode(context,
        username: _username, nickname: _nickname, email: _email, phone: _phone, bookName: _bookName, bookIcon: _bookIcon);
    RestartWidget.restartApp(context);
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
      final deviceInfo = await _getDeviceInfo();
      final authService = AuthService(_serverUrl);
      final result = await authService.login(
        _username,
        _password,
        clientType: Theme.of(context).platform.name,
        clientId: deviceInfo['clientId'],
        clientName: deviceInfo['clientName'],
      );
      if (result.ok && result.data != null) {
        await AppConfigManager.storgeSelfhostMode(
          _serverUrl,
          result.data!.userId,
          result.data!.accessToken,
        );
        RestartWidget.restartApp(context);
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
    final spacing = Theme.of(context).spacing;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(l10n.serverConfig),
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
              label: l10n.storageMode,
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
                serverUrlController: _serverUrlController,
                usernameController: _usernameController,
                passwordController: _passwordController,
                isChecking: _isChecking,
                serverValid: _serverValid,
                isLoading: _isLoading,
                onServerUrlChanged: (value) => setState(() => _serverUrl = value),
                onUsernameChanged: (value) => setState(() => _username = value),
                onPasswordChanged: (value) => setState(() => _password = value),
                onCheckServer: _checkServer,
                onSubmit: _initSelfhost,
              ),
            if (_storageMode == StorageMode.offline)
              OfflineForm(
                usernameController: _usernameController,
                nicknameController: _nicknameController,
                emailController: _emailController,
                phoneController: _phoneController,
                bookNameController: _bookNameController,
                bookIcon: _bookIcon,
                isLoading: _isLoading,
                onUsernameChanged: (value) => setState(() => _username = value),
                onNicknameChanged: (value) => setState(() => _nickname = value),
                onEmailChanged: (value) => setState(() => _email = value),
                onPhoneChanged: (value) => setState(() => _phone = value),
                onBookNameChanged: (value) => setState(() => _bookName = value),
                onBookIconChanged: (value) => setState(() => _bookIcon = value),
                onSubmit: _initOffline,
              ),
          ],
        ),
      ),
    );
  }
}
