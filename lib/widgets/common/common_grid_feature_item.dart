import 'package:flutter/material.dart';
import '../../theme/theme_spacing.dart';

/// 功能网格项组件
///
/// 用于功能菜单中以网格形式展示的可点击项目，包含图标和文字标签。
/// 常用于 "我的" 页面的功能按钮区域。
class CommonGridFeatureItem extends StatelessWidget {
  /// 图标
  final IconData icon;

  /// 文字标签
  final String label;

  /// 点击回调
  final VoidCallback onTap;

  /// 是否高亮模式（更强的透明度层级）
  final bool isHighlighted;

  const CommonGridFeatureItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final spacing = Theme.of(context).spacing;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: spacing.listItemPadding,
          decoration: BoxDecoration(
            color: isHighlighted
                ? colorScheme.surfaceContainerHighest.withAlpha(80)
                : colorScheme.surfaceContainerHighest.withAlpha(40),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isHighlighted
                  ? colorScheme.outlineVariant.withAlpha(40)
                  : colorScheme.outlineVariant.withAlpha(20),
              width: 0.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isHighlighted
                      ? colorScheme.primary.withAlpha(15)
                      : colorScheme.primary.withAlpha(10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(height: spacing.listItemSpacing),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
