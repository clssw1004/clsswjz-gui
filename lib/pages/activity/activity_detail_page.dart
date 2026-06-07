import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/activity_definition_vo.dart';
import '../../providers/activity_checkin_provider.dart';
import '../../utils/date_util.dart';

class ActivityDetailPage extends StatefulWidget {
  final ActivityDefinitionVO definition;

  const ActivityDetailPage({super.key, required this.definition});

  @override
  State<ActivityDetailPage> createState() => _ActivityDetailPageState();
}

class _ActivityDetailPageState extends State<ActivityDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityCheckinProvider>().loadRecordsByDefId(widget.definition.id);
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _doCheckIn(String defId) async {
    HapticFeedback.heavyImpact();
    _animController.forward().then((_) => _animController.reverse());
    final provider = context.read<ActivityCheckinProvider>();
    final ok = await provider.checkIn(defId);
    if (ok && mounted) {
      provider.loadRecordsByDefId(defId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final def = widget.definition;
    final bgColor = Color(def.color);

    return Scaffold(
      appBar: AppBar(title: Text(def.name)),
      body: Consumer<ActivityCheckinProvider>(
        builder: (context, provider, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeader(def, bgColor, provider, theme),
              const SizedBox(height: 24),
              _buildRecordsList(def, provider, theme),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(
    ActivityDefinitionVO def,
    Color bgColor,
    ActivityCheckinProvider provider,
    ThemeData theme,
  ) {
    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnim.value,
        child: child,
      ),
      child: Card(
        elevation: 0,
        color: bgColor.withAlpha(25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: bgColor.withAlpha(60), width: 1.5),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _doCheckIn(def.id),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
            child: Column(
              children: [
                Text(def.emoji, style: const TextStyle(fontSize: 56)),
                const SizedBox(height: 8),
                Text(def.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: bgColor.withAlpha(40),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${provider.todayCountByDefId}',
                        style: theme.textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold, color: bgColor),
                      ),
                      Text(L10nManager.l10n.currentDay,
                          style: theme.textTheme.labelMedium?.copyWith(
                              color: bgColor.withAlpha(180))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecordsList(
    ActivityDefinitionVO def,
    ActivityCheckinProvider provider,
    ThemeData theme,
  ) {
    final records = provider.recordsByDefId;
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(L10nManager.l10n.recentCheckins,
            style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        if (records.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.history_outlined,
                      size: 48,
                      color: colorScheme.outline.withAlpha(80)),
                  const SizedBox(height: 8),
                  Text(L10nManager.l10n.noCheckinRecords,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
          )
        else
          ...records.map((r) => _buildRecordRow(r, provider, theme, colorScheme)),
      ],
    );
  }

  Widget _buildRecordRow(
    dynamic record,
    ActivityCheckinProvider provider,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final dateStr = record.recordDate;
    final timeStr = DateUtil.format(record.createdAt);

    void onDelete() {
      showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(L10nManager.l10n.confirmDelete),
          content: Text(L10nManager.l10n.deleteActivityConfirm(record.activityName)),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(L10nManager.l10n.cancel)),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(L10nManager.l10n.activityDelete)),
          ],
        ),
      ).then((confirmed) {
        if (confirmed == true && mounted) {
          provider.deleteRecord(record.id);
        }
      });
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onLongPress: onDelete,
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline,
                  size: 20, color: colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(dateStr,
                    style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500)),
              ),
              Text(timeStr,
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}
