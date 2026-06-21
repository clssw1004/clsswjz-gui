import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../manager/l10n_manager.dart';
import '../models/vo/user_note_vo.dart';
import '../theme/theme_spacing.dart';
import 'book/note_tile.dart';
import 'report/report_tile.dart';
import '../pages/report/report_detail_page.dart';

/// 笔记渲染器接口
/// 每种 noteType + template 组合注册一个渲染器
abstract class NoteRenderer {
  /// 在列表中渲染预览卡片
  Widget buildTile(UserNoteVO note, VoidCallback? onTap, {VoidCallback? onDelete});

  /// 构建详情页
  Widget buildPage(UserNoteVO note);

  /// 是否可编辑
  bool get isEditable => false;
}

/// 笔记渲染器注册中心（适配器模式）
class NoteRendererRegistry {
  NoteRendererRegistry._();

  static final Map<String, NoteRenderer> _registry = {};

  /// 注册渲染器
  /// [key] 格式为 "noteType:template"，如 "NOTE:"、"REPORT:report_v1"
  static void register(String noteType, String? template, NoteRenderer renderer) {
    _registry['$noteType:${template ?? ''}'] = renderer;
  }

  /// 获取渲染器，按 noteType+template 精确匹配，再按 noteType 模糊匹配
  static NoteRenderer? resolve(String? noteType, String? template) {
    // 精确匹配
    final exact = _registry['$noteType:${template ?? ''}'];
    if (exact != null) return exact;
    // 按 noteType 匹配（任意 template）
    final typeMatch = _registry['$noteType:'];
    if (typeMatch != null) return typeMatch;
    return null;
  }
}

/// 默认 Quill 笔记渲染器
class DefaultNoteRenderer extends NoteRenderer {
  @override
  bool get isEditable => true;

  @override
  Widget buildTile(UserNoteVO note, VoidCallback? onTap, {VoidCallback? onDelete}) {
    return NoteTile(
      note: note,
      index: 0,
      onTap: onTap,
      onDelete: onDelete != null ? (_) async { onDelete(); return true; } : null,
    );
  }

  @override
  Widget buildPage(UserNoteVO note) {
    // 默认走编辑页（只读查看通过 NoteFormPage 实现）
    // 实际路由到编辑页时由调用方处理
    return const SizedBox();
  }
}

/// 月度报告渲染器
class ReportNoteRenderer extends NoteRenderer {
  @override
  bool get isEditable => false;

  @override
  Widget buildTile(UserNoteVO note, VoidCallback? onTap, {VoidCallback? onDelete}) {
    return _DeletableReportTile(note: note, onTap: onTap, onDelete: onDelete);
  }

  @override
  Widget buildPage(UserNoteVO note) {
    return ReportDetailPage(note: note);
  }
}

/// ReportTile + 左滑删除包装
class _DeletableReportTile extends StatelessWidget {
  final UserNoteVO note;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const _DeletableReportTile({
    required this.note,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final spacing = Theme.of(context).spacing;

    final tile = ReportTile(note: note, onTap: onTap);

    if (onDelete == null) return tile;

    return Padding(
      padding: spacing.listItemMargin,
      child: Slidable(
        key: ValueKey(note.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.20,
          children: [
            CustomSlidableAction(
              onPressed: (_) => _showDeleteConfirm(context),
              backgroundColor: cs.errorContainer.withValues(alpha: 0.7),
              foregroundColor: cs.error,
              borderRadius: BorderRadius.horizontal(right: Radius.circular(10)),
              child: const Icon(Icons.delete_outline, size: 24),
            ),
          ],
        ),
        child: tile,
      ),
    );
  }

  Future<void> _showDeleteConfirm(BuildContext context) async {
    final l10n = L10nManager.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          title: Text(l10n.delete(l10n.tabNotes)),
          content: Text('${l10n.delete(l10n.tabNotes)}？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.cancel, style: TextStyle(color: theme.colorScheme.outline)),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.confirm, style: TextStyle(color: theme.colorScheme.error)),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      onDelete?.call();
    }
  }
}

/// 初始化默认渲染器
void initNoteRenderers() {
  NoteRendererRegistry.register('NOTE', null, DefaultNoteRenderer());
  NoteRendererRegistry.register('NOTE', '', DefaultNoteRenderer());
  NoteRendererRegistry.register('REPORT', '', ReportNoteRenderer());
  NoteRendererRegistry.register('REPORT', 'report_v1', ReportNoteRenderer());
}
