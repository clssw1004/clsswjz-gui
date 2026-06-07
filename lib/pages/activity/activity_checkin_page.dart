import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/activity_definition_vo.dart';
import '../../providers/activity_checkin_provider.dart';
import '../../widgets/activity/activity_checkin_grid.dart';
import 'activity_def_edit_page.dart';

class ActivityCheckinPage extends StatefulWidget {
  const ActivityCheckinPage({super.key});

  @override
  State<ActivityCheckinPage> createState() => _ActivityCheckinPageState();
}

class _ActivityCheckinPageState extends State<ActivityCheckinPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityCheckinProvider>().loadAll();
    });
  }

  void _onCheckIn(ActivityDefinitionVO def) {
    context.read<ActivityCheckinProvider>().checkIn(def.id);
  }

  void _onLongPress(ActivityDefinitionVO def) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(L10nManager.l10n.edit),
              onTap: () {
                Navigator.pop(ctx);
                _editDefinition(def);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: Text(L10nManager.l10n.activityDelete, style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                _deleteDefinition(def);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editDefinition(ActivityDefinitionVO def) async {
    final result = await Navigator.push<(String, String, int)>(
      context,
      MaterialPageRoute(
        builder: (_) => ActivityDefEditPage(definition: def),
      ),
    );
    if (result == null || !mounted) return;
    final (name, emoji, color) = result;
    final updated = ActivityDefinitionVO(
      id: def.id,
      accountBookId: def.accountBookId,
      name: name,
      emoji: emoji,
      color: color,
      sortOrder: def.sortOrder,
      createdAt: def.createdAt,
      updatedAt: def.updatedAt,
    );
    await context.read<ActivityCheckinProvider>().updateDefinition(updated);
  }

  Future<void> _deleteDefinition(ActivityDefinitionVO def) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(L10nManager.l10n.confirmDelete),
        content: Text(L10nManager.l10n.deleteActivityConfirm(def.name)),
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
      await context.read<ActivityCheckinProvider>().deleteDefinition(def.id);
    }
  }

  void _navigateToCreate() async {
    final result = await Navigator.push<(String, String, int)>(
      context,
      MaterialPageRoute(
        builder: (_) => const ActivityDefEditPage(),
      ),
    );
    if (result == null || !mounted) return;
    final (name, emoji, color) = result;
    await context
        .read<ActivityCheckinProvider>()
        .createDefinition(name: name, emoji: emoji, color: color);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(L10nManager.l10n.activityCheckin),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: L10nManager.l10n.activityCreate,
            onPressed: _navigateToCreate,
          ),
        ],
      ),
      body: Consumer<ActivityCheckinProvider>(
        builder: (context, provider, _) {
          if (provider.loading && provider.definitions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.definitions.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.emoji_events_outlined,
                      size: 64, color: colorScheme.outline.withAlpha(100)),
                  const SizedBox(height: 16),
                  Text(L10nManager.l10n.noActivityDefinitions,
                      style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    onPressed: _navigateToCreate,
                    icon: const Icon(Icons.add),
                    label: Text(L10nManager.l10n.createFirstActivity),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadAll(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: ActivityCheckinGrid(
                    definitions: provider.definitions,
                    todayCounts: provider.todayCounts,
                    onCheckIn: _onCheckIn,
                    onLongPress: _onLongPress,
                    onAddNew: _navigateToCreate,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          L10nManager.l10n.todayCheckinCount(provider.todayTotal),
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
