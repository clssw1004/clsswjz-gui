import 'package:flutter/material.dart';
import '../../models/vo/activity_definition_vo.dart';

class ActivityCheckinGrid extends StatelessWidget {
  final List<ActivityDefinitionVO> definitions;
  final Map<String, int> totalCounts;
  final Map<String, int> myTodayCounts;
  final void Function(ActivityDefinitionVO vo) onTap;
  final void Function(ActivityDefinitionVO vo) onLongPress;

  const ActivityCheckinGrid({
    super.key,
    required this.definitions,
    required this.totalCounts,
    required this.myTodayCounts,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: definitions.length,
      itemBuilder: (context, index) {
        return _buildDefinitionCard(theme, definitions[index]);
      },
    );
  }

  Widget _buildDefinitionCard(ThemeData theme, ActivityDefinitionVO def) {
    final total = totalCounts[def.id] ?? 0;
    final myToday = myTodayCounts[def.id] ?? 0;
    final bgColor = Color(def.color);
    final hasLimit = def.maxDailyCount != null;
    final limitReached = hasLimit && myToday >= def.maxDailyCount!;
    final showProgress = hasLimit && def.maxDailyCount! > 0;
    final cardColor = bgColor.withAlpha(28);

    return GestureDetector(
      onTap: () => onTap(def),
      onLongPress: () => onLongPress(def),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            // clay depth shadow stack
            BoxShadow(
              color: bgColor.withAlpha(20),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
            BoxShadow(
              color: bgColor.withAlpha(12),
              offset: const Offset(0, 8),
              blurRadius: 16,
            ),
          ],
        ),
        child: Column(
          children: [
            const Spacer(),
            // Emoji
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: bgColor.withAlpha(30),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(def.emoji, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(height: 8),
            // Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(def.name,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(height: 6),
            // Total count pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              decoration: BoxDecoration(
                color: bgColor.withAlpha(50),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('$total',
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: bgColor,
                      fontWeight: FontWeight.w800)),
            ),
            // Progress / limit
            if (showProgress) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: (myToday / def.maxDailyCount!).clamp(0.0, 1.0),
                    minHeight: 5,
                    backgroundColor: bgColor.withAlpha(25),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      limitReached ? bgColor : bgColor.withAlpha(170),
                    ),
                  ),
                ),
              ),
              if (limitReached)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text('今日已满',
                      style: theme.textTheme.labelSmall?.copyWith(
                          color: bgColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 10)),
                ),
            ],
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
