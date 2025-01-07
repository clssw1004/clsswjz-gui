import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../providers/sync_provider.dart';
import '../../theme/theme_spacing.dart';
import '../../utils/toast_util.dart';

class SyncDataButton extends StatelessWidget {
  const SyncDataButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = Theme.of(context).spacing;
    final syncProvider = context.watch<SyncProvider>();

    return Container(
      padding: EdgeInsets.all(spacing.formItemSpacing),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: syncProvider.syncing
            ? null
            : () async {
                try {
                  await syncProvider.syncData();
                  if (context.mounted) {
                    ToastUtil.showSuccess(l10n.syncSuccess);
                  }
                } catch (e) {
                  ToastUtil.showError(l10n.syncFailed);
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
        label: Text(syncProvider.syncing ? l10n.syncing : l10n.syncData),
      ),
    );
  }
}
