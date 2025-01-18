import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../manager/l10n_manager.dart';
import '../../providers/sync_provider.dart';
import '../../theme/theme_spacing.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/forms/self_host_form.dart';

class SyncSettingsPage extends StatefulWidget {
  const SyncSettingsPage({super.key});

  @override
  State<SyncSettingsPage> createState() => _SyncSettingsPageState();
}

class _SyncSettingsPageState extends State<SyncSettingsPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
            Container(
              margin: EdgeInsets.symmetric(vertical: spacing.formItemSpacing),
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: syncProvider.syncing
                    ? null
                    : () async {
                        await syncProvider.syncData();
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
                label: Text(syncProvider.syncing ? L10nManager.l10n.syncing : L10nManager.l10n.syncData),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
