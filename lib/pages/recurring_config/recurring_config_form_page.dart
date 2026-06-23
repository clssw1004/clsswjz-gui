import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/database.dart';
import '../../drivers/driver_factory.dart';
import '../../enums/account_type.dart';
import '../../enums/symbol_type.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/recurring_config_vo.dart';
import '../../models/vo/user_fund_vo.dart';
import '../../providers/recurring_config_provider.dart';
import '../../theme/theme_spacing.dart';
import '../../utils/color_util.dart';
import '../../generated/l10n/app_localizations.dart';
import '../../widgets/book/animated_type_toggle.dart';
import '../../widgets/book/calculator_panel.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/common_card_container.dart';
import '../../widgets/common/common_select_form_field.dart';
import '../../widgets/common/common_text_form_field.dart';
import '../../widgets/common/multi_select_sheet.dart';
import '../../widgets/common/multi_select_dialog.dart';

/// 固定收支配置表单页（新增/编辑）
class RecurringConfigFormPage extends StatefulWidget {
  final RecurringConfigVO? config;
  final String bookId;

  const RecurringConfigFormPage({
    super.key,
    this.config,
    required this.bookId,
  });

  @override
  State<RecurringConfigFormPage> createState() => _RecurringConfigFormPageState();
}

class _RecurringConfigFormPageState extends State<RecurringConfigFormPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _userId = AppConfigManager.instance.userId;
  late final TabController _tabController;

  // 配置字段
  String _type = AccountItemType.expense.code;
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String? _categoryCode;
  String? _fundId;
  String? _shopCode;
  String? _tagCode;
  String? _projectCode;
  String _frequencyType = 'monthly';
  Set<String> _frequencyValues = {};
  String _startDate = '';
  String _endType = 'infinite';
  String? _endDate;
  int? _endCount;

  // 元数据
  List<AccountCategory> _categories = [];
  List<UserFundVO> _funds = [];
  List<AccountShop> _shops = [];
  List<AccountSymbol> _tags = [];
  List<AccountSymbol> _projects = [];
  bool _loading = false;

  // 入场动画
  final List<bool> _sectionVisible = List.filled(5, false);

  bool get _isEdit => widget.config != null;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    if (_isEdit) {
      _fillFromConfig(widget.config!);
    } else {
      _startDate = DateTime.now().toIso8601String().substring(0, 10);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMetaData());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (int i = 0; i < _sectionVisible.length; i++) {
        Future.delayed(Duration(milliseconds: 80 * i), () {
          if (mounted) setState(() => _sectionVisible[i] = true);
        });
      }
    });
  }

  void _fillFromConfig(RecurringConfigVO config) {
    _type = config.type;
    _amountCtrl.text = config.amount.toString();
    _descCtrl.text = config.description ?? '';
    _categoryCode = config.categoryCode;
    _fundId = config.fundId;
    _shopCode = config.shopCode;
    _tagCode = config.tagCode;
    _projectCode = config.projectCode;
    _frequencyType = config.frequencyType;
    _frequencyValues = config.frequencyValue.split(',').toSet();
    _startDate = config.startDate;
    _endType = config.endType;
    _endDate = config.endDate;
    _endCount = config.endCount;
  }

  Future<void> _loadMetaData() async {
    setState(() => _loading = true);
    final bookId = widget.bookId;
    if (bookId.isEmpty) { if (mounted) setState(() => _loading = false); return; }

    try {
      final r1 = await DriverFactory.driver.listCategoriesByBook(_userId, bookId);
      if (mounted && r1.ok && r1.data != null) _categories = r1.data!;

      final r2 = await DriverFactory.driver.listFundsByBook(_userId, bookId);
      if (mounted && r2.ok && r2.data != null) _funds = r2.data!;

      final r3 = await DriverFactory.driver.listShopsByBook(_userId, bookId);
      if (mounted && r3.ok && r3.data != null) _shops = r3.data!;

      final r4 = await DriverFactory.driver.listSymbolsByBook(_userId, bookId, symbolType: SymbolType.tag);
      if (mounted && r4.ok && r4.data != null) _tags = r4.data!;

      final r5 = await DriverFactory.driver.listSymbolsByBook(_userId, bookId, symbolType: SymbolType.project);
      if (mounted && r5.ok && r5.data != null) _projects = r5.data!;
    } catch (_) {}

    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Color _getAmountColor() => _type == AccountItemType.income.code ? ColorUtil.INCOME : ColorUtil.EXPENSE;

  Widget _animSection(int index, Widget child) {
    return AnimatedOpacity(
      opacity: _sectionVisible[index] ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      child: child,
    );
  }

  Widget _sectionDivider(IconData icon, String title) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: cs.primary),
        const SizedBox(width: 6),
        Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.primary)),
        const SizedBox(width: 12),
        Expanded(child: Container(height: 1, color: cs.primary.withAlpha(20))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final spacing = theme.spacing;
    final l10n = L10nManager.l10n;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(_isEdit ? l10n.recurringConfigEdit : l10n.recurringConfigAdd),
        actions: [
          TextButton.icon(
            onPressed: _loading ? null : _save,
            icon: const Icon(Icons.save_outlined, size: 20),
            label: Text(l10n.save),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: const Icon(Icons.repeat), text: l10n.recurringConfigFrequency),
            Tab(icon: const Icon(Icons.receipt_outlined), text: '账目信息'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFrequencyTab(theme, cs, spacing, l10n),
                  _buildTransactionTab(theme, cs, spacing, l10n),
                ],
              ),
            ),
    );
  }

  // ═══════════════════════════════════
  // Tab 1: 账目信息
  // ═══════════════════════════════════

  Widget _buildTransactionTab(ThemeData theme, ColorScheme cs, ThemeSpacing spacing, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: spacing.formPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 类型切换
          _animSection(0, AnimatedTypeToggle(
            value: AccountItemType.fromCode(_type) ?? AccountItemType.expense,
            onChanged: (t) => setState(() {
              _type = t.code;
              _categoryCode = null;
            }),
          )),
          SizedBox(height: spacing.formGroupSpacing),

          // 金额
          _animSection(1, _buildAmountSection(theme, cs)),
          SizedBox(height: spacing.formGroupSpacing),

          // 分类与账户
          _animSection(2, _buildCategoryFundSection(theme, cs, l10n)),
          SizedBox(height: spacing.formGroupSpacing),

          // 详细信息（标签/项目/商户）
          _animSection(3, _buildDetailsSection(theme, cs, l10n)),
          SizedBox(height: spacing.formGroupSpacing),

          // 备注
          _animSection(4, _buildRemarkSection(theme, cs, l10n)),
          SizedBox(height: spacing.formGroupSpacing),

        ],
      ),
    );
  }

  Widget _buildAmountSection(ThemeData theme, ColorScheme cs) {
    final amountColor = _getAmountColor();
    final amountText = _amountCtrl.text.isEmpty ? '0.00' : _amountCtrl.text;
    return InkWell(
      onTap: _showCalculator,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withAlpha(40),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('¥', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: amountColor)),
                  const SizedBox(width: 4),
                  Text(amountText,
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700, color: amountColor, height: 1.1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text('点击输入金额', style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  void _showCalculator() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CalculatorPanel(
        initialValue: double.tryParse(_amountCtrl.text)?.abs(),
        onConfirm: (value) {
          setState(() {
            _amountCtrl.text = value.abs().toStringAsFixed(2);
          });
        },
      ),
    );
  }

  Widget _buildCategoryFundSection(ThemeData theme, ColorScheme cs, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionDivider(Icons.account_tree_outlined, l10n.recurringConfigCategory),
        const SizedBox(height: 16),
        CommonSelectFormField<AccountCategory>(
          items: _categories.where((c) => c.categoryType == _type).toList(),
          value: _categories.where((c) => c.code == _categoryCode).firstOrNull,
          displayMode: DisplayMode.expand,
          displayField: (c) => c.name,
          keyField: (c) => c,
          icon: Icons.category_outlined,
          label: l10n.recurringConfigCategory,
          required: true,
          expandCount: 8,
          expandRows: 3,
          onChanged: (v) => setState(() => _categoryCode = (v as AccountCategory?)?.code),
          validator: (v) => v == null ? l10n.recurringConfigCategoryRequired : null,
        ),
        const SizedBox(height: 16),
        CommonSelectFormField<UserFundVO>(
          items: _funds,
          value: _funds.where((f) => f.id == _fundId).firstOrNull,
          displayMode: DisplayMode.iconText,
          displayField: (f) => f.name,
          keyField: (f) => f,
          icon: Icons.account_balance_wallet_outlined,
          label: l10n.recurringConfigFund,
          required: true,
          allowCreate: false,
          onChanged: (v) => setState(() => _fundId = (v as UserFundVO?)?.id),
          validator: (v) => v == null ? l10n.recurringConfigFundRequired : null,
        ),
      ],
    );
  }

  Widget _buildDetailsSection(ThemeData theme, ColorScheme cs, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionDivider(Icons.label_outline, l10n.recurringConfigType),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: Wrap(
            spacing: 8, runSpacing: 8,
            children: [
              CommonSelectFormField<AccountShop>(
                items: _shops,
                value: _shops.where((s) => s.code == _shopCode).firstOrNull,
                label: l10n.recurringConfigShop,
                displayMode: DisplayMode.badge,
                displayField: (s) => s.name,
                keyField: (s) => s,
                icon: Icons.store_outlined,
                hint: l10n.recurringConfigShop,
                onChanged: (v) => setState(() => _shopCode = (v as AccountShop?)?.code),
              ),
              CommonSelectFormField<AccountSymbol>(
                items: _tags,
                value: _tags.where((t) => t.code == _tagCode).firstOrNull,
                label: l10n.tag,
                displayMode: DisplayMode.badge,
                displayField: (t) => t.name,
                keyField: (t) => t,
                icon: Icons.local_offer_outlined,
                hint: l10n.tag,
                onChanged: (v) => setState(() => _tagCode = (v as AccountSymbol?)?.code),
              ),
              CommonSelectFormField<AccountSymbol>(
                items: _projects,
                value: _projects.where((p) => p.code == _projectCode).firstOrNull,
                label: l10n.project,
                displayMode: DisplayMode.badge,
                displayField: (p) => p.name,
                keyField: (p) => p,
                icon: Icons.folder_outlined,
                hint: l10n.project,
                onChanged: (v) => setState(() => _projectCode = (v as AccountSymbol?)?.code),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRemarkSection(ThemeData theme, ColorScheme cs, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionDivider(Icons.description_outlined, l10n.recurringConfigRemark),
        const SizedBox(height: 16),
        CommonTextFormField(
          controller: _descCtrl,
          labelText: l10n.recurringConfigRemark,
          prefixIcon: const Icon(Icons.description_outlined),
          maxLines: 3,
          minLines: 1,
        ),
      ],
    );
  }

  // ═══════════════════════════════════
  // Tab 2: 频率设置
  // ═══════════════════════════════════

  Widget _buildFrequencyTab(ThemeData theme, ColorScheme cs, ThemeSpacing spacing, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: spacing.formPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 频率类型
          _sectionDivider(Icons.repeat, l10n.recurringConfigFrequency),
          const SizedBox(height: 16),
          CommonCardContainer(
            padding: spacing.contentPadding,
            child: Column(
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'monthly', label: Text('按月'), icon: Icon(Icons.calendar_view_month)),
                    ButtonSegment(value: 'weekly', label: Text('按周'), icon: Icon(Icons.calendar_view_week)),
                  ],
                  selected: {_frequencyType},
                  onSelectionChanged: (v) => setState(() { _frequencyType = v.first; _frequencyValues = {}; }),
                ),
                const SizedBox(height: 16),
                _buildFrequencyValueSelector(l10n),
              ],
            ),
          ),
          SizedBox(height: spacing.formGroupSpacing),

          // 开始日期
          _sectionDivider(Icons.calendar_today, l10n.recurringConfigStartDate),
          const SizedBox(height: 16),
          CommonCardContainer(
            padding: spacing.contentPadding,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.calendar_today, color: cs.primary),
              title: Text(_startDate),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: DateTime.tryParse(_startDate) ?? DateTime.now(),
                  firstDate: DateTime(2020), lastDate: DateTime(2100),
                );
                if (d != null) setState(() => _startDate = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}');
              },
            ),
          ),
          SizedBox(height: spacing.formGroupSpacing),

          // 结束条件
          _sectionDivider(Icons.event_busy, l10n.endCondition),
          const SizedBox(height: 16),
          CommonCardContainer(
            padding: spacing.contentPadding,
            child: Column(
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'infinite', label: Text('无限')),
                    ButtonSegment(value: 'date', label: Text('指定日期')),
                    ButtonSegment(value: 'count', label: Text('指定次数')),
                  ],
                  selected: {_endType},
                  onSelectionChanged: (v) => setState(() => _endType = v.first),
                ),
                if (_endType == 'date') ...[
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.calendar_today, color: cs.primary),
                    title: Text(_endDate ?? l10n.recurringConfigEndDateHint),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2020), lastDate: DateTime(2100),
                      );
                      if (d != null) setState(() => _endDate = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}');
                    },
                  ),
                ],
                if (_endType == 'count') ...[
                  const SizedBox(height: 16),
                  CommonTextFormField(
                    labelText: l10n.recurringConfigCountLabel,
                    keyboardType: TextInputType.number,
                    initialValue: _endCount?.toString(),
                    onChanged: (v) => _endCount = int.tryParse(v),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: spacing.formGroupSpacing),
        ],
      ),
    );
  }

  Widget _buildFrequencyValueSelector(AppLocalizations l10n) {
    if (_frequencyType == 'monthly') {
      final options = List.generate(31, (i) => MultiSelectOption(key: (i + 1).toString(), name: '${i + 1}号'));
      final displayText = _frequencyValues.isEmpty ? l10n.recurringConfigEndDateHint : '每月 ${_frequencyValues.toList()..sort()} 号';
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.calendar_month),
        title: const Text('选择日期'),
        subtitle: Text(displayText),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final r = await MultiSelectSheet.show(context, title: '选择日期', options: options, selectedIds: _frequencyValues.toList());
          if (r != null) setState(() => _frequencyValues = r.toSet());
        },
      );
    } else {
      final weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
      final options = weekdays.asMap().entries.map((e) => MultiSelectOption(key: e.key.toString(), name: e.value)).toList();
      final displayText = _frequencyValues.isEmpty ? l10n.recurringConfigEndDateHint : _frequencyValues.map((k) => weekdays[int.parse(k)]).join('、');
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.calendar_view_week),
        title: const Text('选择星期'),
        subtitle: Text(displayText),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final r = await MultiSelectSheet.show(context, title: '选择星期', options: options, selectedIds: _frequencyValues.toList());
          if (r != null) setState(() => _frequencyValues = r.toSet());
        },
      );
    }
  }

  // ═══════════════════════════════════
  // 保存
  // ═══════════════════════════════════

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_frequencyValues.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(L10nManager.l10n.recurringConfigFreqRequired)));
      return;
    }

    final amount = double.parse(_amountCtrl.text);
    final frequencyValue = _frequencyValues.toList()..sort();
    final provider = context.read<RecurringConfigProvider>();

    if (_isEdit) {
      await provider.updateConfig(widget.config!.id,
        type: _type, amount: amount, description: _descCtrl.text.isEmpty ? null : _descCtrl.text,
        categoryCode: _categoryCode, fundId: _fundId, shopCode: _shopCode, tagCode: _tagCode, projectCode: _projectCode,
        frequencyType: _frequencyType, frequencyValue: frequencyValue.join(','),
        startDate: _startDate, endType: _endType,
        endDate: _endType == 'date' ? _endDate : null, endCount: _endType == 'count' ? _endCount : null,
        bookId: widget.bookId,
      );
    } else {
      await provider.createConfig(widget.bookId,
        type: _type, amount: amount, description: _descCtrl.text.isEmpty ? null : _descCtrl.text,
        categoryCode: _categoryCode!, fundId: _fundId!,
        shopCode: _shopCode, tagCode: _tagCode, projectCode: _projectCode,
        frequencyType: _frequencyType, frequencyValue: frequencyValue.join(','),
        startDate: _startDate, endType: _endType,
        endDate: _endType == 'date' ? _endDate : null, endCount: _endType == 'count' ? _endCount : null,
      );
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(L10nManager.l10n.recurringConfigSaveSuccess)));
      Navigator.pop(context, true);
    }
  }
}
