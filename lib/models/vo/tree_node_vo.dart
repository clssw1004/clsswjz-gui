class TreeNode<T> {
  final T data;
  final List<TreeNode<T>> children;
  final int level;

  bool get isLeaf => children.isEmpty;
  bool get isRoot => level == 0;

  const TreeNode({
    required this.data,
    this.children = const [],
    this.level = 0,
  });

  TreeNode<T> copyWith({
    T? data,
    List<TreeNode<T>>? children,
    int? level,
  }) {
    return TreeNode<T>(
      data: data ?? this.data,
      children: children ?? this.children,
      level: level ?? this.level,
    );
  }
}

/// Tree building utility
class TreeBuilder {
  /// Build tree from flat list with parent-child relationship
  /// [getLastUsedAt] optional, enables recent-use sorting — propagates
  /// descendant timestamps up so recently-used branches float to top.
  static List<TreeNode<T>> buildTree<T>(
    List<T> items, {
    required String Function(T) getId,
    required String? Function(T) getParentId,
    Comparable? Function(T)? getLastUsedAt,
  }) {
    final childrenMap = <String?, List<T>>{};
    for (final item in items) {
      final pid = getParentId(item);
      childrenMap.putIfAbsent(pid, () => []).add(item);
    }
    final result = _buildNodes<T>(null, childrenMap, 0, getId);
    if (getLastUsedAt != null) {
      sortByRecentUse(result, getLastUsedAt);
    }
    return result;
  }

  static List<TreeNode<T>> _buildNodes<T>(
    String? parentId,
    Map<String?, List<T>> childrenMap,
    int level,
    String Function(T) getId,
  ) {
    final children = childrenMap[parentId] ?? [];
    return children.map((item) {
      return TreeNode<T>(
        data: item,
        level: level,
        children: _buildNodes<T>(getId(item), childrenMap, level + 1, getId),
      );
    }).toList();
  }

  /// Flatten tree to list (DFS pre-order).
  /// If [isExpanded] provided, only include children of expanded nodes.
  static List<TreeNode<T>> flatten<T>(
    List<TreeNode<T>> roots, {
    bool Function(TreeNode<T> node)? isExpanded,
  }) {
    final result = <TreeNode<T>>[];
    for (final root in roots) {
      _flattenNode(root, result, isExpanded: isExpanded);
    }
    return result;
  }

  static void _flattenNode<T>(
    TreeNode<T> node,
    List<TreeNode<T>> result, {
    bool Function(TreeNode<T> node)? isExpanded,
  }) {
    result.add(node);
    if (isExpanded != null && !isExpanded(node)) return;
    for (final child in node.children) {
      _flattenNode(child, result, isExpanded: isExpanded);
    }
  }

  /// Get all descendant IDs of a node with given ID
  /// Returns [foundId] + all descendant IDs
  static List<String> getDescendantIds<T>(
    List<TreeNode<T>> roots,
    String targetId, {
    required String Function(T) idGetter,
    bool includeSelf = true,
  }) {
    for (final root in roots) {
      final result = _findDescendantIds(root, targetId, idGetter);
      if (result != null) {
        if (!includeSelf) {
          result.removeAt(0);
        }
        return result;
      }
    }
    return includeSelf ? [targetId] : [];
  }

  static List<String>? _findDescendantIds<T>(
    TreeNode<T> node,
    String targetId,
    String Function(T) idGetter,
  ) {
    if (idGetter(node.data) == targetId) {
      final result = [targetId];
      for (final child in node.children) {
        result.addAll(_collectAllIds(child, idGetter));
      }
      return result;
    }
    for (final child in node.children) {
      final result = _findDescendantIds(child, targetId, idGetter);
      if (result != null) return result;
    }
    return null;
  }

  static List<String> _collectAllIds<T>(
    TreeNode<T> node,
    String Function(T) idGetter,
  ) {
    final result = [idGetter(node.data)];
    for (final child in node.children) {
      result.addAll(_collectAllIds(child, idGetter));
    }
    return result;
  }

  /// Sort tree by recent use — propagate descendant timestamps up so
  /// recently-used branches appear first. Nulls sort last.
  static void sortByRecentUse<T>(
    List<TreeNode<T>> nodes,
    Comparable? Function(T) getTime,
  ) {
    final effective = <TreeNode<T>, Comparable?>{};

    Comparable? _compute(TreeNode<T> node) {
      Comparable? best = getTime(node.data);
      for (final child in node.children) {
        final childBest = _compute(child);
        if (childBest != null &&
            (best == null || childBest.compareTo(best) > 0)) {
          best = childBest;
        }
      }
      effective[node] = best;
      return best;
    }

    void _sortLevel(TreeNode<T> node) {
      node.children.sort((a, b) {
        final aT = effective[a];
        final bT = effective[b];
        if (aT == null && bT == null) return 0;
        if (aT == null) return 1;
        if (bT == null) return -1;
        return bT.compareTo(aT);
      });
      for (final child in node.children) {
        _sortLevel(child);
      }
    }

    // Pass 1: compute effective time bottom-up
    for (final node in nodes) {
      _compute(node);
    }

    // Pass 2: sort children at each level
    for (final node in nodes) {
      _sortLevel(node);
    }

    // Sort roots
    nodes.sort((a, b) {
      final aT = effective[a];
      final bT = effective[b];
      if (aT == null && bT == null) return 0;
      if (aT == null) return 1;
      if (bT == null) return -1;
      return bT.compareTo(aT);
    });
  }
}
