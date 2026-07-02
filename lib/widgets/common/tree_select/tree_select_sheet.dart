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
  final bool allowCreate;
  final Future<T?> Function(String value)? onCreateItem;
  final void Function(T data)? onNodeTap;
  final bool noShell;
  final bool Function(T data)? isSelectableCheck;

  const TreeSelectSheet({
    super.key,
    required this.filtered,
    required this.displayField,
    required this.idField,
    required this.multiSelect,
    this.label,
    this.initialValue,
    this.allowCreate = false,
    this.onCreateItem,
    this.onNodeTap,
    this.noShell = false,
    this.isSelectableCheck,
  });

  @override
  State<TreeSelectSheet<T>> createState() => _TreeSelectSheetState<T>();
}

class _TreeSelectSheetState<T> extends State<TreeSelectSheet<T>> {
  final Set<String> _expandedIds = {};
  final Set<String> _selectedIds = {};
  String _searchQuery = '';
  bool _createLoading = false;
  bool _recentMode = false;
  List<TreeNode<T>>? _cachedRecentNodes;

  String? _currentSingleId;

  // duck-typing 获取最近使用时间
  Comparable? _lastUsedTime(T data) {
    try {
      return (data as dynamic).lastAccountItemAt as Comparable?;
    } catch (_) {
      return null;
    }
  }

  // 检查树中是否存在时间数据
  bool _subtreeHasTime(TreeNode<T> node) {
    if (_lastUsedTime(node.data) != null) return true;
    for (final child in node.children) {
      if (_subtreeHasTime(child)) return true;
    }
    return false;
  }

  bool get _hasRecentData =>
      widget.filtered.any((n) => _subtreeHasTime(n));

