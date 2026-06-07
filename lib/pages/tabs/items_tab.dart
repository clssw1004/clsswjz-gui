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
import '../../models/vo/book_meta.dart';
import '../../widgets/book/book_selector.dart';
import '../../widgets/book/book_statistic_card.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/item_widgets/items_container.dart';
import '../../widgets/item_widgets/debts_container.dart';
import '../../widgets/item_widgets/daily_statistic_bar.dart';
import '../../widgets/item_widgets/daily_statistic_calendar.dart';
import '../../widgets/item_widgets/user_monthly_statistic_chart.dart';
import '../../providers/activity_checkin_provider.dart';
import '../../routes/app_routes.dart';
import '../../theme/theme_spacing.dart';
import '../../widgets/activity/activity_recent_records.dart';

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
      // 加载本月统计数据（固定使用本月范围，不受统计页面影响）
      final bookId = context.read<BooksProvider>().selectedBook?.id;
      if (bookId != null) {
        context.read<StatisticsProvider>().loadItemTabStatistics(bookId);
      }
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
                // 切换账本时重新加载统计数据（固定使用本月范围，不受统计页面影响）
                context
                    .read<StatisticsProvider>()
                    .loadItemTabStatistics(book.id);
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
          final spacing = Theme.of(context).spacing;
          // 加载最近打卡
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final p = context.read<ActivityCheckinProvider>();
            p.loadRecentRecords();
            p.loadDefinitions();
          });

          return Stack(
            children: [
              ListView(
                padding: spacing.contentPadding,
                children: [
                  // 账本统计卡片
                  Padding(
                    padding: EdgeInsets.only(bottom: spacing.formItemSpacing),
                    child: BookStatisticCard(
                      statisticInfo: statisticsProvider.itemTabMonthStatistic,
                      showBalance: false,
                      title: L10nManager.l10n.currentMonth,
                      margin: EdgeInsets.zero,
                    ),
                  ),

                  // 最近账目
                  Padding(
                    padding: EdgeInsets.only(bottom: spacing.formItemSpacing),
                    child: ItemsContainer(
                      accountBook: bookMeta,
                      lastDate: itemListProvider.lastDay,
                      items: itemListProvider.lastDayItems,
                      loading: itemListProvider.loading,
                      onItemTap: (item) {
                        NavigationUtil.toItemEdit(context, item);
                      },
                      margin: EdgeInsets.zero,
                    ),
                  ),

                  ..._buildOrderedComponents(
                    bookMeta: bookMeta,
                    spacing: spacing,
                    statisticsProvider: statisticsProvider,
                    debtListProvider: debtListProvider,
                    bookProvider: bookProvider,
                    context: context,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  /// 根据配置顺序渲染记账页统计组件
  List<Widget> _buildOrderedComponents({
    required BookMetaVO? bookMeta,
    required ThemeSpacing spacing,
    required StatisticsProvider statisticsProvider,
    required DebtListProvider debtListProvider,
    required BooksProvider bookProvider,
    required BuildContext context,
  }) {
    final order = AppConfigManager.instance.uiConfig.itemTabComponentOrder;
    final widgets = <Widget>[];

    for (final key in order) {
      switch (key) {
        case 'daily_bar':
          if (AppConfigManager.instance.uiConfig.itemTabShowDailyBar) {
            widgets.add(Padding(
              padding: EdgeInsets.only(bottom: spacing.formItemSpacing),
              child: DailyStatisticBar(
                dailyStats: statisticsProvider.dailyStatistics ?? [],
                loading: statisticsProvider.loadingDailyStatistics,
              ),
            ));
          }
          break;
        case 'daily_calendar':
          if (AppConfigManager.instance.uiConfig.itemTabShowDailyCalendar) {
            widgets.add(Padding(
              padding: EdgeInsets.only(bottom: spacing.formItemSpacing),
              child: DailyStatisticCalendar(
                dailyStats: statisticsProvider.dailyStatistics ?? [],
                loading: statisticsProvider.loadingDailyStatistics,
              ),
            ));
          }
          break;
        case 'user_monthly':
          if (AppConfigManager.instance.uiConfig.itemTabShowUserMonthly) {
            widgets.add(Padding(
              padding: EdgeInsets.only(bottom: spacing.formItemSpacing),
              child: UserMonthlyStatisticChart(
                data: statisticsProvider.userMonthlyStatistics ?? [],
                loading: statisticsProvider.loadingUserMonthly,
              ),
            ));
          }
          break;
        case 'activity_recent':
          widgets.add(
            Consumer<ActivityCheckinProvider>(
              builder: (context, provider, _) {
                return Padding(
                  padding: EdgeInsets.only(bottom: spacing.formItemSpacing),
                  child: ActivityRecentRecords(
                    definitions: provider.definitions,
                    todayCounts: provider.todayCounts,
                    onViewAll: () => Navigator.pushNamed(
                        context, AppRoutes.activityCheckin),
                  ),
                );
              },
            ),
          );
          break;
        case 'debt':
          if (AppConfigManager.instance.uiConfig.itemTabShowDebt) {
            widgets.add(Padding(
              padding: EdgeInsets.only(bottom: spacing.formItemSpacing),
              child: DebtsContainer(
                debts: debtListProvider.debts.take(3).toList(),
                bookMeta: bookProvider.selectedBook,
                loading: debtListProvider.loading,
                onItemTap: (debt) {
                  NavigationUtil.toDebtEdit(context, debt);
                },
                onRefresh: () => debtListProvider.loadDebts(),
              ),
            ));
          }
          break;
      }
    }

    return widgets;
  }
}
