import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../manager/l10n_manager.dart';
import '../../../models/vo/tree_node_vo.dart';
import '../../../theme/theme_radius.dart';
import 'tree_select_item.dart';

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

/// 层级颜色映射（用于分支线 + 选中色条）
Color branchColor(ColorScheme cs, int level) {
  switch (level.clamp(0, 4)) {
    case 0:
      return cs.primary;
    case 1:
      return cs.tertiary;
    case 2:
      return cs.secondary;
    case 3:
      return cs.primary.withAlpha(160);
    case 4:
      return cs.tertiary.withAlpha(160);
    default:
      return cs.primary.withAlpha(140);
  }
}

/// 树形选择 BottomSheet — 单选/多选共用容器
class TreeSelectSheet<T> extends StatefulWidget {
  final List<TreeNode<T>> filtered;
  final String Function(T) displayField;
  final String Function(T) idField;
  final bool multiSelect;
  final String? label;
  final dynamic initialValue;

  const TreeSelectSheet({
    super.key,
    required this.filtered,
    required this.displayField,
    required this.idField,
    required this.multiSelect,
    this.label,
    this.initialValue,
  });

  @override
  State<TreeSelectSheet<T>> createState() => _TreeSelectSheetState<T>();
}

class _TreeSelectSheetState<T> extends State<TreeSelectSheet<T>> {
  final Set<String> _expandedIds = {};
  final Set<String> _selectedIds = {};
  String _searchQuery = '';

  String? _currentSingleId;

  @override
  void initState() {
    super.initState();

    // 初始化选中状态
    if (widget.multiSelect) {
      if (widget.initialValue is List) {
        _selectedIds.addAll(
            List<String>.from(widget.initialValue as List));
      }
    } else {
      if (widget.initialValue is T) {
        _currentSingleId = widget.idField(widget.initialValue as T);
      } else if (widget.initialValue is String) {
        _currentSingleId = widget.initialValue as String;
      }
    }

    // 默认全部展开
    _expandAll(widget.filtered);
  }

  void _expandAll(List<TreeNode<T>> nodes) {
    for (final node in nodes) {
      if (node.children.isNotEmpty) {
        _expandedIds.add(widget.idField(node.data));
        _expandAll(node.children);
      }
    }
  }

  List<TreeNode<T>> get _visibleNodes {
    List<TreeNode<T>> collectVisible(List<TreeNode<T>> nodes) {
      final result = <TreeNode<T>>[];
      for (final node in nodes) {
        result.add(node);
        if (node.children.isNotEmpty &&
            _expandedIds.contains(widget.idField(node.data))) {
          result.addAll(collectVisible(node.children));
        }
      }
      return result;
    }

    var nodes = collectVisible(widget.filtered);

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      // 收集所有匹配节点和它们的祖先节点ID
      final keepIds = <String>{};
      for (final node in nodes) {
        if (widget.displayField(node.data).toLowerCase().contains(query)) {
          keepIds.add(widget.idField(node.data));
        }
      }
      // 也保留哪些后代有匹配的节点（祖先节点）
      final nodesToKeep = <TreeNode<T>>[];
      for (final node in nodes) {
        if (_nodeOrDescendantMatches(node, keepIds)) {
          nodesToKeep.add(node);
        }
      }
      nodes = nodesToKeep;
    }