  // 最近使用列表：flat + sort + top20，缓存
  List<TreeNode<T>> get _recentNodes {
    if (_cachedRecentNodes == null) {
      final all = TreeBuilder.flatten(widget.filtered);
      // 不可选节点不展示在最近使用中
      if (widget.isSelectableCheck != null) {
        all.removeWhere((n) => !widget.isSelectableCheck!(n.data));
      }
      all.sort((a, b) {
        final aT = _lastUsedTime(a.data);
        final bT = _lastUsedTime(b.data);
        if (aT == null && bT == null) return 0;
        if (aT == null) return 1;
        if (bT == null) return -1;
        return bT.compareTo(aT);
      });
      _cachedRecentNodes = all.take(20).toList();
    }
    return _cachedRecentNodes!;
  }

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
    if (_recentMode) {
      var nodes = _recentNodes;
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        nodes = nodes.where((n) =>
            widget.displayField(n.data).toLowerCase().contains(query)).toList();
      }
      return nodes;
    }

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
    // 自定义回调 → 委托外部
    if (widget.onNodeTap != null) {
      widget.onNodeTap!(node.data);
      return;
    }

    // 不可选节点 → 仅展开
    if (widget.isSelectableCheck != null && !widget.isSelectableCheck!(node.data)) {
      if (node.children.isNotEmpty) _onToggleExpand(node);
      return;
    }

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

  Widget _buildEmptyOrCreate(ColorScheme cs) {
    if (_searchQuery.isNotEmpty && widget.allowCreate) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 12, 16),
        children: [
          _TreeCreateTile<T>(
            searchText: _searchQuery,
            label: widget.label ?? '',
            loading: _createLoading,
            onCreate: () async {
              if (widget.onCreateItem == null) return;
              setState(() => _createLoading = true);
              final result = await widget.onCreateItem!(_searchQuery);
              setState(() => _createLoading = false);
              if (result != null && mounted) {
                Navigator.of(context).pop(result);
              }
            },
          ),
        ],
      );
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 40,
              color: cs.onSurfaceVariant.withAlpha(60)),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty ? L10nManager.l10n.noData : L10nManager.l10n.treeNoOptions,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant.withAlpha(100),
                )),
        ],
      ),
    );
  }

  ListView _buildListView(ColorScheme cs, List<TreeNode<T>> visible) {
    // 搜索：是否有完全匹配项
    final hasExactMatch = _searchQuery.isNotEmpty &&
        TreeBuilder.flatten(widget.filtered).any(
            (n) => widget.displayField(n.data).toLowerCase() == _searchQuery.toLowerCase());
    final showCreate = _searchQuery.isNotEmpty &&
        widget.allowCreate && !hasExactMatch && !_createLoading;

    final items = <Widget>[
      if (showCreate)
        _TreeCreateTile<T>(
          searchText: _searchQuery,
          label: widget.label ?? '',
          loading: _createLoading,
          onCreate: () async {
            if (widget.onCreateItem == null) return;
            setState(() => _createLoading = true);
            final result = await widget.onCreateItem!(_searchQuery);
            setState(() => _createLoading = false);
            if (result != null && mounted) {
              Navigator.of(context).pop(result);
            }
          },
        ),
      for (int i = 0; i < visible.length; i++)
        TreeSelectItem<T>(
          key: ValueKey(widget.idField(visible[i].data)),
          level: _recentMode ? 0 : visible[i].level,
          id: widget.idField(visible[i].data),
          isChecked: _isChecked(widget.idField(visible[i].data)),
          isMulti: widget.multiSelect,
          displayText: widget.displayField(visible[i].data),
          branchColor: branchColor(cs, _recentMode ? 0 : visible[i].level),
          hasChildren: _recentMode ? false : visible[i].children.isNotEmpty,
          isExpanded: _recentMode ? false : _expandedIds.contains(widget.idField(visible[i].data)),
          selectable: widget.isSelectableCheck != null
              ? widget.isSelectableCheck!(visible[i].data)
              : true,
          onTap: () => _onTapNode(visible[i]),
          onToggleExpand: _recentMode || visible[i].children.isEmpty
              ? null
              : () => _onToggleExpand(visible[i]),
        ),
    ];

    return ListView(
      padding: widget.multiSelect
          ? const EdgeInsets.fromLTRB(16, 4, 12, 80)
          : const EdgeInsets.fromLTRB(16, 4, 12, 16),
      children: items,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final visible = _visibleNodes;

    if (widget.noShell) {
      // 无外壳模式：仅返回内容，外壳由外部提供
      return Expanded(
        child: visible.isEmpty
            ? _buildEmptyOrCreate(cs)
            : _buildListView(cs, visible),
      );
    }

    return _TreeSheetLayout(
      label: widget.label,
      multiSelect: widget.multiSelect,
      searchQuery: _searchQuery,
      onSearchChanged: (v) => setState(() => _searchQuery = v),
      recentMode: _recentMode,
      onToggleView: (recent) => setState(() {
        _recentMode = recent;
        _cachedRecentNodes = null;
      }),
      showViewToggle: _hasRecentData,
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
              ? _buildEmptyOrCreate(cs)
              : _buildListView(cs, visible),
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
  final bool recentMode;
  final ValueChanged<bool> onToggleView;
  final bool showViewToggle;

  const _TreeSheetLayout({
    required this.label,
    required this.multiSelect,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.child,
    this.bottomBar,
    this.recentMode = false,
    required this.onToggleView,
    this.showViewToggle = false,
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

  Widget _buildViewChip(BuildContext context, String label, bool selected, VoidCallback onTap) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? cs.primary.withAlpha(20) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? cs.primary.withAlpha(80) : cs.outlineVariant.withAlpha(80),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? cs.primary : cs.onSurfaceVariant,
          ),
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
                  _buildViewChip(context, L10nManager.l10n.treeView, !widget.recentMode, () => widget.onToggleView(false)),
                  const SizedBox(width: 8),
                  _buildViewChip(context, L10nManager.l10n.recentUse, widget.recentMode, () => widget.onToggleView(true)),
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

/// 树形搜索新建项 — 整行可点击创建
class _TreeCreateTile<T> extends StatelessWidget {
  final String searchText;
  final String label;
  final bool loading;
  final VoidCallback onCreate;

  const _TreeCreateTile({
    required this.searchText,
    required this.label,
    required this.loading,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: loading ? null : onCreate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: colorScheme.primary.withAlpha(6),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: loading
                      ? SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.primary,
                          ),
                        )
                      : Icon(Icons.add_rounded, size: 22, color: colorScheme.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    L10nManager.l10n.addNew(searchText),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
