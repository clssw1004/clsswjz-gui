import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:convert';
import '../../models/vo/user_note_vo.dart';
import '../../theme/theme_spacing.dart';
import '../../manager/l10n_manager.dart';
import '../common/common_card_container.dart';

/// 笔记列表项组件
class NoteTile extends StatelessWidget {
  /// 笔记数据
  final UserNoteVO note;

  /// 在列表中的索引
  final int index;

  /// 点击回调
  final VoidCallback? onTap;

  /// 删除回调
  final Future<bool> Function(UserNoteVO note)? onDelete;

  const NoteTile({
    super.key,
    required this.note,
    required this.index,
    this.onTap,
    this.onDelete,
  });

  String _getPlainText(String? content) {
    if (content == null || content.isEmpty) return '';
    try {
      final delta = jsonDecode(content);
      final document = Document.fromJson(delta);
      return document.toPlainText();
    } catch (e) {
      return content;
    }
  }

  /// 显示删除确认对话框
  Future<bool> _showDeleteConfirmDialog(BuildContext context) async {
    final l10n = L10nManager.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text(l10n.delete(l10n.tabNotes)),
          content: Text('${l10n.delete(l10n.tabNotes)}？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                l10n.cancel,
                style: TextStyle(color: theme.colorScheme.outline),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                l10n.confirm,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final result = await onDelete?.call(note);
      return result ?? false;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.spacing;
    final plainText = _getPlainText(note.content);

    return SizedBox(
      width: double.infinity,
      child: CommonCardContainer(
        onTap: onTap,
        margin: spacing.listItemMargin,
        padding: EdgeInsets.zero,
        child: Slidable(
          key: ValueKey(note.id),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 0.20,
            dismissible: DismissiblePane(
              onDismissed: () {},
              closeOnCancel: true,
              confirmDismiss: () => _showDeleteConfirmDialog(context),
            ),
            children: [
              CustomSlidableAction(
                backgroundColor: colorScheme.errorContainer.withAlpha(180),
                foregroundColor: colorScheme.error,
                padding: EdgeInsets.zero,
                onPressed: (_) async {
                  final confirmed = await _showDeleteConfirmDialog(context);
                  if (!confirmed) {
                    Slidable.of(context)?.close();
                  }
                },
                child: Icon(
                  Icons.delete_outline,
                  color: colorScheme.error,
                  size: 24,
                ),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.listItemPadding.left,
              vertical: spacing.listItemPadding.top / 1.5,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 标题
                if (note.title?.isNotEmpty == true) ...[
                  Text(
                    note.title!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                      letterSpacing: 0.15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: spacing.listItemSpacing / 2),
                ],
                // 内容预览
                Text(
                  plainText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    height: 1.4,
                    letterSpacing: 0.25,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: spacing.listItemSpacing / 2),
                // 日期和其他信息
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 日期
                    Text(
                      note.createdAt!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
