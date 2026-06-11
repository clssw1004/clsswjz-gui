import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../drivers/vo_transfer.dart';
import '../../enums/business_type.dart';
import '../../enums/debt_type.dart';
import '../../enums/debt_clear_state.dart';
import '../../manager/dao_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/book_meta.dart';
import '../../models/vo/user_debt_vo.dart';
import '../../models/vo/user_item_vo.dart';
import '../../utils/navigation_util.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../theme/theme_spacing.dart';
import '../../utils/color_util.dart';
import '../../routes/app_routes.dart';

class DebtEditPage extends StatefulWidget {
  final BookMetaVO book;
  final UserDebtVO debt;

  const DebtEditPage({
    super.key,
    required this.book,
    required this.debt,
  });

  @override
  State<DebtEditPage> createState() => _DebtEditPageState();
}

class _DebtEditPageState extends State<DebtEditPage> {
  final _debtorController = TextEditingController();
  final _amountController = TextEditingController();
  late DebtType _debtType;
  late DebtClearState _clearState;
  List<UserItemVO> _items = [];

  List<UserItemVO> get _debtItems {
    return _items.where((item) => item.categoryCode == _debtType.code).toList();
  }

  List<UserItemVO> get _operationItems {
    return _items
        .where((item) => item.categoryCode == _debtType.operationCategory)
        .toList();
  }

  double get _debtAmount {
    return _debtItems.fold(0.0, (sum, item) => sum + item.amount);
  }

  double get _operationAmount {
    return _operationItems.fold(0.0, (sum, item) => sum + item.amount);
  }

  /// 获取剩余金额
  double get _remainingAmount {
    final debt = _debtAmount.abs();
    final operation = _operationAmount.abs();
    return (debt - operation).clamp(0, double.infinity);
  }

  @override
  void initState() {
    super.initState();
    _debtType = DebtType.fromCode(widget.debt.debtType);
    _debtorController.text = widget.debt.debtor;
    _amountController.text = widget.debt.remainAmount.toString();
    _clearState = widget.debt.clearState;
    _loadItems();
  }

