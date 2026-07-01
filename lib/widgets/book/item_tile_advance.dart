import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/user_item_vo.dart';
import '../../utils/color_util.dart';
import '../../theme/theme_spacing.dart';
import '../common/common_card_container.dart';

/// 账目列表项
class ItemTileAdvance extends StatelessWidget {
  /// 账目数据
  final UserItemVO item;

  /// 货币符号
  final String currencySymbol;

  /// 在列表中的索引
  final int index;


  /// 删除回调
  final Future<bool> Function(UserItemVO item)? onDelete;

  const ItemTileAdvance({
    super.key,
    required this.item,
    required this.currencySymbol,
    required this.index,
    this.onDelete,
  });

  /// 显示删除确认对话框
  Future<bool> _showDeleteConfirmDialog(BuildContext context) async {
    final l10n = L10nManager.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text(l10n.delete(l10n.tabAccountItems)),
          content: Text('${l10n.delete(l10n.tabAccountItems)}？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                l10n.cancel,
                style: TextStyle(color: theme.colorScheme.outline),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                l10n.confirm,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final result = await onDelete?.call(item);
      return result ?? false;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.spacing;

    // 解析时间
    final time = DateTime.parse(item.accountDate);
    final timeString = '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';

    // 获取金额颜色
    final amountColor = ColorUtil.getAmountColor(item.type);

    return CommonCardContainer(
      margin: spacing.listItemMargin,
      padding: EdgeInsets.zero,
      child: Slidable(
        key: ValueKey(item.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.20,
          dismissible: DismissiblePane(
            onDismissed: () {},
            closeOnCancel: true,
            confirmDismiss: () => _showDeleteConfirmDialog(context),
          ),
          children: [
            CustomSlidableAction(
              backgroundColor: colorScheme.errorContainer.withAlpha(180),
              foregroundColor: colorScheme.error,
              padding: EdgeInsets.zero,
              onPressed: (_) async {
                final confirmed = await _showDeleteConfirmDialog(context);
                if (!confirmed) {
                  Slidable.of(context)?.close();
                }
              },
              child: Icon(
                Icons.delete_outline,
                color: colorScheme.error,
                size: 24,
              ),
            ),
          ],
        ),
        child: Padding(
          padding: spacing.listItemPadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 左侧渐变装饰条
              Container(
                width: 4,
                height: 72,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      amountColor,
                      amountColor.withValues(alpha: 0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              // 主内容区
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 顶部：分类名称 + 标签 + 金额
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  item.categoryName ?? '',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (item.tags.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                for (var i = 0; i < item.tags.length && i < 3; i++)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    margin: const EdgeInsets.only(right: 4),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      item.tags[i].name,
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: colorScheme.primary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                if (item.tags.length > 3)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '+${item.tags.length - 3}',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: colorScheme.primary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                              ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${item.amount > 0 ? "+" : ""}${item.amount.toStringAsFixed(2)}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: amountColor,
                            fontSize: 16,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                    // 描述
                    if (item.description != null && item.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          item.description!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    // 底部信息行：时间 + 账户 + 商户 + 创建者
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Icon(Icons.schedule_outlined, size: 13, color: colorScheme.outline),
                          const SizedBox(width: 4),
                          Text(
                            timeString,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.outline,
                              fontSize: 12,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                          if (item.fundName != null) ...[
                            const SizedBox(width: 12),
                            Icon(Icons.account_balance_wallet_outlined, size: 13, color: colorScheme.outline),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                item.fundName!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.outline,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          if (item.shopName != null) ...[
                            const SizedBox(width: 12),
                            Icon(Icons.store_outlined, size: 13, color: colorScheme.outline),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                item.shopName!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.outline,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          if (item.createdByName != null && AppConfigManager.instance.userId != item.createdBy) ...[
                            const SizedBox(width: 12),
                            Icon(Icons.person_outline, size: 13, color: colorScheme.outline),
                            const SizedBox(width: 4),
                            Text(
                              item.createdByName!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.outline,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // 项目标签
                    if (item.projectName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.folder_outlined, size: 12, color: colorScheme.onSecondaryContainer),
                              const SizedBox(width: 4),
                              Text(
                                item.projectName!,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSecondaryContainer,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
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
}
