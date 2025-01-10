import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../providers/sync_provider.dart';
import '../../utils/toast_util.dart';
import '../../theme/theme_spacing.dart';

class SyncDataButton extends StatelessWidget {
  const SyncDataButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final syncProvider = context.watch<SyncProvider>();
    final spacing = Theme.of(context).spacing;

    return Container(
      padding: EdgeInsets.all(spacing.formItemSpacing),
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/sync_settings');
              },
              icon: const Icon(Icons.sync_alt),
              label: Text(l10n.syncSettings),
            ),
          ),
          SizedBox(width: spacing.formItemSpacing),
          IconButton(
            onPressed: syncProvider.syncing
                ? null
                : () async {
                    try {
                      await syncProvider.syncData();
                      if (context.mounted) {
                        ToastUtil.showSuccess(l10n.syncSuccess);
                      }
                    } catch (e) {
                      ToastUtil.showError(l10n.syncFailed(e.toString()));
                    }
                  },
            icon: syncProvider.syncing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
          ),
        ],
      ),
    );
  }
}
