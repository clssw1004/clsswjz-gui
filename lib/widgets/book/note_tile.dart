import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'dart:convert';
import '../../models/vo/user_note_vo.dart';
import '../../providers/books_provider.dart';
import '../../providers/note_list_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/theme_spacing.dart';
import '../common/common_card_container.dart';

/// 笔记列表项组件
class NoteTile extends StatelessWidget {
  /// 笔记数据
  final UserNoteVO note;

  /// 在列表中的索引
  final int index;

  /// 点击回调
  final VoidCallback? onTap;

  const NoteTile({
    super.key,
    required this.note,
    required this.index,
    this.onTap,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = Provider.of<BooksProvider>(context);
    final noteListProvider = Provider.of<NoteListProvider>(context);
    final spacing = theme.spacing;
    final plainText = _getPlainText(note.content);

    return CommonCardContainer(
      onTap: onTap,
      margin: spacing.listItemMargin,
      padding: spacing.listItemPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 内容预览
          Text(
            plainText,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: spacing.listItemSpacing),
          // 日期
          Text(
            note.noteDate,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
