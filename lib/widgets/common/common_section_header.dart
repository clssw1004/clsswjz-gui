import 'package:flutter/material.dart';

/// 通用分组标题组件。
///
/// 用于页面上分成区块的功能/设置分组标题：主题色小图标 + 标题文字。
/// 抽取自「我的」Tab 原有的私有 [sectionHeader] 逻辑，供「全部功能」Hub
/// 与「我的」Tab 等页面共用，保持分区标题视觉一致。
class CommonSectionHeader extends StatelessWidget {
  /// 标题前的图标
  final IconData icon;

  /// 标题文案
  final String title;

  const CommonSectionHeader({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
