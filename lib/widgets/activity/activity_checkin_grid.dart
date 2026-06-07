import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/activity_definition_vo.dart';

class ActivityCheckinGrid extends StatelessWidget {
  final List<ActivityDefinitionVO> definitions;
  final Map<String, int> todayCounts;
  final void Function(ActivityDefinitionVO vo) onCheckIn;
  final void Function(ActivityDefinitionVO vo) onLongPress;
  final VoidCallback onAddNew;

  const ActivityCheckinGrid({
    super.key,
    required this.definitions,
    required this.todayCounts,
    required this.onCheckIn,
    required this.onLongPress,
    required this.onAddNew,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: definitions.length + 1,
      itemBuilder: (context, index) {
        if (index == definitions.length) {
          return _buildAddNewCard(theme, colorScheme);
        }
        return _buildDefinitionCard(
            theme, colorScheme, definitions[index]);
      },
    );
  }

  Widget _buildDefinitionCard(
      ThemeData theme, ColorScheme colorScheme, ActivityDefinitionVO def) {
    final count = todayCounts[def.id] ?? 0;
    final bgColor = Color(def.color);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onCheckIn(def);
      },
      onLongPress: () => onLongPress(def),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor.withAlpha(30),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: bgColor.withAlpha(80),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(def.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 6),
            Text(def.name,
                style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: bgColor.withAlpha(50),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(L10nManager.l10n.activityTimes(count),
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: bgColor, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddNewCard(ThemeData theme, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: onAddNew,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withAlpha(80),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outline.withAlpha(40),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline,
                size: 32, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 8),
            Text(L10nManager.l10n.create,
                style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
