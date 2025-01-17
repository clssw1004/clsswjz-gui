import 'package:clsswjz/manager/app_config_manager.dart';
import 'package:flutter/material.dart';
import '../models/vo/account_item_vo.dart';
import '../utils/color_util.dart';

/// 账目列表项
class AccountItemTileAdvance extends StatelessWidget {
  /// 账目数据
  final AccountItemVO item;

  /// 货币符号
  final String currencySymbol;

  /// 在列表中的索引
  final int index;

  const AccountItemTileAdvance({
    super.key,
    required this.item,
    required this.currencySymbol,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 解析时间
    final time = DateTime.parse(item.accountDate);
    final timeString = '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      color: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部分类和金额
              Row(
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
                              fontWeight: FontWeight.w500,
                              height: 1.2,
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
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 右侧金额
                  Text(
                    item.amount.toStringAsFixed(2),
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: ColorUtil.getAmountColor(item.type),
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 底部信息行
              DefaultTextStyle(
                style: theme.textTheme.bodySmall!.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.2,
                ),
                child: Row(
                  children: [
                    // 左侧账户和商户
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (item.fundName != null)
                            _buildInfoChip(
                              context,
                              Icons.account_balance_wallet,
                              item.fundName!,
                              colorScheme.surfaceVariant,
                              colorScheme.onSurfaceVariant,
                            ),
                          if (item.shopName != null)
                            _buildInfoChip(
                              context,
                              Icons.store,
                              item.shopName!,
                              colorScheme.surfaceVariant,
                              colorScheme.onSurfaceVariant,
                            ),
                          if (item.projectName != null)
                            _buildInfoChip(
                              context,
                              Icons.folder_outlined,
                              item.projectName!,
                              colorScheme.secondaryContainer,
                              colorScheme.onSecondaryContainer,
                            ),
                          if (item.tagName != null)
                            _buildInfoChip(
                              context,
                              Icons.label_outline,
                              item.tagName!,
                              colorScheme.tertiaryContainer,
                              colorScheme.onTertiaryContainer,
                            ),
                        ],
                      ),
                    ),
                    // 右侧创建人和时间
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item.createdByName != null && AppConfigManager.instance.userId != item.createdBy) ...[
                          Icon(
                            Icons.person_outline,
                            size: 14,
                            color: colorScheme.outline,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.createdByName!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.outline,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: colorScheme.outline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeString,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context,
    IconData icon,
    String label,
    Color backgroundColor,
    Color foregroundColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: foregroundColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: foregroundColor,
                  height: 1.2,
                ),
          ),
        ],
      ),
    );
  }
}
