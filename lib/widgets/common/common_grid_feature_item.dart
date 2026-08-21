import 'package:flutter/material.dart';

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

  /// 语义色：图标本体与渐变背景使用该颜色；为 null 时回退主题主色。
  final Color? color;

  const CommonGridFeatureItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isHighlighted = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = color ?? colorScheme.primary;
    // 深色模式下图标容器不画背景/边框，只保留彩色图标本体，避免色块突兀
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            color: isHighlighted
                ? colorScheme.surfaceContainerHighest.withAlpha(90)
                : colorScheme.surfaceContainerHighest.withAlpha(45),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHighlighted
                  ? colorScheme.outlineVariant.withAlpha(50)
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
                decoration: isDark
                    ? null
                    : BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            iconColor.withAlpha(isHighlighted ? 50 : 36),
                            iconColor.withAlpha(isHighlighted ? 16 : 10),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: isHighlighted
                            ? Border.all(
                                color: iconColor.withAlpha(55),
                                width: 1,
                              )
                            : null,
                      ),
                child: Icon(
                  icon,
                  size: 20,
                  color: iconColor,
                ),
              ),
              SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