  @override
  void dispose() {
    _debtorController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    try {
      final dbItems = await DaoManager.itemDao.findBySource(
        BusinessType.debt.code,
        [widget.debt.id],
      );
      final items = await VOTransfer.transferItems(dbItems);

      if (mounted) {
        setState(() {
          _items = items;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _items = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.spacing;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(L10nManager.l10n.editTo(L10nManager.l10n.debt)),
      ),
      body: SafeArea(
        child: ListView(
          padding: spacing.pagePadding,
          children: [
            _DebtInfoCard(
              debt: widget.debt,
              book: widget.book,
              debtType: _debtType,
              clearState: _clearState,
              remainingAmount: _remainingAmount,
            ),
            SizedBox(height: spacing.formItemSpacing),
            _DebtRecordCard(
              title: _debtType == DebtType.lend
                  ? L10nManager.l10n.lend
                  : L10nManager.l10n.borrow,
              amount: _debtAmount,
              items: _debtItems,
              book: widget.book,
              debt: widget.debt,
              debtType: _debtType,
              onAddPressed: () => _navigateToPayment(_debtType.code),
              onRefresh: _loadItems,
            ),
            SizedBox(height: spacing.formItemSpacing),
            _DebtRecordCard(
              title: _debtType == DebtType.lend
                  ? L10nManager.l10n.collection
                  : L10nManager.l10n.repayment,
              amount: _operationAmount,
              items: _operationItems,
              book: widget.book,
              debt: widget.debt,
              debtType: _debtType,
              onAddPressed: () =>
                  _navigateToPayment(_debtType.operationCategory),
              onRefresh: _loadItems,
              isOperation: true,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToPayment(String categoryCode) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.debtPayment,
      arguments: [
        _debtType.code == categoryCode
            ? _debtType.text
            : _debtType.operationText,
        widget.book,
        widget.debt,
        categoryCode,
      ],
    );
    if (result == true) {
      _loadItems();
    }
  }
}

class _DebtInfoCard extends StatelessWidget {
  final UserDebtVO debt;
  final BookMetaVO book;
  final DebtType debtType;
  final DebtClearState clearState;
  final double remainingAmount;

  const _DebtInfoCard({
    required this.debt,
    required this.book,
    required this.debtType,
    required this.clearState,
    required this.remainingAmount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.spacing;
    final isLending = debtType == DebtType.lend;
    final amountColor = ColorUtil.getDebtAmountColor(debtType);
    final isSettled = remainingAmount <= 0;

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withAlpha(30)),
      ),
      child: Padding(
        padding: EdgeInsets.all(spacing.formItemSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 债务人 + 类型
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: amountColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isLending
                            ? Icons.arrow_circle_up_outlined
                            : Icons.arrow_circle_down_outlined,
                        size: 16,
                        color: amountColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isLending
                            ? L10nManager.l10n.lend
                            : L10nManager.l10n.borrow,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: amountColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    debt.debtor,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing.formItemSpacing),

            // 进度条
            if (!isSettled) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: (debt.totalAmount - remainingAmount) / debt.totalAmount,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  color: colorScheme.primary.withAlpha(180),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '${L10nManager.l10n.amount}: ${debt.totalAmount}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withAlpha(150),
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${((debt.totalAmount - remainingAmount) / debt.totalAmount * 100).toStringAsFixed(0)}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing.formItemSpacing),
            ],

            // 剩余金额 / 结清
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: spacing.formItemSpacing,
                horizontal: spacing.formItemSpacing,
              ),
              decoration: BoxDecoration(
                color: isSettled
                    ? DebtClearState.cleared.color.withAlpha(10)
                    : colorScheme.primary.withAlpha(8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSettled
                      ? DebtClearState.cleared.color.withAlpha(30)
                      : colorScheme.primary.withAlpha(20),
                ),
              ),
              child: isSettled
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle,
                            size: 22, color: DebtClearState.cleared.color),
                        const SizedBox(width: 8),
                        Text(
                          L10nManager.l10n.debtStatusCleared,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: DebtClearState.cleared.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Text(
                          isLending
                              ? L10nManager.l10n.remainingReceivable
                              : L10nManager.l10n.remainingPayable,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              book.currencySymbol.symbol,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              remainingAmount.toString(),
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
            SizedBox(height: spacing.formItemSpacing),

            // 信息标签
            Wrap(
              spacing: spacing.listItemSpacing,
              runSpacing: spacing.listItemSpacing / 2,
              children: [
                _infoTag(
                  context,
                  Icons.calendar_today_outlined,
                  debt.debtDate,
                  colorScheme,
                ),
                _infoTag(
                  context,
                  Icons.account_balance_wallet_outlined,
                  debt.fundName,
                  colorScheme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTag(
    BuildContext context,
    IconData icon,
    String label,
    ColorScheme colorScheme,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(60),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _DebtRecordCard extends StatelessWidget {
  final String title;
  final double amount;
  final List<UserItemVO> items;
  final BookMetaVO book;
  final UserDebtVO debt;
  final DebtType debtType;
  final VoidCallback onAddPressed;
  final VoidCallback onRefresh;
  final bool isOperation;

  const _DebtRecordCard({
    required this.title,
    required this.amount,
    required this.items,
    required this.book,
    required this.debt,
    required this.debtType,
    required this.onAddPressed,
    required this.onRefresh,
    this.isOperation = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final colorScheme = theme.colorScheme;
    final amountColor = isOperation
        ? ColorUtil.getDebtAmountReverseColor(debtType)
        : ColorUtil.getDebtAmountColor(debtType);
    final iconData = isOperation
        ? (debtType == DebtType.lend
            ? Icons.arrow_circle_down_outlined
            : Icons.arrow_circle_up_outlined)
        : (debtType == DebtType.lend
            ? Icons.arrow_circle_up_outlined
            : Icons.arrow_circle_down_outlined);

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Padding(
            padding: EdgeInsets.fromLTRB(
              spacing.formItemSpacing,
              spacing.formItemSpacing / 2,
              spacing.formItemSpacing / 2,
              0,
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: amountColor.withAlpha(15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(iconData, size: 18, color: amountColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        amount.toString(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: amountColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: onAddPressed,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    foregroundColor: colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(
                    title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 列表
          if (items.isNotEmpty) ...[
            Divider(
              height: 1,
              thickness: 0.5,
              indent: spacing.formItemSpacing,
              endIndent: spacing.formItemSpacing,
              color: colorScheme.outlineVariant.withAlpha(80),
            ),
            _DebtItemList(
              items: items,
              book: book,
              onRefresh: onRefresh,
            ),
            // 底部留白
            SizedBox(height: spacing.listItemSpacing / 2),
          ] else
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: spacing.formItemSpacing,
                horizontal: spacing.formItemSpacing,
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_outlined,
                        size: 16,
                        color: colorScheme.onSurfaceVariant.withAlpha(80)),
                    const SizedBox(width: 6),
                    Text(
                      L10nManager.l10n.noData,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant.withAlpha(80),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DebtItemList extends StatelessWidget {
  final List<UserItemVO> items;
  final BookMetaVO book;
  final VoidCallback onRefresh;

  const _DebtItemList({
    required this.items,
    required this.book,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final colorScheme = theme.colorScheme;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: items.length,
      separatorBuilder: (_, __) => Padding(
        padding: EdgeInsets.only(left: spacing.formItemSpacing),
        child: Divider(
          height: 1,
          thickness: 0.5,
          color: colorScheme.outlineVariant.withAlpha(50),
        ),
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          onTap: () async {
            await NavigationUtil.toItemEdit(context, item);
            onRefresh();
          },
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              spacing.formItemSpacing,
              spacing.listItemSpacing,
              spacing.formItemSpacing,
              spacing.listItemSpacing,
            ),
            child: Row(
              children: [
                // 日期 + 账户
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('yyyy-MM-dd')
                            .format(DateTime.parse(item.accountDate)),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (item.fundName != null && item.fundName!.isNotEmpty)
                        Text(
                          item.fundName!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant.withAlpha(150),
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  item.amount.toString(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: ColorUtil.getTransferCategoryColor(item),
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
