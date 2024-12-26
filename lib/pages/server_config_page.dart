import 'package:clsswjz/app_init.dart';
import 'package:clsswjz/manager/app_config_manager.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/health_service.dart';
import '../utils/toast_util.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ServerConfigPage extends StatefulWidget {
  const ServerConfigPage({super.key});

  @override
  State<ServerConfigPage> createState() => _ServerConfigPageState();
}

class _ServerConfigPageState extends State<ServerConfigPage> {
  final _formKey = GlobalKey<FormState>();
  final _serverController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isChecking = false;
  bool _serverValid = false;

  @override
  void dispose() {
    _serverController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkServer() async {
    final l10n = AppLocalizations.of(context)!;
    if (_serverController.text.isEmpty) {
      ToastUtil.showError(l10n!.pleaseInputServerAddress);
      return;
    }
    setState(() => _isChecking = true);
    try {
      final healthService = HealthService(_serverController.text);
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

  Future<void> _login() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (!_serverValid) {
      ToastUtil.showError(l10n.pleaseCheckServerFirst);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authService = AuthService(_serverController.text);
      final result = await authService.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (result.ok && result.data != null) {
        // 设置用户信息和token
        await AppConfigManager.setServerInfo(
          _serverController.text,
          result.data!.userId,
          result.data!.accessToken,
        );
        await init();
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.serverConfig),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _serverController,
                    decoration: InputDecoration(
                      labelText: l10n.serverAddress,
                      hintText: 'http://example.com',
                      prefixIcon: const Icon(Icons.computer),
                      suffixIcon: _isChecking
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              _serverValid ? Icons.check_circle : Icons.error,
                              color: _serverValid ? Colors.green : Colors.red,
                            ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.pleaseInputServerAddress;
                      }
                      return null;
                    },
                  ),
                ),
                IconButton(
                  onPressed: _isChecking ? null : _checkServer,
                  icon: const Icon(Icons.refresh),
                  tooltip: l10n.checkServer,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: l10n.username,
                prefixIcon: const Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.pleaseInputUsername;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: l10n.password,
                prefixIcon: const Icon(Icons.lock),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.pleaseInputPassword;
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.login),
            ),
          ],
        ),
      ),
    );
  }
}
