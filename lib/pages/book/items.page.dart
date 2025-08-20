import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../manager/l10n_manager.dart';
import '../../models/dto/item_filter_dto.dart';
import '../../models/vo/book_meta.dart';
import '../../models/vo/user_item_vo.dart';
import '../../providers/items_provider.dart';
import '../../utils/navigation_util.dart';
import '../../widgets/book/items_list_view.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/common_search_field.dart';

/// 展示账目列表的通用页面（用于按条件查看账目）
class ItemsPage extends StatefulWidget {
  final BookMetaVO bookMeta;
  final ItemFilterDTO? initialFilter;
  final String? title;

  const ItemsPage({super.key, required this.bookMeta, this.initialFilter, this.title});

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 初始化后触发一次加载，注意要使用 builder 内的 context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 这里的 context 是 ItemsPage，自身未必能读取到 Provider，加载逻辑放到 builder 中执行
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(BuildContext context) {
    context.read<ItemsProvider>().setKeyword(_searchController.text);
  }

  void _onTapItem(UserItemVO item) {
    NavigationUtil.toItemEdit(context, item);
  }

  Future<void> _showSearchDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(L10nManager.l10n.search),
          content: SizedBox(
            width: 320,
            child: CommonSearchField(
              width: 320,
              controller: _searchController,
              hintText: L10nManager.l10n.search,
              autofocus: true,
              onSubmitted: (_) {
                _handleSearch(context);
                Navigator.of(ctx).pop();
              },
              onClear: () => _handleSearch(context),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(L10nManager.l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                _handleSearch(context);
                Navigator.of(ctx).pop();
              },
              child: Text(L10nManager.l10n.search),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ItemsProvider>(
      create: (_) {
        final p = ItemsProvider(
          bookMeta: widget.bookMeta,
          initialFilter: widget.initialFilter,
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          p.loadItems(refresh: true);
        });
        return p;
      },
      builder: (context, _) {
        final screenWidth = MediaQuery.of(context).size.width;
        final searchFieldWidth = (screenWidth * 0.28) > 240 ? 240.0 : (screenWidth * 0.28);
        return Scaffold(
          appBar: CommonAppBar(
            title: Text(
              widget.title ?? L10nManager.l10n.tabAccountItems,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
            actions: [
              if (screenWidth >= 420)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CommonSearchField(
                    width: searchFieldWidth,
                    controller: _searchController,
                    hintText: L10nManager.l10n.search,
                    onSubmitted: (_) => _handleSearch(context),
                    onClear: () => _handleSearch(context),
                  ),
                )
              else
                IconButton(
                  tooltip: L10nManager.l10n.search,
                  onPressed: () => _showSearchDialog(context),
                  icon: const Icon(Icons.search),
                ),
            ],
          ),
          body: Consumer<ItemsProvider>(
            builder: (context, provider, child) {
              return ItemsListView(
                accountBook: widget.bookMeta,
                onItemTap: _onTapItem,
                onDelete: (item) async {
                  final ok = await provider.deleteItem(item);
                  return ok;
                },
              );
            },
          ),
        );
      },
    );
  }
}

 
