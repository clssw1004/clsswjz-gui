part of 'tree_select_sheet.dart';

/// 树形选择 BottomSheet 布局 — 标题栏 + 搜索框 + 视图切换
class _TreeSheetLayout extends StatefulWidget {
  final String? label;
  final bool multiSelect;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final Widget child;
  final Widget? bottomBar;
  final _ViewMode viewMode;
  final ValueChanged<_ViewMode> onViewModeChanged;
  final bool showViewToggle;
  final bool showScoreToggle;

  const _TreeSheetLayout({
    required this.label,
    required this.multiSelect,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.child,
    this.bottomBar,
    this.viewMode = _ViewMode.tree,
    required this.onViewModeChanged,
    this.showViewToggle = false,
    this.showScoreToggle = false,
  });

  @override
  State<_TreeSheetLayout> createState() => _TreeSheetLayoutState();
}

class _TreeSheetLayoutState extends State<_TreeSheetLayout> {
  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Widget _buildTab(BuildContext context, String label, IconData icon, bool selected, VoidCallback onTap) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? cs.primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? cs.primary : cs.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? cs.primary : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final radius = theme.extension<ThemeRadius>()?.radius ?? 12;
    final screenH = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenH * 0.8,
        minHeight: 300,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(radius * 1.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽手柄
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 2),
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withAlpha(50),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // 标题行
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 8, 4),
            child: Row(
              children: [
                Icon(Icons.account_tree_outlined,
                    size: 18, color: cs.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.label ?? L10nManager.l10n.pleaseSelect(''),
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                if (widget.multiSelect)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      L10nManager.l10n.treeMultiSelectHint,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // 搜索输入框（常驻）
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: L10nManager.l10n.search,
                hintStyle: TextStyle(color: cs.onSurfaceVariant.withAlpha(100)),
                isDense: true,
                filled: true,
                fillColor: cs.surfaceContainerHighest.withAlpha(60),
                prefixIcon: Icon(Icons.search_rounded,
                    size: 20, color: cs.onSurfaceVariant),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close_rounded, size: 18,
                            color: cs.onSurfaceVariant),
                        onPressed: () {
                          _searchCtrl.clear();
                          widget.onSearchChanged('');
                        },
                        visualDensity: VisualDensity.compact,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
              ),
              onChanged: (v) {
                widget.onSearchChanged(v);
                setState(() {});
              },
            ),
          ),
          // 视图切换
          if (widget.showViewToggle)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 2),
              child: Row(
                children: [
                  if (widget.showScoreToggle)
                    Padding(
                      padding: const EdgeInsets.only(right: 24),
                      child: _buildTab(context,
                          L10nManager.l10n.smartSort, Icons.auto_awesome,
                          widget.viewMode == _ViewMode.recommend,
                          () => widget.onViewModeChanged(_ViewMode.recommend)),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(right: 24),
                    child: _buildTab(context,
                        L10nManager.l10n.recentUse, Icons.history,
                        widget.viewMode == _ViewMode.recent,
                        () => widget.onViewModeChanged(_ViewMode.recent)),
                  ),
                  _buildTab(context,
                      L10nManager.l10n.treeView, Icons.account_tree_outlined,
                      widget.viewMode == _ViewMode.tree,
                      () => widget.onViewModeChanged(_ViewMode.tree)),
                ],
              ),
            ),
          Divider(height: 1, color: cs.outline.withAlpha(20)),
          widget.child,
          if (widget.bottomBar != null) widget.bottomBar!,
        ],
      ),
    );
  }
}
