import 'package:clsswjz/models/vo/user_item_vo.dart';
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
import '../../utils/navigation_util.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../theme/theme_spacing.dart';
import '../../utils/toast_util.dart';
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
  bool _saving = false;
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
    return _debtAmount - _operationAmount;
  }

  @override
  void initState() {
    super.initState();
    _debtType = DebtType.fromCode(widget.debt.debtType);
    _debtorController.text = widget.debt.debtor;
    _amountController.text = widget.debt.amount.toString();
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

  Future<void> _updateDebtState(DebtClearState state, String message) async {
    final confirmed = await _showConfirmDialog(message);
    if (confirmed != true) return;

    setState(() => _saving = true);
    try {
      await DriverFactory.driver.updateDebt(
        AppConfigManager.instance.userId,
        widget.book.id,
        widget.debt.id,
        clearState: state,
        clearDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ToastUtil.showError(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<bool?> _showConfirmDialog(String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(L10nManager.l10n.warning),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(L10nManager.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(L10nManager.l10n.confirm),
          ),
        ],
      ),
    );
  }

  Future<void> _delete() async {
    final confirmed = await _showConfirmDialog(
      L10nManager.l10n.deleteConfirmMessage(widget.debt.debtor),
    );
    if (confirmed != true) return;

    setState(() => _saving = true);
    try {
      final result = await DriverFactory.driver.deleteDebt(
        AppConfigManager.instance.userId,
        widget.book.id,
        widget.debt.id,
      );
      if (result.ok) {
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } else {
        if (mounted) {
          ToastUtil.showError(result.message ??
              L10nManager.l10n.deleteFailed(L10nManager.l10n.debt, ''));
        }
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
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
        actions: _buildAppBarActions(),
      ),
      body: ListView(
        padding: spacing.pagePadding,
        children: [
          _DebtInfoCard(
            debt: widget.debt,
            book: widget.book,
            debtType: _debtType,
            clearState: _clearState,
            remainingAmount: _remainingAmount,
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          _DebtRecordCard(
            title: _debtType == DebtType.lend
                ? L10nManager.l10n.collection
                : L10nManager.l10n.repayment,
            amount: _operationAmount,
            items: _operationItems,
            book: widget.book,
            debt: widget.debt,
            debtType: _debtType,
            onAddPressed: () => _navigateToPayment(_debtType.operationCategory),
            onRefresh: _loadItems,
            isOperation: true,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
      if (_clearState == DebtClearState.pending) ...[
        IconButton(
          onPressed: _saving
              ? null
              : () => _updateDebtState(
                    DebtClearState.cleared,
                    '确认将此债务标记为已结清？',
                  ),
          icon: const Icon(Icons.check_circle_outline),
          tooltip: '标记为已结清',
        ),
        IconButton(
          onPressed: _saving
              ? null
              : () => _updateDebtState(
                    DebtClearState.cancelled,
                    '确认将此债务标记为已作废？',
                  ),
          icon: const Icon(Icons.cancel_outlined),
          tooltip: '标记为已作废',
        ),
      ],
      IconButton(
        onPressed: _saving ? null : _delete,
        icon: Icon(
          Icons.delete_outline,
          color: Theme.of(context).colorScheme.error,
        ),
      ),
    ];
  }

  Future<void> _navigateToPayment(String categoryCode) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.debtPayment,
      arguments: [
        _debtType == DebtType.lend
            ? L10nManager.l10n.collection
            : L10nManager.l10n.repayment,
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
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  debt.debtor,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              CommonTag(
                label: clearState.text,
                color: clearState.color,
                outlined: true,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRemainingAmount(context),
          const SizedBox(height: 16),
          _buildInfoRow(context),
        ],
      ),
    );
  }

  Widget _buildRemainingAmount(BuildContext context) {
    final theme = Theme.of(context);
    final debtColor = ColorUtil.getDebtAmountReverseColor(debtType);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: debtColor.withAlpha(12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            debtType == DebtType.lend
                ? L10nManager.l10n.remainingReceivable
                : L10nManager.l10n.remainingPayable,
            style: theme.textTheme.bodyMedium?.copyWith(color: debtColor),
          ),
          const SizedBox(height: 4),
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
              const SizedBox(width: 8),
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
    return Row(
      children: [
        CommonTag(
          icon: Icons.calendar_today_outlined,
          label: debt.debtDate,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          backgroundColor: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withAlpha(50),
        ),
        const SizedBox(width: 12),
        CommonTag(
          icon: Icons.account_balance_wallet_outlined,
          label: debt.fundName,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          backgroundColor: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withAlpha(50),
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
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                amount.toString(),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isOperation
                      ? ColorUtil.getDebtAmountReverseColor(debtType)
                      : ColorUtil.getDebtAmountColor(debtType),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onAddPressed,
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  foregroundColor: colorScheme.primary,
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
            const Divider(height: 16),
            _DebtItemList(
              items: items,
              book: book,
              onRefresh: onRefresh,
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
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            L10nManager.l10n.noData,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withAlpha(100),
                ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          onTap: () {
            NavigationUtil.toItemEdit(context, item);
            onRefresh();
          },
          title: Row(
            children: [
              CommonTag(
                icon: Icons.calendar_today_outlined,
                label: DateFormat('yyyy-MM-dd')
                    .format(DateTime.parse(item.accountDate)),
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withAlpha(50),
              ),
              const SizedBox(width: 12),
              CommonTag(
                icon: Icons.account_balance_wallet_outlined,
                label: item.fundName ?? '',
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withAlpha(50),
              ),
              const Spacer(),
              Text(
                item.amount.toString(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: ColorUtil.getTransferCategoryColor(item),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}
