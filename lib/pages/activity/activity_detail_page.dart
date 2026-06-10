import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/activity_definition_vo.dart';
import '../../providers/activity_checkin_provider.dart';
import '../../utils/date_util.dart';
import 'activity_def_edit_page.dart';

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

  Future<void> _editDefinition(ActivityDefinitionVO def) async {
    final result = await Navigator.push<(String, String, int, int?)>(
      context,
      MaterialPageRoute(
        builder: (_) => ActivityDefEditPage(definition: def),
      ),
    );
    if (result == null || !mounted) return;
    final (name, emoji, color, maxDailyCount) = result;
    final updated = ActivityDefinitionVO(
      id: def.id,
      accountBookId: def.accountBookId,
      name: name,
      emoji: emoji,
      color: color,
      sortOrder: def.sortOrder,
      maxDailyCount: maxDailyCount,
      createdAt: def.createdAt,
      updatedAt: def.updatedAt,
    );
    final provider = context.read<ActivityCheckinProvider>();
    await provider.updateDefinition(updated);
    if (mounted) {
      provider.loadRecordsByDefId(def.id);
    }
  }

  Future<void> _deleteDefinition() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(L10nManager.l10n.confirmDelete),
        content: Text(L10nManager.l10n.deleteActivityConfirm(widget.definition.name)),
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
    );
    if (confirm == true && mounted) {
      await context.read<ActivityCheckinProvider>().deleteDefinition(widget.definition.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final def = widget.definition;
    final bgColor = Color(def.color);

    return Scaffold(
      appBar: AppBar(
        title: Text(def.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: L10nManager.l10n.edit,
            onPressed: () => _editDefinition(def),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            tooltip: L10nManager.l10n.activityDelete,
            onPressed: _deleteDefinition,
          ),
        ],
      ),
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
                if (def.maxDailyCount != null && provider.todayCountByDefId >= def.maxDailyCount!)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.withAlpha(30),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.orange.withAlpha(100)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_outline,
                              size: 16, color: Colors.orange.shade700),
                          const SizedBox(width: 6),
                          Text(
                            '已达每日上限 ${def.maxDailyCount} 次',
                            style: theme.textTheme.labelMedium?.copyWith(
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
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
    final timeStr = DateUtil.format(record.createdAt);

    Future<void> onEditTime() async {
      final dt = DateTime.fromMillisecondsSinceEpoch(record.createdAt);
      final date = await showDatePicker(
        context: context,
        initialDate: dt,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
      );
      if (date == null || !mounted) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(dt),
      );
      if (time == null || !mounted) return;
      final newDt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      await provider.updateRecordTime(record.id, createdAt: newDt.millisecondsSinceEpoch);
    }

    Future<bool> onDelete() async {
      final confirmed = await showDialog<bool>(
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
      );
      if (confirmed == true && mounted) {
        return provider.deleteRecord(record.id);
      }
      return false;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: ValueKey(record.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: colorScheme.error,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.delete_outline, color: colorScheme.onError),
        ),
        confirmDismiss: (_) async {
          final deleted = await onDelete();
          return deleted;
        },
        child: GestureDetector(
          onLongPress: onEditTime,
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.access_time,
                    size: 18, color: colorScheme.primary),
                const SizedBox(width: 12),
                Text(timeStr,
                    style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
