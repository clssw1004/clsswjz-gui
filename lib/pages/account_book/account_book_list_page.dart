import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../manager/user_config_manager.dart';
import '../../models/vo/user_book_vo.dart';
import '../../providers/account_books_provider.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/common_card_container.dart';
import '../../widgets/common/shared_badge.dart';
import 'account_book_form_page.dart';

/// 账本列表页面
class AccountBookListPage extends StatefulWidget {
  const AccountBookListPage({
    super.key,
  });

  @override
  State<AccountBookListPage> createState() => _AccountBookListPageState();
}

class _AccountBookListPageState extends State<AccountBookListPage> {
  @override
  void initState() {
    super.initState();
    // 加载账本列表
    context
        .read<AccountBooksProvider>()
        .loadBooks(UserConfigManager.currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(l10n.accountBooks),
      ),
      body: Consumer<AccountBooksProvider>(
        builder: (context, provider, child) {
          if (provider.loading && provider.books.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.books.isEmpty) {
            return Center(
              child: Text(
                provider.error!,
                style: TextStyle(color: colorScheme.error),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.refresh(UserConfigManager.currentUserId),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.books.length,
              itemBuilder: (context, index) {
                final book = provider.books[index];
                return _AccountBookCard(
                  book: book,
                  userId: UserConfigManager.currentUserId,
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push<bool>(
            MaterialPageRoute(
              builder: (context) => const AccountBookFormPage(),
            ),
          )
              .then((created) {
            if (created == true) {
              context
                  .read<AccountBooksProvider>()
                  .refresh(UserConfigManager.currentUserId);
            }
          });
        },
        tooltip: l10n.addNew(l10n.accountBook),
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// 账本卡片
class _AccountBookCard extends StatelessWidget {
  final UserBookVO book;
  final String userId;

  const _AccountBookCard({
    required this.book,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isShared = book.createdBy != userId;

    return CommonCardContainer(
      onTap: () {
        Navigator.of(context)
            .push<bool>(
          MaterialPageRoute(
            builder: (context) => AccountBookFormPage(book: book),
          ),
        )
            .then((updated) {
          if (updated == true) {
            context
                .read<AccountBooksProvider>()
                .refresh(UserConfigManager.currentUserId);
          }
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getBookIcon(book.icon),
                  size: 20,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            book.name,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        if (isShared && book.createdByName != null)
                          SharedBadge(name: book.createdByName!),
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
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.outline.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  book.currencySymbol,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              if (book.members.isNotEmpty) ...[
                const SizedBox(width: 12),
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
    return Icons.book;
  }
  // 这里可以根据icon字符串返回对应的图标
  return IconData(int.parse(icon), fontFamily: 'MaterialIcons');
}
