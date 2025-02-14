import 'package:clsswjz/models/vo/user_item_vo.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../database/database.dart';
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
import '../../widgets/common/common_app_bar.dart';
import '../../theme/theme_spacing.dart';
import '../../utils/toast_util.dart';
import '../../utils/color_util.dart';
import '../../widgets/common/common_card_container.dart';
import '../../pages/book/debt_payment_page.dart';

class DebtEditPage extends StatefulWidget {
  final BookMetaVO book;
  final UserDebtVO debt;
  final List<UserItemVO> items;

  const DebtEditPage({
    super.key,
    required this.book,
    required this.debt,
    required this.items,
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
    _clearState = widget.debt.clearState;
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
                  // 第一行：债务类型、债务人和状态
                  Row(
                    children: [
                      // 借出/借入标签
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: ColorUtil.getDebtAmountColor(_debtType)
                              .withAlpha(24),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _debtType == DebtType.lend
                                  ? Icons.arrow_circle_up_outlined
                                  : Icons.arrow_circle_down_outlined,
                              color: ColorUtil.getDebtAmountColor(_debtType),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.debt.debtType == DebtType.lend.code
                                  ? L10nManager.l10n.lend
                                  : L10nManager.l10n.borrow,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: ColorUtil.getDebtAmountColor(_debtType),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 债务人
                      Expanded(
                        child: Text(
                          widget.debt.debtor,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 状态标签
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _clearState.color.withAlpha(24),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _clearState.color.withAlpha(50),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _clearState.text,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: _clearState.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 第二行：金额显示
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color:
                          ColorUtil.getDebtAmountColor(_debtType).withAlpha(12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.book.currencySymbol.symbol,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: ColorUtil.getDebtAmountColor(_debtType),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _amountController.text,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: ColorUtil.getDebtAmountColor(_debtType),
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 第三行：日期和账户信息
                  Row(
                    children: [
                      // 日期
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withAlpha(50),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _selectedDate,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // 账户
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withAlpha(50),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.debt.fundName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 第一个卡片：借出/借入记录
            CommonCardContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  Row(
                    children: [
                      Icon(
                        _debtType == DebtType.lend
                            ? Icons.arrow_circle_up_outlined
                            : Icons.arrow_circle_down_outlined,
                        size: 20,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _debtType == DebtType.lend
                            ? L10nManager.l10n.lend
                            : L10nManager.l10n.borrow,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  // 借出/借入记录列表
                  _buildItemList(
                    context,
                    widget.items
                        .where((item) =>
                            item.categoryCode ==
                            (_debtType == DebtType.lend ? 'lend' : 'borrow'))
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // 第二个卡片：收款/还款记录
            CommonCardContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题
                  Row(
                    children: [
                      Icon(
                        _debtType == DebtType.lend
                            ? Icons.arrow_circle_down_outlined
                            : Icons.arrow_circle_up_outlined,
                        size: 20,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _debtType == DebtType.lend
                            ? L10nManager.l10n.collection
                            : L10nManager.l10n.repayment,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      // 添加还款/借款按钮
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DebtPaymentPage(
                                book: widget.book,
                                debt: widget.debt,
                              ),
                            ),
                          ).then((updated) {
                            if (updated == true) {
                              // 刷新数据
                              // _loadItems();
                            }
                          });
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          minimumSize: const Size(0, 32),
                          foregroundColor: theme.colorScheme.primary,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.add,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(_debtType == DebtType.lend
                                ? L10nManager.l10n.collection
                                : L10nManager.l10n.repayment),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // 收款/还款记录列表
                  _buildItemList(
                    context,
                    widget.items
                        .where((item) =>
                            item.categoryCode ==
                            (_debtType == DebtType.lend
                                ? 'collection'
                                : 'repayment'))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemList(BuildContext context, List<UserItemVO> items) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            L10nManager.l10n.noData,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.75),
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 12),
      itemCount: items.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: colorScheme.outlineVariant.withAlpha(40),
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              // 日期
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withAlpha(50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.accountDate?.split(' ')[0] ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // 账户
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withAlpha(50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.fundName ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // 金额
              Text(
                item.amount.toString(),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: ColorUtil.getDebtAmountColor(_debtType),
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
