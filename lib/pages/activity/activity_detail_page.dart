import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../manager/dao_manager.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../manager/service_manager.dart';
import '../../models/vo/activity_definition_vo.dart';
import '../../models/vo/attachment_vo.dart';
import '../../providers/activity_checkin_provider.dart';
import 'package:intl/intl.dart';
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
  Map<String, String> _userNames = {};
  Map<String, Color> _userColors = {};
  Map<String, AttachmentVO?> _userAvatars = {};

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
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = context.read<ActivityCheckinProvider>();
    await provider.loadRecordsByDefId(widget.definition.id);
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final provider = context.read<ActivityCheckinProvider>();
    final userIds = provider.recordsByDefId
        .map((r) => r.createdBy)
        .toSet()
        .toList();
    if (userIds.isEmpty) return;
    try {
      final users = await DaoManager.userDao.findByIds(userIds);
      final nameMap = <String, String>{};
      final colorMap = <String, Color>{};
      final avatarIds = <String>[];
      for (final u in users) {
        final displayName = u.nickname.isNotEmpty ? u.nickname : u.username;
        nameMap[u.id] = displayName;
        colorMap[u.id] = _hashColor(u.id);
        if (u.avatar != null && u.avatar!.isNotEmpty) {
          avatarIds.add(u.avatar!);
        }
      }

      // 加载头像（同数据共享页面方式）
      final avatarMap = <String, AttachmentVO?>{};
      if (avatarIds.isNotEmpty) {
        try {
          final attachments = await ServiceManager.attachmentService.getAttachments(avatarIds);
          for (final a in attachments) {
            avatarMap[a.id] = a;
          }
        } catch (_) {}
      }
      final userAvatarMap = <String, AttachmentVO?>{};
      for (final u in users) {
        if (u.avatar != null) {
          userAvatarMap[u.id] = avatarMap[u.avatar];
        }
      }

      if (mounted) {
        setState(() {
          _userNames = nameMap;
          _userColors = colorMap;
          _userAvatars = userAvatarMap;
        });
      }
    } catch (_) {}
  }

  static Color _hashColor(String id) {
    final hash = id.hashCode;
    final hues = [0, 30, 60, 120, 180, 210, 240, 300, 330];
    final hue = hues[hash.abs() % hues.length];
    return HSLColor.fromAHSL(0.35, hue.toDouble(), 0.6, 0.5).toColor();
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
        title: const Text(''),
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
      child: Container(
        decoration: BoxDecoration(
          color: bgColor.withAlpha(25),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: bgColor.withAlpha(20),
              offset: const Offset(0, 4),
              blurRadius: 10,
            ),
          ],
        ),
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
                        '${provider.totalCountOf(def.id)}',
                        style: theme.textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold, color: bgColor),
                      ),
                      Text('累计',
                          style: theme.textTheme.labelMedium?.copyWith(
                              color: bgColor.withAlpha(180))),
                    ],
                  ),
                ),
                if (def.maxDailyCount != null && provider.myTodayCountOf(def.id) >= def.maxDailyCount!)
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
    final dt = DateTime.fromMillisecondsSinceEpoch(record.createdAt);
    final dateTimeStr = DateFormat('yyyy/MM/dd HH:mm').format(dt);
    final isMine = record.createdBy == AppConfigManager.instance.userId;
    final userName = _userNames[record.createdBy] ?? record.createdBy.substring(0, 6);
    final userColor = _userColors[record.createdBy] ?? colorScheme.secondaryContainer;

    Future<bool> onDelete() async {
      if (!isMine) return false;
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

    final avatarAttach = _userAvatars[record.createdBy];

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: ValueKey(record.id),
        direction: isMine ? DismissDirection.endToStart : DismissDirection.none,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: colorScheme.error,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.delete_outline, color: colorScheme.onError),
        ),
        confirmDismiss: (_) async {
          final deleted = await onDelete();
          return deleted;
        },
        child: GestureDetector(
          onLongPress: isMine ? () => _showEditRecordSheet(context, record, provider, theme) : null,
          child: Opacity(
            opacity: isMine ? 1.0 : 0.7,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withAlpha(8),
                    offset: const Offset(0, 2),
                    blurRadius: 6,
                  ),
                ],
              ),
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
            child: Row(
              children: [
                // 用户头像
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: userColor.withAlpha(120),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: avatarAttach?.file != null
                      ? Image.file(avatarAttach!.file!,
                          width: 36, height: 36,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildAvatarFallback(userName))
                      : _buildAvatarFallback(userName),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 日期时间
                      Text(dateTimeStr,
                          style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700)),
                      // 备注
                      if (record.remark != null && record.remark!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(record.remark!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant.withAlpha(180)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                    ],
                  ),
                ),
                // 用户名
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.person_outline,
                          size: 12,
                          color: colorScheme.onSurfaceVariant.withAlpha(100)),
                      if (!isMine) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.lock_outline,
                            size: 10,
                            color: colorScheme.onSurfaceVariant.withAlpha(80)),
                      ],
                      const SizedBox(width: 2),
                      Text(userName,
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant.withAlpha(150)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Future<void> _showEditRecordSheet(
    BuildContext context,
    dynamic record,
    ActivityCheckinProvider provider,
    ThemeData theme,
  ) async {
    final dt = DateTime.fromMillisecondsSinceEpoch(record.createdAt);
    TextEditingController remarkCtrl = TextEditingController(text: record.remark ?? '');
    TextEditingController locationCtrl = TextEditingController(text: record.location ?? '');
    DateTime selectedDt = dt;

    final result = await showModalBottomSheet<(int?, String?, String?)>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 24, right: 24, top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('编辑记录', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: ctx,
                            initialDate: selectedDt,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date == null || !ctx.mounted) return;
                          final time = await showTimePicker(
                            context: ctx,
                            initialTime: TimeOfDay.fromDateTime(selectedDt),
                          );
                          if (time == null) return;
                          setSheetState(() {
                            selectedDt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                          });
                        },
                        icon: const Icon(Icons.access_time, size: 18),
                        label: Text(DateFormat('yyyy/MM/dd HH:mm').format(selectedDt)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: remarkCtrl,
                    decoration: InputDecoration(
                      labelText: '备注',
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: locationCtrl,
                    decoration: InputDecoration(
                      labelText: '地点',
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        final newCreatedAt = selectedDt.millisecondsSinceEpoch;
                        final newRemark = remarkCtrl.text.trim();
                        final newLocation = locationCtrl.text.trim();
                        Navigator.pop(ctx, (
                          newCreatedAt != dt.millisecondsSinceEpoch ? newCreatedAt : null,
                          newLocation.isNotEmpty ? newLocation : null,
                          newRemark.isNotEmpty ? newRemark : null,
                        ));
                      },
                      child: const Text('保存'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );

    if (result == null || !mounted) return;
    final (newCreatedAt, newLocation, newRemark) = result;

    // 检查是否有实际变更
    final hasTimeChange = newCreatedAt != null && newCreatedAt != dt.millisecondsSinceEpoch;
    final hasLocationChange = newLocation != null && newLocation != (record.location ?? '');
    final hasRemarkChange = newRemark != null && newRemark != (record.remark ?? '');
    if (!hasTimeChange && !hasLocationChange && !hasRemarkChange) return;

    await provider.updateRecord(record.id,
      createdAt: hasTimeChange ? newCreatedAt : null,
      location: hasLocationChange ? newLocation : null,
      remark: hasRemarkChange ? newRemark : null,
    );
  }

  Widget _buildAvatarFallback(String name) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }
}
