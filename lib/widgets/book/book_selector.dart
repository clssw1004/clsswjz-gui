import 'package:flutter/material.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/user_book_vo.dart';
import '../../constants/account_book_icons.dart';
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

class _BookSelectorState extends State<BookSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _arrowController;
  late Animation<double> _arrowAnimation;

  @override
  void initState() {
    super.initState();
    _arrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _arrowAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _arrowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _arrowController.dispose();
    super.dispose();
  }

  Future<void> _showBookSelector() async {
    _arrowController.forward();
    final result = await showModalBottomSheet<UserBookVO>(
      context: context,
      isScrollControlled: true,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _BookSelectorSheet(
        userId: widget.userId,
        books: widget.books,
        selectedBook: widget.selectedBook,
      ),
    );
    if (mounted) _arrowController.reverse();
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

    final book = widget.selectedBook!;
    final isOwner = book.createdBy == widget.userId;

    return InkWell(
      onTap: _showBookSelector,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedBuilder(
        animation: _arrowAnimation,
        builder: (context, child) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outlineVariant.withAlpha(80),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getBookIcon(book.icon),
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  book.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              if (!isOwner && book.createdByName != null) ...[
                const SizedBox(width: 6),
                SharedBadge(name: book.createdByName!),
              ],
              const SizedBox(width: 4),
              Transform.rotate(
                angle: _arrowAnimation.value * 3.14159,
                child: Icon(
                  Icons.arrow_drop_down,
                  size: 22,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 账本选择底部抽屉
class _BookSelectorSheet extends StatefulWidget {
  final String userId;
  final List<UserBookVO> books;
  final UserBookVO? selectedBook;

  const _BookSelectorSheet({
    required this.userId,
    required this.books,
    this.selectedBook,
  });

  @override
  State<_BookSelectorSheet> createState() => _BookSelectorSheetState();
}

class _BookSelectorSheetState extends State<_BookSelectorSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<UserBookVO> _filteredBooks = [];

  @override
  void initState() {
    super.initState();
    _filteredBooks = widget.books;
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filteredBooks = q.isEmpty
          ? widget.books
          : widget.books.where((b) {
              return b.name.toLowerCase().contains(q) ||
                  (b.description?.toLowerCase().contains(q) ?? false) ||
                  (b.createdByName?.toLowerCase().contains(q) ?? false);
            }).toList();
    });
  }

  void _select(UserBookVO book) {
    AppConfigManager.instance.setDefaultBookId(book.id);
    Navigator.of(context).pop(book);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            // 拖拽指示条
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurfaceVariant.withAlpha(50),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // 标题
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      L10nManager.l10n.selectAccountBook,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 搜索框
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _searchCtrl,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: L10nManager.l10n.search,
                  prefixIcon:
                      Icon(Icons.search, color: colorScheme.primary, size: 22),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () => _searchCtrl.clear(),
                        )
                      : null,
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest.withAlpha(40),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            // 分割线
            if (_filteredBooks.isNotEmpty)
              Divider(height: 1, color: colorScheme.outline.withAlpha(20)),
            // 列表
            Expanded(
              child: _filteredBooks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inbox_outlined,
                              size: 40,
                              color: colorScheme.onSurfaceVariant.withAlpha(60)),
                          const SizedBox(height: 8),
                          Text(
                            L10nManager.l10n.noMatchingResults,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant.withAlpha(100),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.only(top: 4, bottom: 12),
                      children: _filteredBooks.map((book) {
                        final isOwner = book.createdBy == widget.userId;
                        final selected =
                            widget.selectedBook?.id == book.id;

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 1),
                          child: Container(
                            decoration: BoxDecoration(
                              color: selected
                                  ? colorScheme.primary.withAlpha(10)
                                  : null,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 2),
                              leading: Icon(
                                _getBookIcon(book.icon),
                                size: 22,
                                color: selected
                                    ? colorScheme.primary
                                    : colorScheme.outline.withAlpha(60),
                              ),
                              title: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      book.name,
                                      style: theme
                                          .textTheme.bodyMedium
                                          ?.copyWith(
                                        fontWeight: selected
                                            ? FontWeight.w600
                                            : null,
                                        color: selected
                                            ? colorScheme.primary
                                            : null,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (!isOwner && book.createdByName != null)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 6),
                                      child: SharedBadge(
                                          name: book.createdByName!),
                                    ),
                                ],
                              ),
                              subtitle: book.description?.isNotEmpty == true
                                  ? Text(
                                      book.description!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : null,
                              trailing: selected
                                  ? Icon(Icons.check_circle_rounded,
                                      size: 22, color: colorScheme.primary)
                                  : null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              onTap: () => _select(book),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 获取账本图标
IconData _getBookIcon(String? icon) {
  return getIconByCode(icon);
}
