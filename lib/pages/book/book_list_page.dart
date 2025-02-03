import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../drivers/driver_factory.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/user_book_vo.dart';
import '../../providers/books_provider.dart';
import '../../utils/toast_util.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/common_card_container.dart';
import '../../widgets/common/common_dialog.dart';
import '../../widgets/common/shared_badge.dart';
import '../../widgets/common/empty_data_view.dart';
import 'book_form_page.dart';

/// 账本列表页面
class BookListPage extends StatefulWidget {
  const BookListPage({super.key});

  @override
  State<BookListPage> createState() => _BookListPageState();
}

class _BookListPageState extends State<BookListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BooksProvider>().loadBooks(AppConfigManager.instance.userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: Text(L10nManager.l10n.accountBooks),
      ),
      body: Consumer<BooksProvider>(
        builder: (context, provider, child) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.books.isEmpty) {
            return EmptyDataView(
              icon: Icons.book_outlined,
              title: L10nManager.l10n.noAccountBooks,
              buttonText: L10nManager.l10n.addNew(L10nManager.l10n.accountBook),
              onButtonPressed: () => _showAccountBookForm(context),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                provider.loadBooks(AppConfigManager.instance.userId),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: provider.books.length,
              itemBuilder: (context, index) {
                final book = provider.books[index];
                return Dismissible(
                  key: Key(book.id),
                  direction: book.permission.canDeleteBook
                      ? DismissDirection.endToStart
                      : DismissDirection.none,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: Theme.of(context).colorScheme.onError,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    if (!book.permission.canDeleteBook) return false;

                    final result = await CommonDialog.showWarning(
                      context: context,
                      message:
                          '${L10nManager.l10n.deleteConfirmMessage(book.name)}\n${L10nManager.l10n.deleteBookWarning}',
                    );

                    if (result != true || !mounted) return false;

                    try {
                      final deleteResult = await context
                          .read<BooksProvider>()
                          .deleteBook(book.id);

                      if (!deleteResult) {
                        if (mounted) {
                          ToastUtil.showError(L10nManager.l10n.deleteFailed(
                            L10nManager.l10n.accountBook,
                            '',
                          ));
                        }
                        return false;
                      }
                      return true;
                    } catch (e) {
                      if (mounted) {
                        ToastUtil.showError(L10nManager.l10n.deleteFailed(
                          L10nManager.l10n.accountBook,
                          e.toString(),
                        ));
                      }
                      return false;
                    }
                  },
                  child: _AccountBookCard(
                    book: book,
                    userId: AppConfigManager.instance.userId,
                    onEdit: () => _showAccountBookForm(context, book),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAccountBookForm(context),
        icon: const Icon(Icons.add),
        label: Text(L10nManager.l10n.addNew(L10nManager.l10n.accountBook)),
      ),
    );
  }

  Future<void> _showAccountBookForm(BuildContext context,
      [UserBookVO? book]) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => BookFormPage(book: book),
      ),
    );
    if (result == true && mounted) {
      context.read<BooksProvider>().loadBooks(AppConfigManager.instance.userId);
    }
  }
}

/// 账本卡片
class _AccountBookCard extends StatelessWidget {
  final UserBookVO book;
  final String userId;
  final VoidCallback onEdit;

  const _AccountBookCard({
    required this.book,
    required this.userId,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isShared = book.createdBy != userId;

    return CommonCardContainer(
      onTap: onEdit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getBookIcon(book.icon),
                  size: 24,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            book.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (isShared && book.createdByName != null) ...[
                          const SizedBox(width: 8),
                          SharedBadge(name: book.createdByName!),
                        ],
                      ],
                    ),
                    if (book.description?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(
                        book.description!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  book.currencySymbol.symbol,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (book.members.isNotEmpty) ...[
                const SizedBox(width: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${book.members.length}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// 获取账本图标
IconData _getBookIcon(String? icon) {
  if (icon == null || icon.isEmpty) {
    return Icons.book_outlined;
  }
  // 这里可以根据icon字符串返回对应的图标
  return IconData(int.parse(icon), fontFamily: 'MaterialIcons');
}
