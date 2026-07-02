import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../manager/l10n_manager.dart';
import '../../../models/vo/tree_node_vo.dart';
import '../../../theme/theme_radius.dart';
import 'tree_select_item.dart';

part 'tree_select_multi_bar.dart';
part 'tree_select_create_tile.dart';
part 'tree_select_layout.dart';

/// 视图模式
enum _ViewMode { tree, recent, recommend }

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
  final Map<String, double>? scores;

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
    this.scores,
  });

  @override
  State<TreeSelectSheet<T>> createState() => _TreeSelectSheetState<T>();
}

class _TreeSelectSheetState<T> extends State<TreeSelectSheet<T>> {
  final Set<String> _expandedIds = {};
  final Set<String> _selectedIds = {};
  String _searchQuery = '';
  bool _createLoading = false;
  _ViewMode _viewMode = _ViewMode.tree;
  List<TreeNode<T>>? _cachedRecentNodes;
  List<TreeNode<T>>? _cachedRecommendNodes;

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

  bool get _hasScoreData =>
      widget.scores != null && widget.scores!.isNotEmpty;

  // 最近使用列表：flat + sort + top20，缓存
  List<TreeNode<T>> get _recentNodes {
    if (_cachedRecentNodes == null) {
      final all = TreeBuilder.flatten(widget.filtered);
      // 不可选节点不展示
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

  // 推荐列表：按智能评分排序，top20
  List<TreeNode<T>> get _recommendNodes {
    if (_cachedRecommendNodes == null) {
      final scores = widget.scores;
      if (scores == null || scores.isEmpty) return [];
      final all = TreeBuilder.flatten(widget.filtered);
      // 不可选节点不展示
      if (widget.isSelectableCheck != null) {
        all.removeWhere((n) => !widget.isSelectableCheck!(n.data));
      }
      final scored = all.where((n) {
        final s = scores[widget.idField(n.data)];
        return s != null && s > 0;
      }).toList();
      scored.sort((a, b) {
        final sa = scores[widget.idField(a.data)] ?? 0;
        final sb = scores[widget.idField(b.data)] ?? 0;
        return sb.compareTo(sa);
      });
      _cachedRecommendNodes = scored.take(20).toList();
    }
    return _cachedRecommendNodes!;
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

    // 有评分数据时默认智能推荐视图
    if (_hasScoreData) {
      _viewMode = _ViewMode.recommend;
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
    // 搜索时统一全量搜索（不限当前视图）
    if (_searchQuery.isNotEmpty) {
      final all = TreeBuilder.flatten(widget.filtered);
      final query = _searchQuery.toLowerCase();
      if (_viewMode == _ViewMode.tree) {
        // 树形模式保留祖先节点
        final keepIds = <String>{};
        for (final node in all) {
          if (widget.displayField(node.data)
              .toLowerCase().contains(query)) {
            keepIds.add(widget.idField(node.data));
          }
        }
        final nodesToKeep = <TreeNode<T>>[];
        for (final node in all) {
          if (_nodeOrDescendantMatches(node, keepIds)) {
            nodesToKeep.add(node);
          }
        }
        return nodesToKeep;
      }
      // 扁平模式直接返回匹配项
      return all.where((n) =>
          widget.displayField(n.data).toLowerCase().contains(query)).toList();
    }

    if (_viewMode == _ViewMode.recent) {
      return _recentNodes;
    }

    if (_viewMode == _ViewMode.recommend) {
      return _recommendNodes;
    }

    // tree mode
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

    return collectVisible(widget.filtered);
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
    final isFlat = _viewMode != _ViewMode.tree;

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
          level: isFlat ? 0 : visible[i].level,
          id: widget.idField(visible[i].data),
          isChecked: _isChecked(widget.idField(visible[i].data)),
          isMulti: widget.multiSelect,
          displayText: widget.displayField(visible[i].data),
          branchColor: branchColor(cs, isFlat ? 0 : visible[i].level),
          hasChildren: isFlat ? false : visible[i].children.isNotEmpty,
          isExpanded: isFlat ? false : _expandedIds.contains(widget.idField(visible[i].data)),
          selectable: widget.isSelectableCheck != null
              ? widget.isSelectableCheck!(visible[i].data)
              : true,
          onTap: () => _onTapNode(visible[i]),
          onToggleExpand: isFlat || visible[i].children.isEmpty
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
      viewMode: _viewMode,
      onViewModeChanged: (mode) => setState(() {
        _viewMode = mode;
        _cachedRecentNodes = null;
        _cachedRecommendNodes = null;
      }),
      showViewToggle: _hasRecentData || _hasScoreData,
      showScoreToggle: _hasScoreData,
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
