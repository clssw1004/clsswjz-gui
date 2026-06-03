import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/user_book_vo.dart';
import '../../providers/books_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/theme_spacing.dart';
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
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Scaffold(
      appBar: CommonAppBar(
        title: Text(L10nManager.l10n.accountBooks),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => Navigator.pushNamed(context, AppRoutes.import),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.file_upload_outlined, size: 20, color: onSurface),
                    const SizedBox(width: 4),
                    Text(
                      L10nManager.l10n.import,
                      style: TextStyle(fontSize: 14, color: onSurface),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<BooksProvider>(
        builder: (context, provider, child) {
          final spacing = Theme.of(context).spacing;
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.books.isEmpty) {
            return EmptyDataView(
              icon: Icons.book_outlined,
              title: L10nManager.l10n.noAccountBooks,
              buttonText:
                  L10nManager.l10n.addNew(L10nManager.l10n.accountBook),
              onButtonPressed: () => _showAccountBookForm(context),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                provider.loadBooks(AppConfigManager.instance.userId),
            child: ListView.builder(
              padding: spacing.contentPadding,
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
                    padding: EdgeInsets.only(right: spacing.formItemSpacing),
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
                    await _deleteBook(context, book, provider);
                    return false;
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

  Future<void> _deleteBook(
      BuildContext context, UserBookVO book, BooksProvider provider) async {
    if (!book.permission.canDeleteBook) return;

    final result = await CommonDialog.showWarning(
      context: context,
      message:
          '${L10nManager.l10n.deleteConfirmMessage(book.name)}\n${L10nManager.l10n.deleteBookWarning}',
    );

    if (result != true || !mounted) return;

    try {
      final deleteResult = await provider.deleteBook(book.id);
      if (!deleteResult) {
        if (mounted) {
          ToastUtil.showError(L10nManager.l10n.deleteFailed(
            L10nManager.l10n.accountBook,
            '',
          ));
        }
      }
    } catch (e) {
      if (mounted) {
        ToastUtil.showError(L10nManager.l10n.deleteFailed(
          L10nManager.l10n.accountBook,
          e.toString(),
        ));
      }
    }
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
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      onTap: onEdit,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 账本图标
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getBookIcon(book.icon),
              size: 22,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 14),
          // 右侧内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题行
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        book.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isShared && book.createdByName != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: SharedBadge(name: book.createdByName!),
                      ),
                  ],
                ),
                // 描述
                if (book.description?.isNotEmpty == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      book.description!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 10),
                // 底部元数据
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        book.currencySymbol.symbol,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (book.members.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${book.members.length}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const Spacer(),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: colorScheme.onSurfaceVariant.withAlpha(80),
                    ),
                  ],
                ),
              ],
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
    return Icons.book_outlined;
  }
  return IconData(int.parse(icon), fontFamily: 'MaterialIcons');
}
