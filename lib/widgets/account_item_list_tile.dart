import 'package:flutter/material.dart';
import '../models/vo/account_item_vo.dart';

/// 账目列表项
class AccountItemListTile extends StatelessWidget {
  /// 账目数据
  final AccountItemVO item;

  /// 货币符号
  final String currencySymbol;

  const AccountItemListTile({
    super.key,
    required this.item,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 解析时间
    final time = DateTime.parse(item.accountDate);
    final timeString = '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧内容
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 分类
                if (item.categoryName != null)
                  Text(
                    item.categoryName!,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                // 描述
                if (item.description != null && item.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      item.description!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
          // 右侧金额
          Text(
            '${item.type == 'EXPENSE' ? '-' : '+'}${currencySymbol}${item.amount.toStringAsFixed(2)}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: item.type == 'EXPENSE'
                  ? colorScheme.error
                  : colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      // 底部信息行
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            // 左侧账户和商户
            Expanded(
              child: Row(
                children: [
                  if (item.fundName != null) ...[
                    Icon(
                      Icons.account_balance_wallet,
                      size: 16,
                      color: colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.fundName!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (item.shopName != null) ...[
                    Icon(
                      Icons.store,
                      size: 16,
                      color: colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.shopName!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // 右侧创建人和时间
            if (item.createdByName != null) ...[
              Text(
                item.createdByName!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              timeString,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
