import 'package:flutter/material.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/tree_node_vo.dart';
import '../../theme/theme_radius.dart';

/// 树形选择器（BottomSheet 展示树状连线层级），支持单选/多选
class TreeSelectFormField<T> extends FormField<dynamic> {
  final bool multiSelect;

  TreeSelectFormField({
    super.key,
    required List<TreeNode<T>> roots,
    dynamic value,
    required String Function(T) displayField,
    required String Function(T) idField,
    Set<String>? excludeIds,
    String? label,
    String? hint,
    this.multiSelect = false,
    ValueChanged<dynamic>? onChanged,
    super.validator,
  }) : super(
          initialValue: multiSelect
              ? (value is List ? List<String>.from(value) : <String>[])
              : value,
          builder: (state) {
            return _TreeSelectWidget<T>(
              roots: roots,
              value: multiSelect
                  ? (state.value is List
                      ? List<String>.from(state.value)
                      : <String>[])
                  : state.value,
              displayField: displayField,
              idField: idField,
              excludeIds: excludeIds ?? {},
              label: label,
              hint: hint,
              errorText: state.errorText,
              multiSelect: multiSelect,
              onChanged: (v) {
                state.didChange(v);
                if (onChanged != null) onChanged(v);
              },
            );
          },
        );
}

class _TreeSelectWidget<T> extends StatefulWidget {
  final List<TreeNode<T>> roots;
  final dynamic value;
  final String Function(T) displayField;
  final String Function(T) idField;
  final Set<String> excludeIds;
  final String? label;
  final String? hint;
  final String? errorText;
  final bool multiSelect;
  final ValueChanged<dynamic>? onChanged;

  const _TreeSelectWidget({
    required this.roots,
    this.value,
    required this.displayField,
    required this.idField,
    this.excludeIds = const {},
    this.label,
    this.hint,
    this.errorText,
    this.multiSelect = false,
    this.onChanged,
  });

  @override
  State<_TreeSelectWidget<T>> createState() => _TreeSelectWidgetState<T>();
}

class _TreeSelectWidgetState<T> extends State<_TreeSelectWidget<T>> {
  Set<String> _tempSelected = {};

  static const _indentStep = 20.0;
  static final _dotColors = <int, Color Function(ColorScheme)>{
    0: (c) => c.primary,
    1: (c) => c.tertiary,
    2: (c) => c.secondary,
    3: (c) => c.primary.withValues(alpha: 0.55),
    4: (c) => c.tertiary.withValues(alpha: 0.55),
  };

  String get _displayText {
    if (widget.multiSelect) {
      final ids = (widget.value is List
          ? List<String>.from(widget.value)
          : <String>[]);
      if (ids.isEmpty) return widget.hint ?? L10nManager.l10n.pleaseSelect('');
      return L10nManager.l10n.treeSelectedCount(ids.length);
    }
    if (widget.value == null) return widget.hint ?? L10nManager.l10n.pleaseSelect('');
    return widget.displayField(widget.value as T);
  }

  Color _dotColor(ColorScheme cs, int level) =>
      _dotColors[level.clamp(0, 4)]?.call(cs) ?? cs.primary.withValues(alpha: 0.5);

  /// 计算每个 flatten 节点的祖先 isLast 状态，用于画连线
  List<List<bool>> _computeAncestorLast(List<TreeNode<T>> nodes) {
    final ancestors = <_LevelLast>{};
    return nodes.map((n) {
      ancestors.removeWhere((a) => a.level >= n.level);
      ancestors.add(_LevelLast(level: n.level, isLast: false));
      return List<bool>.unmodifiable(
        ancestors.where((a) => a.level < n.level).map((a) => a.isLast).toList(),
      );
    }).toList();
  }

  /// 打完 flatten 后标记每个节点是否为父级的最后一个子节点
  List<bool> _markLast(List<TreeNode<T>> nodes) {
    final result = List<bool>.filled(nodes.length, false);
    for (int i = 0; i < nodes.length; i++) {
      final nextIdx = i + 1;
      if (nextIdx >= nodes.length || nodes[nextIdx].level <= nodes[i].level) {
        result[i] = true;
      }
    }
    // 回填 ancestors
    final ancestors = <_LevelLast>{};
    for (int i = 0; i < nodes.length; i++) {
      final n = nodes[i];
      ancestors.removeWhere((a) => a.level >= n.level);
      ancestors.add(_LevelLast(level: n.level, isLast: result[i]));
    }
    return result;
  }

  Future<void> _showPicker() async {
    final radius = Theme.of(context).extension<ThemeRadius>()?.radius ?? 12;
    final screenH = MediaQuery.of(context).size.height;

    final allNodes = TreeBuilder.flatten(widget.roots);
    final filtered = allNodes
        .where((n) => !widget.excludeIds.contains(widget.idField(n.data)))
        .toList();

    if (widget.multiSelect) {
      _tempSelected = Set<String>.from(
        widget.value is List ? List<String>.from(widget.value) : <String>[],
      );
      await _showMultiPicker(radius, screenH, filtered);
    } else {
      final result = await _showSinglePicker(radius, screenH, filtered);
      if (result != null && mounted) {
        widget.onChanged?.call(result);
      }
    }
  }

