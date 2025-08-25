import 'package:flutter/material.dart';

/// 通用进度条组件
class ProgressIndicatorBar extends StatelessWidget {
  /// 进度值 (0.0 到 1.0)，为 null 时显示不确定进度
  final double? value;

  /// 进度条标签文本
  final String label;

  /// 进度条高度
  final double height;

  /// 文本样式
  final TextStyle? labelStyle;

  const ProgressIndicatorBar({
    super.key,
    this.value,
    required this.label,
    this.height = 18,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: height,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          LinearProgressIndicator(
            value: value,
            minHeight: height,
            backgroundColor: colorScheme.surfaceContainerHighest.withAlpha(180),
            color: colorScheme.primary.withAlpha(51),
          ),
          Text(
            label,
            style: labelStyle ??
                theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }
}
