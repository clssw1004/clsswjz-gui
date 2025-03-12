
import 'package:flutter/material.dart';

import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../routes/app_routes.dart';
import '../../theme/theme_spacing.dart';
import '../../utils/http_client.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/common_dialog.dart';
import '../../widgets/setting/server_url_field.dart';

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

  void _showEditServerUrlDialog() {
    final controller = TextEditingController(text: _serverUrl);
    CommonDialog.show(
      context: context,
      title: L10nManager.l10n.serverAddress,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ServerUrlField(controller: controller),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(L10nManager.l10n.cancel),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () async {
                  final newUrl = controller.text.trim();
                  if (newUrl.isNotEmpty && newUrl != _serverUrl) {
                    await AppConfigManager.instance.setServerUrl(newUrl);
                    await HttpClient.refresh(serverUrl: newUrl);
                    if (!mounted) return;
                    setState(() {
                      _serverUrl = newUrl;
                    });
                  }
                  if (!mounted) return;
                  Navigator.of(context).pop();
                },
                child: Text(L10nManager.l10n.confirm),
              ),
            ],
          ),
        ],
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
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _showEditServerUrlDialog,
                tooltip: L10nManager.l10n.edit,
              ),
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
                trailing: TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.resetAuth,
                      arguments: _serverUrl,
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(L10nManager.l10n.reset),
                ),
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
