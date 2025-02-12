import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../database/database.dart';
import '../../enums/debt_type.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/book_meta.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/common_badge.dart';
import '../../theme/theme_spacing.dart';
import '../../utils/toast_util.dart';
import '../../utils/color_util.dart';
import '../../drivers/driver_factory.dart';
import '../../manager/app_config_manager.dart';
import '../../enums/debt_clear_state.dart';
import '../../widgets/common/common_card_container.dart';

class DebtEditPage extends StatefulWidget {
  final BookMetaVO book;
  final AccountDebt debt;

  const DebtEditPage({
    super.key,
    required this.book,
    required this.debt,
  });

  @override
  State<DebtEditPage> createState() => _DebtEditPageState();
}

class _DebtEditPageState extends State<DebtEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _debtorController = TextEditingController();
  final _amountController = TextEditingController();
  late DebtType _debtType;
  String? _selectedAccountId;
  bool _saving = false;
  late String _selectedDate;
  late DebtClearState _clearState;

  List<AccountFund> get _accounts => widget.book.funds ?? [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    _debtType = DebtType.fromCode(widget.debt.debtType);
    _debtorController.text = widget.debt.debtor;
    _amountController.text = widget.debt.amount.toString();
    _selectedAccountId = widget.debt.fundId;
    _selectedDate = widget.debt.debtDate;
    _clearState = DebtClearState.fromCode(widget.debt.clearState);
  }

  @override
  void dispose() {
    _debtorController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _markAsCleared() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(L10nManager.l10n.warning),
        content: Text('确认将此债务标记为已结清？'),
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

    if (confirmed != true) return;

    setState(() {
      _saving = true;
    });

    try {
      await DriverFactory.driver.updateDebt(
        AppConfigManager.instance.userId,
        widget.book.id,
        widget.debt.id,
        clearState: DebtClearState.cleared,
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
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _markAsCancelled() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(L10nManager.l10n.warning),
        content: Text('确认将此债务标记为已作废？'),
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

    if (confirmed != true) return;

    setState(() {
      _saving = true;
    });

    try {
      await DriverFactory.driver.updateDebt(
        AppConfigManager.instance.userId,
        widget.book.id,
        widget.debt.id,
        clearState: DebtClearState.cancelled,
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
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
    });

    try {
      await DriverFactory.driver.updateDebt(
        AppConfigManager.instance.userId,
        widget.book.id,
        widget.debt.id,
        debtor: _debtorController.text,
        amount: double.parse(_amountController.text),
        fundId: _selectedAccountId!,
        debtDate: _selectedDate,
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
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(L10nManager.l10n.warning),
        content:
            Text(L10nManager.l10n.deleteConfirmMessage(widget.debt.debtor)),
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

    if (confirmed != true) return;

    setState(() {
      _saving = true;
    });

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
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.spacing;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(L10nManager.l10n.editTo(L10nManager.l10n.debt)),
        actions: [
          if (_clearState == DebtClearState.pending) ...[
            IconButton(
              onPressed: _saving ? null : _markAsCleared,
              icon: const Icon(Icons.check_circle_outline),
              tooltip: '标记为已结清',
            ),
            IconButton(
              onPressed: _saving ? null : _markAsCancelled,
              icon: const Icon(Icons.cancel_outlined),
              tooltip: '标记为已作废',
            ),
          ],
          IconButton(
            onPressed: _saving ? null : _delete,
            icon: Icon(
              Icons.delete_outline,
              color: colorScheme.error,
            ),
          ),
          IconButton(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onSurface,
                    ),
                  )
                : const Icon(Icons.save_outlined),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: spacing.formPadding,
          children: [
            CommonCardContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _debtType == DebtType.lend
                            ? Icons.arrow_circle_up_outlined
                            : Icons.arrow_circle_down_outlined,
                        color: ColorUtil.getDebtAmountColor(_debtType),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.debt.debtType == DebtType.lend.code
                            ? L10nManager.l10n.lend
                            : L10nManager.l10n.borrow,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: ColorUtil.getDebtAmountColor(_debtType),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.debt.debtor,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      CommonBadge(
                        text: _clearState.text,
                        textColor: _clearState.color,
                      ),
                    ],
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: spacing.formItemSpacing),
                    child: Row(
                      children: [
                        Text(
                          '${widget.book.currencySymbol.symbol} ${_amountController.text}',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: ColorUtil.getDebtAmountColor(_debtType),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.account_balance_wallet_outlined,
                          color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        _accounts
                            .firstWhere(
                                (account) => account.id == _selectedAccountId)
                            .name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing.formItemSpacing),
            CommonCardContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: Icon(Icons.calendar_today_outlined,
                        color: theme.colorScheme.primary),
                    title: Text(L10nManager.l10n.debtDate),
                    subtitle: Text(_selectedDate),
                    contentPadding: EdgeInsets.zero,
                  ),
                  Divider(height: 1),
                  if (widget.debt.expectedClearDate != null)
                    ListTile(
                      leading: Icon(Icons.event_available_outlined,
                          color: theme.colorScheme.primary),
                      title: Text(L10nManager.l10n.expectedClearDate),
                      subtitle: Text(widget.debt.expectedClearDate!),
                      contentPadding: EdgeInsets.zero,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
