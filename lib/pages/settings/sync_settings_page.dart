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
  late final TextEditingController _serverUrlController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  String _serverUrl = '';
  String _username = '';
  String _password = '';
  final bool _isChecking = false;
  final bool _serverValid = false;

  @override
  void initState() {
    super.initState();
    _serverUrlController = TextEditingController(text: _serverUrl);
    _usernameController = TextEditingController(text: _username);
    _passwordController = TextEditingController(text: _password);
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
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
            const Divider(),
            SelfHostForm(
              serverUrlController: _serverUrlController,
              usernameController: _usernameController,
              passwordController: _passwordController,
              isChecking: _isChecking,
              serverValid: _serverValid,
              isLoading: false,
              onServerUrlChanged: (value) => setState(() => _serverUrl = value),
              onUsernameChanged: (value) => setState(() => _username = value),
              onPasswordChanged: (value) => setState(() => _password = value),
              onCheckServer: () {},
              onSubmit: () {},
            ),
          ],
        ),
      ),
    );
  }
}
