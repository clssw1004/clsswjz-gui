import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'tree_select_connector.dart';

/// 树节点单项 — 层级彩色圆点 + 缩进
///
/// 每个层级用不同颜色的 5px 实心圆标记。
/// 选中态：左侧 3px 色条 + 背景 tint + 文字变色加粗。
class TreeSelectItem<T> extends StatefulWidget {
  final int level;
  final String id;
  final bool isChecked;
  final bool isMulti;
  final String displayText;
  final Color branchColor;
  final bool hasChildren;
  final bool isExpanded;
  final bool selectable;
  final VoidCallback onTap;
  final VoidCallback? onToggleExpand;

  const TreeSelectItem({
    super.key,
    required this.level,
    required this.id,
    required this.isChecked,
    required this.isMulti,
    required this.displayText,
    required this.branchColor,
    required this.hasChildren,
    required this.isExpanded,
    this.selectable = true,
    required this.onTap,
    this.onToggleExpand,
  });

  @override
  State<TreeSelectItem<T>> createState() => _TreeSelectItemState<T>();
}

class _TreeSelectItemState<T> extends State<TreeSelectItem<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _checkAnim;
  late Animation<double> _checkScale;

  @override
  void initState() {
    super.initState();
    _checkAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _checkScale = CurvedAnimation(
      parent: _checkAnim,
      curve: Curves.elasticOut,
    );
    if (widget.isChecked) _checkAnim.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant TreeSelectItem<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isChecked != oldWidget.isChecked) {
      if (widget.isChecked) {
        _checkAnim.forward();
      } else {
        _checkAnim.reverse();
      }
    }
  }

  @override
  void dispose() {
    _checkAnim.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.selectionClick();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final opacity = widget.selectable ? 1.0 : 0.4;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      color: widget.isChecked
          ? widget.branchColor.withAlpha(25)
          : Colors.transparent,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.selectable ? _handleTap : null,
          child: SizedBox(
            height: 44,
            child: Opacity(
              opacity: opacity,
              child: Row(
                children: [
                  // 层级缩进
                  SizedBox(width: widget.level * 26.0),
                  LevelTab(
                    level: widget.level,
                    color: widget.branchColor,
                    isSelected: widget.isChecked,
                  ),
                  const SizedBox(width: 10),
                  // 文本
                  Expanded(
                    child: Text(
                      widget.displayText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            widget.isChecked ? FontWeight.w600 : FontWeight.w400,
                        color: widget.isChecked ? widget.branchColor : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // 右侧固定图标区（48px）
                  SizedBox(
                    width: 48,
                    child: Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        if (widget.hasChildren)
                          Positioned(
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                widget.onToggleExpand?.call();
                              },
                              behavior: HitTestBehavior.opaque,
                              child: AnimatedRotation(
                                turns: widget.isExpanded ? 0.5 : 0.0,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeInOut,
                                child: Icon(
                                  Icons.arrow_drop_down_rounded,
                                  size: 24,
                                  color: theme.colorScheme
                                      .onSurfaceVariant
                                      .withAlpha(100),
                                ),
                              ),
                            ),
                          ),
                        if (widget.isChecked)
                          Positioned(
                            right: 28,
                            child: ScaleTransition(
                              scale: _checkScale,
                              child: Icon(
                                Icons.check_circle_rounded,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
