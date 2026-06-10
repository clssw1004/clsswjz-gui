import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/vo/activity_definition_vo.dart';

class ActivityCheckinGrid extends StatelessWidget {
  final List<ActivityDefinitionVO> definitions;
  final Map<String, int> todayCounts;
  final void Function(ActivityDefinitionVO vo) onTap;
  final void Function(ActivityDefinitionVO vo) onLongPress;

  const ActivityCheckinGrid({
    super.key,
    required this.definitions,
    required this.todayCounts,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: definitions.length,
      itemBuilder: (context, index) {
        return _buildDefinitionCard(theme, definitions[index]);
      },
    );
  }

  Widget _buildDefinitionCard(
      ThemeData theme, ActivityDefinitionVO def) {
    final count = todayCounts[def.id] ?? 0;
    final bgColor = Color(def.color);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap(def);
      },
      onLongPress: () => onLongPress(def),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor.withAlpha(20),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: bgColor.withAlpha(50),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            const Spacer(),
            // Emoji — 小装饰
            Text(def.emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 6),
            // Name — 主视觉
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(def.name,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(height: 8),
            // Count — 次数标签
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: bgColor.withAlpha(50),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('$count',
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: bgColor,
                      fontWeight: FontWeight.w700)),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
