import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../drivers/driver_factory.dart';
import '../../enums/business_type.dart';
import '../../enums/debt_type.dart';
import '../../enums/debt_clear_state.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../models/dto/item_filter_dto.dart';
import '../../models/vo/book_meta.dart';
import '../../models/vo/user_debt_vo.dart';
import '../../models/vo/user_item_vo.dart';
import '../../utils/navigation_util.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../theme/theme_spacing.dart';
import '../../utils/color_util.dart';
import '../../widgets/common/common_card_container.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/common_tag.dart';

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
    return _debtAmount + _operationAmount;
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
      final itemResult = await DriverFactory.driver.listItemsByBook(
        AppConfigManager.instance.userId,
        widget.book.id,
        filter: ItemFilterDTO(
          source: BusinessType.debt.code,
          sourceIds: [widget.debt.id],
        ),
      );

      if (mounted) {
        setState(() {
          _items = itemResult.ok ? itemResult.data ?? [] : [];
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
    final spacing = theme.spacing;

    return CommonCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CommonTag(
                icon: debtType == DebtType.lend
                    ? Icons.arrow_circle_up_outlined
                    : Icons.arrow_circle_down_outlined,
                label: debtType == DebtType.lend
                    ? L10nManager.l10n.lend
                    : L10nManager.l10n.borrow,
                color: ColorUtil.getDebtAmountColor(debtType),
              ),
              SizedBox(width: spacing.listItemSpacing),
              Expanded(
                child: Text(
                  debt.debtor,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // CommonTag(
              //   label: clearState.text,
              //   color: clearState.color,
              //   outlined: true,
              // ),
            ],
          ),
          SizedBox(height: spacing.formItemSpacing),
          _buildRemainingAmount(context),
          SizedBox(height: spacing.formItemSpacing),
          _buildInfoRow(context),
        ],
      ),
    );
  }

  Widget _buildRemainingAmount(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final debtColor = ColorUtil.getDebtAmountReverseColor(debtType);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          horizontal: spacing.formItemSpacing,
          vertical: spacing.listItemSpacing),
      decoration: BoxDecoration(
        color: debtColor.withAlpha(13),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            debtType == DebtType.lend
                ? L10nManager.l10n.remainingReceivable
                : L10nManager.l10n.remainingPayable,
            style: theme.textTheme.bodyMedium?.copyWith(color: debtColor),
          ),
          SizedBox(height: spacing.listItemSpacing / 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                book.currencySymbol.symbol,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: debtColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: spacing.listItemSpacing / 2),
              Text(
                remainingAmount.toString(),
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: debtColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context) {
    final theme = Theme.of(context);
    final spacing = theme.spacing;
    final colorScheme = theme.colorScheme;

    return Wrap(
      spacing: spacing.listItemSpacing,
      runSpacing: spacing.listItemSpacing / 2,
      children: [
        CommonTag(
          icon: Icons.calendar_today_outlined,
          label: debt.debtDate,
          color: colorScheme.onSurfaceVariant,
          backgroundColor: colorScheme.surfaceContainerHighest.withAlpha(50),
        ),
        CommonTag(
          icon: Icons.account_balance_wallet_outlined,
          label: debt.fundName,
          color: colorScheme.onSurfaceVariant,
          backgroundColor: colorScheme.surfaceContainerHighest.withAlpha(50),
        ),
      ],
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

    return CommonCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isOperation
                    ? (debtType == DebtType.lend
                        ? Icons.arrow_circle_down_outlined
                        : Icons.arrow_circle_up_outlined)
                    : (debtType == DebtType.lend
                        ? Icons.arrow_circle_up_outlined
                        : Icons.arrow_circle_down_outlined),
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: spacing.listItemSpacing / 2),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: spacing.listItemSpacing),
                    Text(
                      amount.toString(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isOperation
                            ? ColorUtil.getDebtAmountReverseColor(debtType)
                            : ColorUtil.getDebtAmountColor(debtType),
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: onAddPressed,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      horizontal: spacing.listItemSpacing / 2,
                      vertical: spacing.listItemSpacing / 2),
                  foregroundColor: colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                icon: Icon(
                  Icons.add_circle_outline,
                  size: 18,
                  color: colorScheme.primary,
                ),
                label: Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          if (items.isNotEmpty) ...[
            Divider(
              height: spacing.listItemSpacing,
              thickness: 1,
              color: colorScheme.outlineVariant.withAlpha(128),
            ),
            _DebtItemList(
              items: items,
              book: book,
              onRefresh: onRefresh,
            ),
          ] else ...[
            SizedBox(height: spacing.listItemSpacing),
            Center(
              child: Padding(
                padding:
                    EdgeInsets.symmetric(vertical: spacing.listItemSpacing),
                child: Text(
                  L10nManager.l10n.noData,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant.withAlpha(102),
                  ),
                ),
              ),
            ),
          ],
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

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: spacing.listItemSpacing),
          child: Text(
            L10nManager.l10n.noData,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant.withAlpha(102),
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        thickness: 0.5,
        color: colorScheme.outlineVariant.withAlpha(77),
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          onTap: () {
            NavigationUtil.toItemEdit(context, item);
            onRefresh();
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: spacing.listItemSpacing,
              horizontal: spacing.listItemSpacing / 2,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: spacing.listItemSpacing / 2,
                    runSpacing: spacing.listItemSpacing / 2,
                    children: [
                      CommonTag(
                        icon: Icons.calendar_today_outlined,
                        label: DateFormat('yyyy-MM-dd')
                            .format(DateTime.parse(item.accountDate)),
                        color: colorScheme.onSurfaceVariant,
                        backgroundColor:
                            colorScheme.surfaceContainerHighest.withAlpha(50),
                      ),
                      CommonTag(
                        icon: Icons.account_balance_wallet_outlined,
                        label: item.fundName ?? '',
                        color: colorScheme.onSurfaceVariant,
                        backgroundColor:
                            colorScheme.surfaceContainerHighest.withAlpha(50),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: spacing.listItemSpacing),
                Text(
                  item.amount.toString(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: ColorUtil.getTransferCategoryColor(item),
                    fontWeight: FontWeight.w600,
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
