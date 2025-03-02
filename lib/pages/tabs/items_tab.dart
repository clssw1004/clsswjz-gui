import 'package:clsswjz/providers/debt_list_provider.dart';
import 'package:clsswjz/providers/item_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../manager/app_config_manager.dart';
import '../../providers/books_provider.dart';
import '../../providers/sync_provider.dart';
import '../../utils/navigation_util.dart';
import '../../widgets/book/book_selector.dart';
import '../../widgets/book/book_statistic_card.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/book/items_container.dart';
import '../../widgets/book/debts_container.dart';
import '../../routes/app_routes.dart';

/// 账目列表标签页
class ItemsTab extends StatefulWidget {
  const ItemsTab({super.key});

  @override
  State<ItemsTab> createState() => _ItemsTabState();
}

class _ItemsTabState extends State<ItemsTab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BooksProvider>().loadBooks(AppConfigManager.instance.userId);
    });
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ItemListProvider>();
      provider.loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        showBackButton: false,
        title: Consumer<BooksProvider>(
          builder: (context, provider, child) {
            return BookSelector(
              key: ValueKey(provider.selectedBook?.id),
              userId: AppConfigManager.instance.userId,
              books: provider.books,
              selectedBook: provider.selectedBook,
              onSelected: (book) {
                provider.setSelectedBook(book);
              },
            );
          },
        ),
      ),
      body: Consumer4<BooksProvider, ItemListProvider, DebtListProvider,
          SyncProvider>(
        builder: (context, bookProvider, itemListProvider, debtListProvider,
            syncProvider, child) {
          final accountBook = bookProvider.selectedBook;
          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.only(bottom: 16),
                children: [
                  // 账本统计卡片
                  BookStatisticCard(
                    statisticInfo: bookProvider.statisticInfo,
                    onTap: () => bookProvider.loadStatisticInfo(),
                    mode: StatisticCardMode.lastDay,
                  ),

                  // 最近账目
                  ItemsContainer(
                    accountBook: accountBook,
                    items: itemListProvider.items.take(3).toList(),
                    loading: itemListProvider.loading,
                    onItemTap: (item) {
                      NavigationUtil.toItemEdit(context, item);
                    },
                  ),

                  // 债务信息
                  DebtsContainer(
                    debts: debtListProvider.debts.take(3).toList(),
                    bookMeta: bookProvider.selectedBook,
                    loading: debtListProvider.loading,
                    onItemTap: (debt) {
                      NavigationUtil.toDebtEdit(context, debt);
                    },
                    onRefresh: () => debtListProvider.loadDebts(),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
