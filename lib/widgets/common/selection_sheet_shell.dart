import 'package:flutter/material.dart';
import '../../theme/theme_radius.dart';

/// 共用 BottomSheet 外壳：拖拽手柄 + 可选标题头 + 圆角容器
/// 供树形选择器和通用选择器的 BottomSheet 内容共用
///
/// 用法：
/// ```dart
/// showModalBottomSheet(
///   builder: (ctx) => SelectionSheetShell(
///     headerIcon: Icons.account_tree_outlined,
///     headerTitle: '选择分类',
///     headerSubtitle: '多选',
///     children: [
///       // 在这里放搜索栏、ListView、底部按钮栏等
///       _buildSearchBar(),
///       Divider(...),
///       Expanded(child: _buildList()),
///       _buildBottomBar(),
///     ],
///   ),
/// )
/// ```
class SelectionSheetShell extends StatelessWidget {
  /// 标题行图标
  final IconData? headerIcon;

  /// 标题文本
  final String? headerTitle;

  /// 标题行副文本（如"多选"提示）
  final String? headerSubtitle;

  /// 最大高度占屏幕比例，默认 0.68
  final double maxHeightRatio;

  /// 最小高度，默认 200
  final double minHeight;

  /// 内容区子组件（header 下方所有内容）
  final List<Widget> children;

  const SelectionSheetShell({
    super.key,
    this.headerIcon,
    this.headerTitle,
    this.headerSubtitle,
    this.maxHeightRatio = 0.68,
    this.minHeight = 200,
    this.children = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final radius = theme.extension<ThemeRadius>()?.radius ?? 12;
    final screenH = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenH * maxHeightRatio,
        minHeight: minHeight,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
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
                color: colorScheme.onSurfaceVariant.withAlpha(50),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // 标题头
          if (headerTitle != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                children: [
                  if (headerIcon != null) ...[
                    Icon(headerIcon, size: 18, color: colorScheme.primary),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      headerTitle!,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (headerSubtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        headerSubtitle!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          // 内容区（由调用方提供）
          ...children,
        ],
      ),
    );
  }
}
