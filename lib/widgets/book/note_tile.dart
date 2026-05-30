import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:convert';
import '../../models/vo/user_note_vo.dart';
import '../../theme/theme_spacing.dart';
import '../../theme/theme_radius.dart';
import '../../manager/l10n_manager.dart';
import '../../utils/date_util.dart';

final List<Color> _notePalette = [
  const Color(0xFF5C6BC0),
  const Color(0xFF26A69A),
  const Color(0xFFFF7043),
  const Color(0xFFAB47BC),
  const Color(0xFF42A5F5),
  const Color(0xFF66BB6A),
  const Color(0xFFEC407A),
  const Color(0xFFFFA726),
  const Color(0xFF26C6DA),
  const Color(0xFF8D6E63),
];

Color _colorForNote(String code) {
  final index = code.hashCode.abs() % _notePalette.length;
  return _notePalette[index];
}

/// 笔记列表项组件
class NoteTile extends StatefulWidget {
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

  @override
  State<NoteTile> createState() => _NoteTileState();
}

class _NoteTileState extends State<NoteTile> {
  bool _isExpanded = false;

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  Document? _getDocument(String? content) {
    if (content == null || content.isEmpty) return null;
    try {
      final delta = jsonDecode(content);
      return Document.fromJson(delta);
    } catch (e) {
      return null;
    }
  }

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

  Widget _buildEditor(Document document, ThemeData theme, ColorScheme colorScheme) {
    final controller = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );

    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.copyWith(
          bodyMedium: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
            height: 1.4,
            letterSpacing: 0.25,
          ),
        ),
      ),
      child: QuillEditor(
        controller: controller,
        scrollController: ScrollController(),
        focusNode: FocusNode(),
        config: QuillEditorConfig(
          autoFocus: false,
          expands: false,
          padding: EdgeInsets.zero,
          showCursor: false,
          enableInteractiveSelection: false,
          placeholder: null,
          embedBuilders: FlutterQuillEmbeds.editorBuilders(
            imageEmbedConfig: QuillEditorImageEmbedConfig(
              imageProviderBuilder: (context, imageUrl) => null,
            ),
          ),
        ),
      ),
    );
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
      final result = await widget.onDelete?.call(widget.note);
      return result ?? false;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.spacing;
    final radius = theme.extension<ThemeRadius>()?.radius ?? 8;
    final document = _getDocument(widget.note.content);
    final plainText = _getPlainText(widget.note.content);
    final accentColor = _colorForNote(widget.note.groupCode ?? widget.note.id);

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: spacing.listItemMargin,
        child: Slidable(
          key: ValueKey(widget.note.id),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: 0.20,
            children: [
              CustomSlidableAction(
                onPressed: (_) => _showDeleteConfirmDialog(context),
                backgroundColor: colorScheme.errorContainer.withValues(alpha: 0.7),
                foregroundColor: colorScheme.error,
                borderRadius: BorderRadius.horizontal(right: Radius.circular(radius)),
                child: const Icon(Icons.delete_outline, size: 24),
              ),
            ],
          ),
          child: Card(
            clipBehavior: Clip.antiAlias,
            elevation: 0,
            margin: EdgeInsets.zero,
            color: colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
              side: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.18),
              ),
            ),
            child: InkWell(
              onTap: widget.onTap,
              child: Row(
                children: [
                  // 左侧彩色装饰条
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          accentColor,
                          accentColor.withValues(alpha: 0.4),
                        ],
                      ),
                    ),
                  ),
                  // 主要内容
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(spacing.listItemPadding.left),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 标题行
                          if (widget.note.title?.isNotEmpty == true)
                            Padding(
                              padding: EdgeInsets.only(bottom: spacing.listItemSpacing / 2),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.subject_rounded,
                                    size: 20,
                                    color: accentColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      widget.note.title!,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: colorScheme.onSurface,
                                        fontWeight: FontWeight.w600,
                                        height: 1.3,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (widget.note.groupName?.isNotEmpty == true)
                                    _buildGroupChip(widget.note.groupName!, accentColor, theme),
                                ],
                              ),
                            ),
                          // 分组名（无标题时在内容区上方显示）
                          if ((widget.note.title?.isEmpty ?? true) &&
                              widget.note.groupName?.isNotEmpty == true)
                            Padding(
                              padding: EdgeInsets.only(bottom: spacing.listItemSpacing / 2),
                              child: _buildGroupChip(widget.note.groupName!, accentColor, theme),
                            ),
                          // 内容区
                          _isExpanded && document != null
                              ? ConstrainedBox(
                                  constraints: const BoxConstraints(maxHeight: 300),
                                  child: AbsorbPointer(
                                    child: _buildEditor(document, theme, colorScheme),
                                  ),
                                )
                              : Text(
                                  plainText,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    height: 1.5,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          // 底部栏
                          Padding(
                            padding: EdgeInsets.only(top: spacing.listItemSpacing / 2),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.schedule_outlined,
                                  size: 14,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  DateUtil.format(widget.note.createdAt!),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    letterSpacing: 0.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                Material(
                                  type: MaterialType.transparency,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: _toggleExpand,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: AnimatedRotation(
                                        turns: _isExpanded ? 0.5 : 0.0,
                                        duration: const Duration(milliseconds: 200),
                                        child: Icon(
                                          Icons.expand_more_rounded,
                                          size: 22,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
      ),
    );
  }

  Widget _buildGroupChip(String groupName, Color accentColor, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        groupName,
        style: theme.textTheme.labelSmall?.copyWith(
          color: accentColor,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
