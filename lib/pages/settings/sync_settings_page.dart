import 'package:clsswjz/manager/app_config_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../manager/l10n_manager.dart';
import '../../providers/sync_provider.dart';
import '../../theme/theme_spacing.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/setting/server_url_field.dart';

class SyncSettingsPage extends StatefulWidget {
  const SyncSettingsPage({super.key});

  @override
  State<SyncSettingsPage> createState() => _SyncSettingsPageState();
}

class _SyncSettingsPageState extends State<SyncSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _serverController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _serverController.text = AppConfigManager.instance.serverUrl;
  }

  @override
  void dispose() {
    _serverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final syncProvider = context.watch<SyncProvider>();

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(L10nManager.l10n.syncSettings),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            ServerUrlField(
              controller: _serverController,
            ),
            SizedBox(height: spacing.formItemSpacing),
            Container(
              margin: EdgeInsets.symmetric(vertical: spacing.formItemSpacing),
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: syncProvider.syncing
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          await syncProvider.syncData();
                        }
                      },
                icon: syncProvider.syncing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.sync),
                label: Text(syncProvider.syncing
                    ? L10nManager.l10n.syncing
                    : L10nManager.l10n.syncData),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
