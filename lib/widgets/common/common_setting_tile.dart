import 'package:flutter/material.dart';
import '../../theme/theme_spacing.dart';

/// 设置列表项组件
///
/// 用于设置页面的列表项，包含圆形图标、文字标签、右侧箭头和底部分隔线。
/// 常用于 "我的" 页面的系统设置区域。
class CommonSettingTile extends StatelessWidget {
  /// 图标
  final IconData icon;

  /// 文字标签
  final String label;

  /// 点击回调
  final VoidCallback onTap;

  /// 是否为最后一项（控制底部分隔线显示）
  final bool isLast;

  const CommonSettingTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.spacing;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: spacing.formItemPadding,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.only(left: 68),
            child: Divider(
              height: 1,
              color: colorScheme.outlineVariant.withAlpha(128),
            ),
          ),
      ],
    );
  }
}
