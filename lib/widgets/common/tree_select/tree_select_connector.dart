import 'package:flutter/material.dart';

/// 层级缩进标签 — 书签形小标签，每层颜色渐变
class LevelTab extends StatelessWidget {
  final int level;
  final Color color;
  final bool isSelected;

  const LevelTab({
    super.key,
    required this.level,
    required this.color,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final alpha = isSelected ? 255 : (255 - level * 30).clamp(160, 255);
    return Container(
      width: 3,
      height: 12,
      decoration: BoxDecoration(
        color: color.withAlpha(alpha),
        borderRadius: BorderRadius.circular(1.5),
      ),
    );
  }
}
