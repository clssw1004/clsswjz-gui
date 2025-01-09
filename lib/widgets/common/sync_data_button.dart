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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final syncProvider = context.watch<SyncProvider>();

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
          Stack(
            alignment: Alignment.center,
            children: [
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
                          ToastUtil.showError(l10n.syncFailed);
                        }
                      },
                icon: syncProvider.syncing ? const SizedBox(width: 24, height: 24) : const Icon(Icons.sync),
              ),
              if (syncProvider.syncing)
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    value: syncProvider.progress > 0 ? syncProvider.progress : null,
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                ),
              if (syncProvider.syncing && syncProvider.currentStep != null)
                Positioned(
                  bottom: -16,
                  child: Text(
                    syncProvider.currentStep!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
