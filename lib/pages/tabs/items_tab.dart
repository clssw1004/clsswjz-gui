import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../providers/books_provider.dart';
import '../../providers/debt_list_provider.dart';
import '../../providers/item_list_provider.dart';
import '../../providers/statistics_provider.dart';
import '../../providers/sync_provider.dart';
import '../../utils/navigation_util.dart';
import '../../widgets/book/book_selector.dart';
import '../../widgets/book/book_statistic_card.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/item_widgets/items_container.dart';
import '../../widgets/item_widgets/debts_container.dart';
import '../../widgets/item_widgets/daily_statistic_bar.dart';
import '../../widgets/item_widgets/daily_statistic_calendar.dart';
  import '../../widgets/item_widgets/user_monthly_statistic_chart.dart';

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
      final itemProvider = context.read<ItemListProvider>();
      itemProvider.loadItems();
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
                // 切换账本时重新加载统计数据
                context
                    .read<StatisticsProvider>()
                    .loadBookStatisticInfo(book.id);
                // 加载每日统计数据
                context.read<StatisticsProvider>().loadDailyStatistics(book.id);
                  // 加载按用户当月统计（受配置控制）
                  if (AppConfigManager.instance.uiConfig.itemTabShowUserMonthly) {
                    context.read<StatisticsProvider>().loadUserMonthlyStatistics(book.id);
                  }
              },
            );
          },
        ),
      ),
      body: Consumer5<BooksProvider, ItemListProvider, DebtListProvider,
          SyncProvider, StatisticsProvider>(
        builder: (context, bookProvider, itemListProvider, debtListProvider,
            syncProvider, statisticsProvider, child) {
          final bookMeta = bookProvider.selectedBook;
          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                children: [
                  // 账本统计卡片
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: BookStatisticCard(
                      statisticInfo: statisticsProvider.currentMonthStatistic,
                      showBalance: false,
                      title: L10nManager.l10n.currentMonth,
                    ),
                  ),

                  // 最近账目
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: ItemsContainer(
                      accountBook: bookMeta,
                      lastDate: itemListProvider.lastDay,
                      items: itemListProvider.lastDayItems,
                      loading: itemListProvider.loading,
                      onItemTap: (item) {
                        NavigationUtil.toItemEdit(context, item);
                      },
                    ),
                  ),

                  // 每日统计卡片（柱状图） - 根据配置决定是否显示
                  if (AppConfigManager.instance.uiConfig.itemTabShowDailyBar)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: DailyStatisticBar(
                        dailyStats: statisticsProvider.dailyStatistics ?? [],
                        loading: statisticsProvider.loadingDailyStatistics,
                      ),
                    ),

                  // 每日统计（日历） - 根据配置决定是否显示
                  if (AppConfigManager.instance.uiConfig.itemTabShowDailyCalendar)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: DailyStatisticCalendar(
                        dailyStats: statisticsProvider.dailyStatistics ?? [],
                        loading: statisticsProvider.loadingDailyStatistics,
                      ),
                    ),

                  // 按用户当月统计（双Y轴柱状图） - 根据配置决定是否显示
                  if (AppConfigManager.instance.uiConfig.itemTabShowUserMonthly)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: UserMonthlyStatisticChart(
                        data: statisticsProvider.userMonthlyStatistics ?? [],
                        loading: statisticsProvider.loadingUserMonthly,
                      ),
                    ),

                  // 债务信息 - 根据配置决定是否显示
                  if (AppConfigManager.instance.uiConfig.itemTabShowDebt)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: DebtsContainer(
                        debts: debtListProvider.debts.take(3).toList(),
                        bookMeta: bookProvider.selectedBook,
                        loading: debtListProvider.loading,
                        onItemTap: (debt) {
                          NavigationUtil.toDebtEdit(context, debt);
                        },
                        onRefresh: () => debtListProvider.loadDebts(),
                      ),
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
