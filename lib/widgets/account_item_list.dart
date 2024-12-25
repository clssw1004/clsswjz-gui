import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/vo/account_item_vo.dart';
import '../services/account_item_service.dart';
import 'account_item_list_tile.dart';

/// 账目列表
class AccountItemList extends StatefulWidget {
  /// 账本ID
  final String accountBookId;

  /// 初始账目列表
  final List<AccountItemVO>? initialItems;

  /// 点击账目回调
  final void Function(AccountItemVO item)? onItemTap;

  const AccountItemList({
    super.key,
    required this.accountBookId,
    this.initialItems,
    this.onItemTap,
  });

  @override
  State<AccountItemList> createState() => _AccountItemListState();
}

class _AccountItemListState extends State<AccountItemList> {
  /// 账目列表
  List<AccountItemVO>? _items;

  /// 账目服务
  final _accountItemService = AccountItemService();

  @override
  void initState() {
    super.initState();
    _items = widget.initialItems;
    if (_items == null) {
      _loadItems();
    }
  }

  @override
  void didUpdateWidget(AccountItemList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.accountBookId != widget.accountBookId) {
      _loadItems();
    }
  }

  /// 加载账目列表
  Future<void> _loadItems() async {
    final result = await _accountItemService.getByAccountBookId(
      widget.accountBookId,
    );
    if (result.ok && mounted) {
      setState(() {
        _items = result.data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    if (_items == null) {
      return Center(child: Text(l10n.loading));
    }

    if (_items!.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long,
              size: 48,
              color: colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noAccountItems,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _items!.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = _items![index];
        return InkWell(
          onTap:
              widget.onItemTap == null ? null : () => widget.onItemTap!(item),
          child: AccountItemListTile(item: item),
        );
      },
    );
  }
}
