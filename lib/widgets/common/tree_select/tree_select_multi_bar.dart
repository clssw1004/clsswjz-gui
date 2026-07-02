part of 'tree_select_sheet.dart';

/// 多选底部按钮栏
class _MultiBottomBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _MultiBottomBar({
    required this.selectedCount,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outline.withAlpha(20))),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: onCancel,
                child: Text(L10nManager.l10n.cancel),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: onConfirm,
                style: FilledButton.styleFrom(
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      (Theme.of(context)
                              .extension<ThemeRadius>()
                              ?.radius ??
                          12) *
                          1.8,
                    ),
                  ),
                ),
                child: Text(
                  L10nManager.l10n.treeSelectedCount(selectedCount),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
