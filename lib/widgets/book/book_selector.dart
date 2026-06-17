import 'package:flutter/material.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/user_book_vo.dart';
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
    final result = await showDialog<UserBookVO>(
      context: context,
      useSafeArea: false,
      builder: (ctx) => _BookSelectorDialog(
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
    final bookName = book.name;

    return InkWell(
      onTap: _showBookSelector,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedBuilder(
        animation: _arrowAnimation,
        builder: (context, child) => Container(
          constraints: const BoxConstraints(maxWidth: 220),
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
                  bookName,
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

/// 账本选择弹窗
class _BookSelectorDialog extends StatefulWidget {
  final String userId;
  final List<UserBookVO> books;
  final UserBookVO? selectedBook;

  const _BookSelectorDialog({
    required this.userId,
    required this.books,
    this.selectedBook,
  });

  @override
  State<_BookSelectorDialog> createState() => _BookSelectorDialogState();
}

class _BookSelectorDialogState extends State<_BookSelectorDialog> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<UserBookVO> _filteredBooks = [];
  bool _showSearch = false;

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
    final isSelected = widget.selectedBook;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题栏 + 搜索切换
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: _showSearch
                      ? TextField(
                          controller: _searchCtrl,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: L10nManager.l10n.search,
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: theme.textTheme.titleMedium,
                        )
                      : Text(
                          L10nManager.l10n.selectAccountBook,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                IconButton(
                  icon: Icon(
                    _showSearch ? Icons.close : Icons.search,
                    size: 22,
                  ),
                  onPressed: () {
                    setState(() {
                      _showSearch = !_showSearch;
                      if (!_showSearch) {
                        _searchCtrl.clear();
                      }
                    });
                  },
                ),
              ],
            ),
          ),

          // 列表
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 380,
                minHeight: 100,
              ),
              child: _filteredBooks.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.search_off,
                                size: 40,
                                color: colorScheme.onSurfaceVariant.withAlpha(80)),
                            const SizedBox(height: 8),
                            Text(
                              L10nManager.l10n.noMatchingResults,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 8),
                      itemCount: _filteredBooks.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 2),
                      itemBuilder: (context, index) {
                        final book = _filteredBooks[index];
                        final isOwner =
                            book.createdBy == widget.userId;
                        final selected =
                            isSelected?.id == book.id;

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _select(book),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              decoration: BoxDecoration(
                                color: selected
                                    ? colorScheme.primaryContainer
                                        .withAlpha(120)
                                    : null,
                                borderRadius: BorderRadius.circular(12),
                                border: selected
                                    ? Border.all(
                                        color: colorScheme.primary
                                            .withAlpha(60),
                                      )
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  // 图标
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? colorScheme.primaryContainer
                                          : colorScheme
                                              .surfaceContainerHigh,
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _getBookIcon(book.icon),
                                      size: 20,
                                      color: selected
                                          ? colorScheme.onPrimaryContainer
                                          : colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // 名称 + 描述
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                book.name,
                                                style: theme
                                                    .textTheme.bodyLarge
                                                    ?.copyWith(
                                                  fontWeight:
                                                      FontWeight.w600,
                                                ),
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (!isOwner &&
                                                book.createdByName !=
                                                    null) ...[
                                              const SizedBox(width: 6),
                                              SharedBadge(
                                                  name:
                                                      book.createdByName!),
                                            ],
                                          ],
                                        ),
                                        if (book.description
                                                ?.isNotEmpty ==
                                            true)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 2),
                                            child: Text(
                                              book.description!,
                                              style: theme
                                                  .textTheme.bodySmall
                                                  ?.copyWith(
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                              maxLines: 1,
                                              overflow:
                                                  TextOverflow.ellipsis,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (selected)
                                    Icon(Icons.check_circle,
                                        size: 22,
                                        color: colorScheme.primary),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 获取账本图标
IconData _getBookIcon(String? icon) {
  if (icon == null || icon.isEmpty) {
    return Icons.book;
  }
  return IconData(int.parse(icon), fontFamily: 'MaterialIcons');
}
