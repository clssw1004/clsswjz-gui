import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'dart:convert';
import '../../models/vo/user_note_vo.dart';
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
    final spacing = theme.spacing;
    final plainText = _getPlainText(note.content);

    return SizedBox(
      width: double.infinity,
      child: CommonCardContainer(
        onTap: onTap,
        margin: spacing.listItemMargin,
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
                // 右侧图标
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