  Future<T?> _showSinglePicker(
      double radius, double screenH, List<TreeNode<T>> filtered) async {
    final localColor = Theme.of(context).colorScheme;
    final localRadius = Theme.of(context).extension<ThemeRadius>()?.radius ?? 12;
    final isLastList = _markLast(filtered);
    final ancestorLast = _computeAncestorLast(filtered);

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius * 1.5)),
      ),
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: screenH * 0.8, minHeight: 300),
        decoration: BoxDecoration(
          color: localColor.surface,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(localRadius * 1.5)),
        ),
        child: _buildSheetContent(ctx, filtered, isLastList, ancestorLast),
      ),
    );
  }

  Future<void> _showMultiPicker(
      double radius, double screenH, List<TreeNode<T>> filtered) async {
    final localColor = Theme.of(context).colorScheme;
    final isLastList = _markLast(filtered);
    // 为多选重新计算 ancestorLast（isLast 需要实时更新）
    final List<List<bool>> ancestorLast = [];
    final ancestors = <_LevelLast>{};
    for (int i = 0; i < filtered.length; i++) {
      final n = filtered[i];
      ancestors.removeWhere((a) => a.level >= n.level);
      ancestors.add(_LevelLast(level: n.level, isLast: isLastList[i]));
      ancestorLast.add(List<bool>.unmodifiable(
        ancestors.where((a) => a.level < n.level).map((a) => a.isLast).toList(),
      ));
    }

    await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius * 1.5)),
      ),
      builder: (ctx) {
        final lc = Theme.of(ctx).colorScheme;
        final lr = Theme.of(ctx).extension<ThemeRadius>()?.radius ?? 12;
        return StatefulBuilder(
          builder: (ctx, setLocalState) {
            return Container(
              constraints:
                  BoxConstraints(maxHeight: screenH * 0.8, minHeight: 300),
              decoration: BoxDecoration(
                color: lc.surface,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(lr * 1.5)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(ctx, lc),
                  Divider(height: 1, color: lc.outline.withAlpha(20)),
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(child: Text(L10nManager.l10n.treeNoOptions))
                        : ListView(
                            padding:
                                const EdgeInsets.only(top: 4, bottom: 80),
                            children: List.generate(filtered.length, (i) {
                              final node = filtered[i];
                              final id = widget.idField(node.data);
                              final checked = _tempSelected.contains(id);
                              final dots =
                                  ancestorLast.isNotEmpty ? ancestorLast[i] : <bool>[];
                              return _buildMultiItem(
                                ctx, node, id, checked, dots, isLastList[i],
                                setLocalState,
                              );
                            }),
                          ),
                  ),
                  _buildBottomBar(ctx),
                ],
              ),
            );
          },
        );
      },
    ).then((result) {
      if (result != null && mounted) {
        widget.onChanged?.call(result.toList());
      }
    });
  }

  // ─── Single-select item ───────────────────────────────────────

  Widget _buildSheetContent(
    BuildContext ctx,
    List<TreeNode<T>> filtered,
    List<bool> isLastList,
    List<List<bool>> ancestorLast,
  ) {
    final localColor = Theme.of(ctx).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(ctx, localColor),
        Divider(height: 1, color: localColor.outline.withAlpha(20)),
        if (filtered.isEmpty)
          Expanded(child: Center(child: Text(L10nManager.l10n.treeNoOptions)))
        else
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 4, bottom: 16),
              children: List.generate(filtered.length, (i) {
                final node = filtered[i];
                final isSelected = widget.value != null &&
                    widget.idField(node.data) ==
                        widget.idField(widget.value as T);
                return _buildSingleItem(
                  ctx, node, isSelected, ancestorLast[i], isLastList[i],
                );
              }),
            ),
          ),
      ],
    );
  }

  // ─── Single item ───────────────────────────────────────────────

  Widget _buildSingleItem(
    BuildContext ctx,
    TreeNode<T> node,
    bool isSelected,
    List<bool> ancestorLast,
    bool isLast,
  ) {
    final cs = Theme.of(ctx).colorScheme;
    final dotColor = _dotColor(cs, node.level);
    final levelIndent = node.level * _indentStep;

    return SizedBox(
      height: 40,
      child: Row(
        children: [
          // 树状连线区域
          SizedBox(
            width: levelIndent + 20,
            child: CustomPaint(
              painter: _TreeBranchPainter(
                level: node.level,
                isLast: isLast,
                ancestorIsLast: ancestorLast,
                color: cs.outlineVariant,
              ),
            ),
          ),
          // 选中指示左边框
          if (isSelected)
            Container(
              width: 3,
              height: 20,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: dotColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          // 层级圆点
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor.withValues(alpha: isSelected ? 1.0 : 0.6),
            ),
          ),
          const SizedBox(width: 8),
          // 名称
          Expanded(
            child: Text(
              widget.displayField(node.data),
              style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? dotColor : null,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          // 选中标记
          if (isSelected)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(Icons.check_circle_rounded,
                  color: dotColor, size: 20),
            ),
        ],
      ),
    );
  }

  // ─── Multi item ────────────────────────────────────────────────

  Widget _buildMultiItem(
    BuildContext ctx,
    TreeNode<T> node,
    String id,
    bool checked,
    List<bool> ancestorLast,
    bool isLast,
    void Function(VoidCallback) setLocalState,
  ) {
    final cs = Theme.of(ctx).colorScheme;
    final dotColor = _dotColor(cs, node.level);
    final levelIndent = node.level * _indentStep;

    return SizedBox(
      height: 40,
      child: Row(
        children: [
          // 树状连线区域
          SizedBox(
            width: levelIndent + 20,
            child: CustomPaint(
              painter: _TreeBranchPainter(
                level: node.level,
                isLast: isLast,
                ancestorIsLast: ancestorLast,
                color: cs.outlineVariant,
              ),
            ),
          ),
          // Checkbox
          GestureDetector(
            onTap: () => setLocalState(() {
              if (checked) { _tempSelected.remove(id); }
              else { _tempSelected.add(id); }
            }),
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Icon(
                checked
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
                size: 20,
                color: checked ? dotColor : cs.outline,
              ),
            ),
          ),
          // 层级圆点
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor.withValues(alpha: checked ? 1.0 : 0.6),
            ),
          ),
          const SizedBox(width: 8),
          // 名称
          Expanded(
            child: Text(
              widget.displayField(node.data),
              style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                    fontWeight: checked ? FontWeight.w600 : FontWeight.w400,
                    color: checked ? dotColor : null,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Bottom bar ────────────────────────────────────────────────

  Widget _buildBottomBar(BuildContext ctx) {
    final lc = Theme.of(ctx).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: lc.surface,
        border: Border(top: BorderSide(color: lc.outline.withAlpha(20))),
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(L10nManager.l10n.cancel),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx, _tempSelected),
                child: Text(
                    L10nManager.l10n.treeSelectedCount(_tempSelected.length)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext ctx, ColorScheme localColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 2),
          child: Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: localColor.onSurfaceVariant.withAlpha(50),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Row(
            children: [
              Icon(Icons.account_tree_outlined,
                  size: 18, color: localColor.primary),
              const SizedBox(width: 8),
              Text(
                widget.label ?? '选择',
                style: Theme.of(ctx)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (widget.multiSelect)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(L10nManager.l10n.treeMultiSelectHint,
                      style: Theme.of(ctx).textTheme.labelSmall?.copyWith(
                            color: localColor.onSurfaceVariant,
                          )),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final radius = theme.extension<ThemeRadius>()?.radius ?? 12;

    return TextFormField(
      readOnly: true,
      onTap: _showPicker,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.multiSelect
            ? (widget.hint ??
                '${L10nManager.l10n.pleaseSelect('')}${L10nManager.l10n.treeMultiSelectHint}')
            : (widget.hint ?? L10nManager.l10n.pleaseSelect('')),
        errorText: widget.errorText,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withAlpha(30),
        prefixIcon: const Icon(Icons.account_tree_outlined, size: 20),
        suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: colorScheme.outline.withAlpha(60)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: colorScheme.outline.withAlpha(60)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(
            color: colorScheme.primary.withAlpha(120),
            width: 1.5,
          ),
        ),
      ),
      controller: TextEditingController(text: _displayText),
      style: theme.textTheme.bodyLarge,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// 树状连线绘制器
// ═══════════════════════════════════════════════════════════════════

class _TreeBranchPainter extends CustomPainter {
  final int level;
  final bool isLast;
  final List<bool> ancestorIsLast;
  final Color color;

  const _TreeBranchPainter({
    required this.level,
    required this.isLast,
    required this.ancestorIsLast,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (level == 0) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const segW = 20.0;
    final midY = size.height / 2;

    for (int i = 0; i < level; i++) {
      final x = i * segW + segW / 2;
      if (i < level - 1) {
        // 祖先层竖线
        if (ancestorIsLast.length > i && !ancestorIsLast[i]) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
        }
      } else {
        // 当前层：竖线 + 横线弯头
        canvas.drawLine(Offset(x, 0), Offset(x, midY), paint);
        canvas.drawLine(Offset(x, midY), Offset(x + segW / 2, midY), paint);
        if (!isLast) {
          canvas.drawLine(Offset(x, midY), Offset(x, size.height), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TreeBranchPainter old) =>
      level != old.level || isLast != old.isLast || color != old.color;
}

/// 辅助记录层级及是否为末位
class _LevelLast {
  final int level;
  final bool isLast;
  const _LevelLast({required this.level, required this.isLast});
}