    return nodes;
  }

  bool _nodeOrDescendantMatches(
      TreeNode<T> node, Set<String> keepIds) {
    if (keepIds.contains(widget.idField(node.data))) return true;
    for (final child in node.children) {
      if (_nodeOrDescendantMatches(child, keepIds)) return true;
    }
    return false;
  }

  void _onTapNode(TreeNode<T> node) {
    final id = widget.idField(node.data);

    // 点击行 → 选中（单选 pop，多选 toggle）
    if (widget.multiSelect) {
      setState(() {
        if (_selectedIds.contains(id)) {
          _selectedIds.remove(id);
          _deselectDescendants(node);
        } else {
          _selectedIds.add(id);
          _selectDescendants(node);
        }
      });
    } else {
      Navigator.of(context).pop(node.data);
    }
  }

  void _onToggleExpand(TreeNode<T> node) {
    final id = widget.idField(node.data);
    HapticFeedback.selectionClick();
    setState(() {
      if (_expandedIds.contains(id)) {
        _expandedIds.remove(id);
      } else {
        _expandedIds.add(id);
      }
    });
  }

  void _selectDescendants(TreeNode<T> node) {
    for (final child in node.children) {
      _selectedIds.add(widget.idField(child.data));
      _selectDescendants(child);
    }
  }

  void _deselectDescendants(TreeNode<T> node) {
    for (final child in node.children) {
      _selectedIds.remove(widget.idField(child.data));
      _deselectDescendants(child);
    }
  }

  bool _isChecked(String id) {
    if (widget.multiSelect) {
      return _selectedIds.contains(id);
    }
    return id == _currentSingleId;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final visible = _visibleNodes;

    return _TreeSheetLayout(
      label: widget.label,
      multiSelect: widget.multiSelect,
      searchQuery: _searchQuery,
      onSearchChanged: (v) => setState(() => _searchQuery = v),
      bottomBar: widget.multiSelect
          ? _MultiBottomBar(
              selectedCount: _selectedIds.length,
              onCancel: () => Navigator.of(context).pop(),
              onConfirm: () =>
                  Navigator.of(context).pop(_selectedIds.toList()),
            )
          : null,
      child: Expanded(
        child: visible.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_outlined,
                            size: 40,
                            color: cs.onSurfaceVariant.withAlpha(60)),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty
                              ? L10nManager.l10n.noData
                              : L10nManager.l10n.treeNoOptions,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: cs.onSurfaceVariant.withAlpha(100),
                              ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: widget.multiSelect
                      ? const EdgeInsets.fromLTRB(16, 4, 12, 80)
                      : const EdgeInsets.fromLTRB(16, 4, 12, 16),
                  children: List.generate(visible.length, (i) {
                    final node = visible[i];
                    final id = widget.idField(node.data);
                    return TreeSelectItem<T>(
                      key: ValueKey(id),
                      level: node.level,
                      id: id,
                      isChecked: _isChecked(id),
                      isMulti: widget.multiSelect,
                      displayText: widget.displayField(node.data),
                      branchColor: branchColor(cs, node.level),
                      hasChildren: node.children.isNotEmpty,
                      isExpanded: _expandedIds.contains(id),
                      onTap: () => _onTapNode(node),
                      onToggleExpand: node.children.isNotEmpty
                          ? () => _onToggleExpand(node)
                          : null,
                    );
                  }),
                ),
      ),
    );
  }
}

/// 树形选择 BottomSheet 布局 — 搜索集成在标题栏
class _TreeSheetLayout extends StatefulWidget {
  final String? label;
  final bool multiSelect;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final Widget child;
  final Widget? bottomBar;

  const _TreeSheetLayout({
    required this.label,
    required this.multiSelect,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.child,
    this.bottomBar,
  });

  @override
  State<_TreeSheetLayout> createState() => _TreeSheetLayoutState();
}

class _TreeSheetLayoutState extends State<_TreeSheetLayout>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _searchCtrl;
  late final AnimationController _animCtrl;
  bool _searchOpen = false;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searchOpen = !_searchOpen;
      if (_searchOpen) {
        _animCtrl.forward();
      } else {
        _animCtrl.reverse();
        _searchCtrl.clear();
        widget.onSearchChanged('');
      }
    });
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
          // 标题行（含搜索按钮）
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
                // 搜索展开按钮
                IconButton(
                  icon: Icon(
                    _searchOpen ? Icons.close_rounded : Icons.search_rounded,
                    size: 22,
                  ),
                  color: cs.onSurfaceVariant,
                  onPressed: _toggleSearch,
                  visualDensity: VisualDensity.compact,
                  tooltip: L10nManager.l10n.search,
                ),
              ],
            ),
          ),
          // 搜索输入框（展开动画）
          if (_searchOpen)
            SizeTransition(
              sizeFactor: _animCtrl,
              axisAlignment: 1.0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: TextField(
                  controller: _searchCtrl,
                  autofocus: true,
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: L10nManager.l10n.search,
                    isDense: true,
                    filled: true,
                    fillColor: cs.surfaceContainerHighest.withAlpha(60),
                    prefixIcon: Icon(Icons.search_rounded,
                        size: 20, color: cs.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                  onChanged: widget.onSearchChanged,
                ),
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
