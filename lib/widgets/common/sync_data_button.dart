import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../manager/l10n_manager.dart';
import '../../providers/sync_provider.dart';

class SyncDataButton extends StatelessWidget {
  const SyncDataButton({super.key});

  @override
  Widget build(BuildContext context) {
    final syncProvider = context.watch<SyncProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  L10nManager.l10n.syncSettings,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                if (syncProvider.currentStep != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    syncProvider.currentStep!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: syncProvider.progress,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                      minHeight: 4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => Navigator.pushNamed(context, '/sync_settings'),
                icon: Icon(
                  Icons.settings_outlined,
                  color: colorScheme.primary,
                ),
              ),
              IconButton.filledTonal(
                onPressed: syncProvider.syncing
                    ? null
                    : () async {
                        await syncProvider.syncData();
                      },
                icon: syncProvider.syncing
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onSecondaryContainer,
                        ),
                      )
                    : const Icon(Icons.sync),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
