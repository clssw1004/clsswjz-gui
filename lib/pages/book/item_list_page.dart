import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import '../../enums/item_view_mode.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/user_book_vo.dart';
import '../../models/vo/user_item_vo.dart';
import '../../providers/item_list_provider.dart';
import '../../providers/sync_provider.dart';
import '../../routes/app_routes.dart';
import '../../utils/navigation_util.dart';
import '../../widgets/book/item_list_advance.dart';
import '../../widgets/book/item_list_timeline.dart';
import '../../widgets/book/item_list_calendar.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/progress_indicator_bar.dart';
import '../../widgets/book/item_filter_sheet.dart';
import '../../models/vo/book_meta.dart';
import '../../manager/service_manager.dart';
import '../../widgets/common/common_search_field.dart';

class ItemListPage extends StatefulWidget {
  final UserBookVO accountBook;

  const ItemListPage({
    super.key,
    required this.accountBook,
  });

  @override
  State<ItemListPage> createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  bool _isRefreshing = false;
  ItemViewMode _viewMode = ItemViewMode.advance;
  late BookMetaVO _bookMeta;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initBookMeta();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initBookMeta() async {
    final meta =
        await ServiceManager.accountBookService.toBookMeta(widget.accountBook);
    if (mounted) {
      setState(() {
        _bookMeta = meta!;
      });
    }
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);

    try {
      final syncProvider = context.read<SyncProvider>();
      await syncProvider.syncData();
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  void _handleSearch() {
    final provider = context.read<ItemListProvider>();
    provider.setKeyword(_searchController.text);
  }

  /// 显示筛选面板
  void _showFilterSheet() {
    final provider = context.read<ItemListProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ItemFilterSheet(
            initialFilter: provider.filter,
            selectedBook: _bookMeta,
            onConfirm: (filter) {
              provider.setFilter(filter);
            },
            onClear: () {
              provider.setFilter(null);
            },
          ),
        ),
      ),
    );
  }

  /// 构建视图切换按钮
  Widget _buildViewModeButton(ThemeData theme) {
    return PopupMenuButton<ItemViewMode>(
      icon: Icon(
        _viewMode == ItemViewMode.advance
            ? Icons.view_agenda
            : _viewMode == ItemViewMode.timeline
                ? Icons.timeline
                : Icons.calendar_month,
        color: theme.colorScheme.primary,
      ),
      onSelected: (mode) {
        setState(() {
          _viewMode = mode;
        });
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: ItemViewMode.advance,
          child: Row(
            children: [
              Icon(
                Icons.view_agenda,
                color: _viewMode == ItemViewMode.advance
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
              const SizedBox(width: 8),
              Text(L10nManager.l10n.advanceMode),
            ],
          ),
        ),
        PopupMenuItem(
          value: ItemViewMode.timeline,
          child: Row(
            children: [
              Icon(
                Icons.timeline,
                color: _viewMode == ItemViewMode.timeline
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
              const SizedBox(width: 8),
              Text(L10nManager.l10n.timelineMode),
            ],
          ),
        ),
        PopupMenuItem(
          value: ItemViewMode.calendar,
          child: Row(
            children: [
              Icon(
                Icons.calendar_month,
                color: _viewMode == ItemViewMode.calendar
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
              const SizedBox(width: 8),
              Text(L10nManager.l10n.calendarMode),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建账目列表
  Widget _buildItemList() {
    final provider = context.read<ItemListProvider>();

    switch (_viewMode) {
      case ItemViewMode.advance:
        return ItemListAdvance(
          accountBook: widget.accountBook,
          onItemTap: (item) {
            _onTabItem(provider, item);
          },
          onDelete: (item) async {
            await provider.deleteItem(item);
            return true;
          },
        );
      case ItemViewMode.timeline:
        return ItemListTimeline(
          accountBook: widget.accountBook,
          onItemTap: (item) {
            _onTabItem(provider, item);
          },
        );
      case ItemViewMode.calendar:
        return ItemListCalendar(
          accountBook: widget.accountBook,
          onItemTap: (item) {
            _onTabItem(provider, item);
          },
        );
    }
  }

  void _onTabItem(ItemListProvider itemListProvider, UserItemVO item) {
    NavigationUtil.toItemEdit(context, item);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(L10nManager.l10n.tabAccountItems),
        actions: [
          // 搜索框
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CommonSearchField(
              width: size.width * 0.35,
              controller: _searchController,
              hintText: L10nManager.l10n.search,
              onSubmitted: (_) => _handleSearch(),
              onClear: _handleSearch,
            ),
          ),
          // 筛选按钮
          IconButton(
            onPressed: _showFilterSheet,
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if (context.read<ItemListProvider>().filter?.isNotEmpty == true)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: L10nManager.l10n.more,
          ),
          // 视图切换按钮
          _buildViewModeButton(theme),
        ],
      ),
      body: Consumer2<ItemListProvider, SyncProvider>(
        builder: (context, itemListProvider, syncProvider, child) {
          return Stack(
            children: [
              CustomRefreshIndicator(
                onRefresh: _handleRefresh,
                builder: (context, child, controller) => child,
                child: _buildItemList(),
              ),
              // 同步进度条
              if (syncProvider.syncing && syncProvider.currentStep != null)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ProgressIndicatorBar(
                    value: syncProvider.progress,
                    label: syncProvider.currentStep!,
                    height: 24,
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppRoutes.itemAdd,
            arguments: [widget.accountBook],
          ).then((added) {
            if (added == true) {
              context.read<ItemListProvider>().loadItems();
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
