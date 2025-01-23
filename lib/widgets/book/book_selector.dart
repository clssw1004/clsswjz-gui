import 'package:flutter/material.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/user_book_vo.dart';
import '../common/common_dialog.dart';
import '../common/shared_badge.dart';

/// 账本选择组件
class BookSelector extends StatefulWidget {
  /// 用户ID
  final String userId;

  /// 选中的账本
  final UserBookVO? selectedBook;

  /// 账本列表
  final List<UserBookVO> books;

  /// 选中账本回调
  final void Function(UserBookVO book)? onSelected;

  const BookSelector({
    super.key,
    required this.userId,
    required this.books,
    this.selectedBook,
    this.onSelected,
  });

  @override
  State<BookSelector> createState() => _BookSelectorState();
}

class _BookSelectorState extends State<BookSelector> {
  /// 显示账本选择弹窗
  Future<void> _showBookSelector() async {
    final result = await CommonDialog.show<UserBookVO>(
      context: context,
      title: L10nManager.l10n.selectAccountBook,
      width: 320,
      content: _AccountBookList(
        userId: widget.userId,
        books: widget.books,
      ),
    );

    if (result != null && mounted) {
      widget.onSelected?.call(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (widget.selectedBook == null) {
      return Text(L10nManager.l10n.noAccountBooks);
    }

    final isOwner = widget.selectedBook!.createdBy == widget.userId;
    final bookName = isOwner ? widget.selectedBook!.name : '${widget.selectedBook!.name} (${widget.selectedBook!.createdByName})';

    return InkWell(
      onTap: _showBookSelector,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getBookIcon(widget.selectedBook!.icon),
              size: 20,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                bookName,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

/// 账本列表
class _AccountBookList extends StatelessWidget {
  final String userId;
  final List<UserBookVO> books;

  const _AccountBookList({
    required this.userId,
    required this.books,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxHeight: 400,
      ),
      child: books.isEmpty
          ? Center(child: Text(L10nManager.l10n.noAccountBooks))
          : ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: books.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final book = books[index];
                return ListTile(
                  leading: Icon(
                    _getBookIcon(book.icon),
                    color: colorScheme.primary,
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(book.name),
                      ),
                      if (book.createdBy != userId && book.createdByName != null) SharedBadge(name: book.createdByName!),
                    ],
                  ),
                  subtitle: book.description?.isNotEmpty == true
                      ? Text(
                          book.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : null,
                  onTap: () async {
                    await AppConfigManager.instance.setDefaultBookId(book.id);
                    Navigator.of(context).pop(book);
                  },
                );
              },
            ),
    );
  }
}

/// 获取账本图标
IconData _getBookIcon(String? icon) {
  if (icon == null || icon.isEmpty) {
    return Icons.book;
  }
  // 这里可以根据icon字符串返回对应的图标
  return IconData(int.parse(icon), fontFamily: 'MaterialIcons');
}
