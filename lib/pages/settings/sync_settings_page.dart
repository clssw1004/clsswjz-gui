import 'package:clsswjz/manager/app_config_manager.dart';
import 'package:clsswjz/utils/http_client.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../manager/l10n_manager.dart';
import '../../providers/sync_provider.dart';
import '../../theme/theme_spacing.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/common_dialog.dart';
import '../../widgets/setting/self_host_auth_form.dart';

class SyncSettingsPage extends StatefulWidget {
  const SyncSettingsPage({super.key});

  @override
  State<SyncSettingsPage> createState() => _SyncSettingsPageState();
}

class _SyncSettingsPageState extends State<SyncSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  late String _serverUrl;

  String? get _maskedAccessToken {
    final token = AppConfigManager.instance.accessToken;
    if (token.isEmpty) return null;
    if (token.length <= 8) return token;
    return '${token.substring(0, 4)}...${token.substring(token.length - 4)}';
  }

  @override
  void initState() {
    super.initState();
    _serverUrl = AppConfigManager.instance.serverUrl;
  }

  Future<void> _handleSubmit(
      String serverUrl, String username, String password) async {
    // 先保存服务器URL配置
    await AppConfigManager.instance.setServerUrl(serverUrl);
    await HttpClient.refresh(serverUrl: serverUrl);
    // 再进行同步
    if (!mounted) return;
    final syncProvider = context.read<SyncProvider>();
    await syncProvider.syncData();
    Navigator.of(context).pop();
  }

  void _showConfigDialog() {
    final syncProvider = context.read<SyncProvider>();
    CommonDialog.show(
      context: context,
      title: L10nManager.l10n.serverConfig,
      content: SelfHostAuthForm(
        isLoading: syncProvider.syncing,
        onSubmit: _handleSubmit,
        initServerUrl: _serverUrl,
        submitText:
            "${L10nManager.l10n.reset}${L10nManager.l10n.accessToken}&${L10nManager.l10n.syncData}",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.spacing;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(L10nManager.l10n.syncSettings),
        actions: [
          IconButton(
            onPressed: _showConfigDialog,
            icon: const Icon(Icons.refresh),
            tooltip: L10nManager.l10n.reset,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            ListTile(
              leading: const Icon(Icons.computer),
              title: Text(L10nManager.l10n.serverAddress),
              subtitle: Text(_serverUrl),
              tileColor: theme.colorScheme.onInverseSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            if (_maskedAccessToken != null) ...[
              SizedBox(height: spacing.formItemSpacing),
              ListTile(
                leading: const Icon(Icons.key),
                title: Text(L10nManager.l10n.accessToken),
                subtitle: Text(_maskedAccessToken!),
                tileColor: theme.colorScheme.onInverseSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
