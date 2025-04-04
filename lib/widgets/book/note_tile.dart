import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:convert';
import '../../models/vo/user_note_vo.dart';
import '../../theme/theme_spacing.dart';
import '../../manager/l10n_manager.dart';
import '../../utils/date_util.dart';
import '../common/common_card_container.dart';

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

class _NoteTileState extends State<NoteTile>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
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

  Widget _buildContent(BuildContext context, Document document) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 300),
        child: AbsorbPointer(
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
              embedBuilders: kIsWeb
                  ? FlutterQuillEmbeds.editorWebBuilders()
                  : FlutterQuillEmbeds.editorBuilders(),
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
    final document = _getDocument(widget.note.content);
    final plainText = _getPlainText(widget.note.content);

    return SizedBox(
      width: double.infinity,
      child: CommonCardContainer(
        onTap: widget.onTap,
        margin: spacing.listItemMargin,
        padding: EdgeInsets.zero,
        child: Slidable(
          key: ValueKey(widget.note.id),
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
          child: Stack(
            children: [
              InkWell(
                onTap: widget.onTap,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.listItemPadding.left,
                    vertical: spacing.listItemPadding.top / 1.5,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.note.title?.isNotEmpty == true) ...[
                        Text(
                          widget.note.title!,
                          style: theme.textTheme.titleLarge?.copyWith(
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
                      if (_isExpanded && document != null)
                        _buildContent(context, document)
                      else
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateUtil.format(widget.note.createdAt!),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              letterSpacing: 0.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 40),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: spacing.listItemPadding.right,
                bottom: spacing.listItemPadding.bottom,
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: _toggleExpand,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
