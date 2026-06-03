import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/account_book_icons.dart';
import '../../drivers/driver_factory.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../manager/service_manager.dart';
import '../../models/common.dart';
import '../../models/vo/user_book_vo.dart';
import '../../models/vo/user_fund_vo.dart';
import '../../utils/toast_util.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/common_card_container.dart';
import '../../widgets/common/common_dialog.dart';
import '../../widgets/common/common_select_form_field.dart';
import '../../enums/currency_symbol.dart';
import '../../widgets/common/common_icon_picker.dart';
import '../../theme/theme_radius.dart';
import '../../theme/theme_spacing.dart';

class BookFormPage extends StatefulWidget {
  final UserBookVO? book;

  const BookFormPage({
    super.key,
    this.book,
  });

  @override
  State<BookFormPage> createState() => _BookFormPageState();
}

class _BookFormPageState extends State<BookFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _listScrollController = ScrollController();
  final inviteCodeController = TextEditingController();

  String? _icon;
  CurrencySymbol _currencySymbol = CurrencySymbol.cny;
  String? _defaultFundId;
  List<UserFundVO> _funds = [];
  late List<BookMemberVO> _members;
  bool _saving = false;

  bool get isCreateMode => widget.book == null;

  final List<bool> _sectionVisible = [false, false, false];

  @override
  void initState() {
    super.initState();
    if (!isCreateMode) {
      _nameController.text = widget.book!.name;
      _descriptionController.text = widget.book!.description ?? '';
      _icon = widget.book!.icon;
      _currencySymbol = widget.book!.currencySymbol;
      _defaultFundId = widget.book!.defaultFundId;
      _members = List.from(widget.book!.members);
    } else {
      _members = [];
    }
    _loadFunds();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (int i = 0; i < _sectionVisible.length; i++) {
        Future.delayed(Duration(milliseconds: 100 * i), () {
          if (mounted) setState(() => _sectionVisible[i] = true);
        });
      }
    });
  }

  Future<void> _loadFunds() async {
    if (isCreateMode) return;
    final result = await DriverFactory.driver.listFundsByBook(
      AppConfigManager.instance.userId,
      widget.book!.id,
    );
    setState(() => _funds = result.data ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _listScrollController.dispose();
    inviteCodeController.dispose();
    super.dispose();
  }

  Future<OperateResult<void>> create() async {
    return await DriverFactory.driver.createBook(
      AppConfigManager.instance.userId,
      name: _nameController.text,
      description: _descriptionController.text,
      currencySymbol: _currencySymbol,
      icon: _icon,
      members: _members,
      defaultFundId: _defaultFundId,
    );
  }

  Future<OperateResult<void>> update() async {
    return await DriverFactory.driver.updateBook(
      AppConfigManager.instance.userId,
      widget.book!.id,
      name: _nameController.text,
      currencySymbol: _currencySymbol,
      icon: _icon,
      description: _descriptionController.text,
      members: _members,
      defaultFundId: _defaultFundId,
    );
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      final result = await (isCreateMode ? create() : update());
      if (!result.ok) {
        if (mounted) {
          ToastUtil.showError(
              L10nManager.l10n.saveFailed(result.message ?? ''));
        }
        return;
      }
      if (mounted) Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _selectIcon() async {
    await CommonIconPicker.show(
      context: context,
      icons: accountBookIcons,
      selectedIconCode: _icon,
      onIconSelected: (iconCode) => setState(() => _icon = iconCode),
    );
  }

  // ── 入场动画 ──

  Widget _buildAnimatedSection(int index, Widget child) {
    return AnimatedOpacity(
      opacity: _sectionVisible[index] ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      child: child,
    );
  }

  // ── 基础信息 Hero 区块 ──

  Widget _buildHeroSection(ThemeData theme, ColorScheme colorScheme) {
    final radius = theme.extension<ThemeRadius>()?.radius ?? 12;

    return CommonCardContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          GestureDetector(
            onTap: _selectIcon,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _icon != null
                    ? IconData(int.parse(_icon!),
                        fontFamily: 'MaterialIcons')
                    : Icons.book_outlined,
                size: 32,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _nameController,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: L10nManager.l10n.name,
              hintStyle: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface.withAlpha(80),
                fontWeight: FontWeight.w600,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return L10nManager.l10n.required;
              }
              return null;
            },
            onChanged: (value) => _nameController.text = value,
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: colorScheme.outline.withAlpha(25)),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _selectCurrency(context),
            borderRadius: BorderRadius.circular(radius),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.currency_exchange,
                      size: 20, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    '${_currencySymbol.symbol} ${_currencySymbol.code}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _currencySymbol.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: _descriptionController,
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: L10nManager.l10n.description,
              prefixIcon: Icon(Icons.description_outlined,
                  size: 20, color: colorScheme.onSurfaceVariant),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius),
                borderSide: BorderSide(
                    color: colorScheme.outline.withAlpha(50)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius),
                borderSide: BorderSide(
                    color: colorScheme.outline.withAlpha(50)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius),
                borderSide: BorderSide(
                    color: colorScheme.primary.withAlpha(120)),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              isDense: true,
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withAlpha(40),
            ),
            onChanged: (value) => _descriptionController.text = value,
          ),
        ],
      ),
    );
  }

  Future<void> _selectCurrency(BuildContext context) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final result = await showModalBottomSheet<CurrencySymbol>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 32, height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(60),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                L10nManager.l10n.currency,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...CurrencySymbol.values.map((c) => ListTile(
                leading: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: c == _currencySymbol
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      c.symbol,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: c == _currencySymbol
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                title: Text('${c.code} - ${c.name}'),
                trailing: c == _currencySymbol
                    ? Icon(Icons.check_circle_rounded,
                        color: colorScheme.primary, size: 22)
                    : null,
                onTap: () => Navigator.pop(ctx, c),
              )),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (result != null) {
      setState(() => _currencySymbol = result);
    }
  }

  // ── 默认资金账户（编辑模式） ──

  Widget _buildFundSection(ThemeData theme, ColorScheme colorScheme) {
    return CommonCardContainer(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: CommonSelectFormField<UserFundVO>(
        items: _funds,
        value: _defaultFundId,
        displayMode: DisplayMode.iconText,
        displayField: (item) => item.name,
        keyField: (item) => item.id,
        icon: Icons.account_balance_wallet_outlined,
        label: L10nManager.l10n.defaultFund,
        hint: L10nManager.l10n.optional,
        onChanged: (value) {
          final fund = value as UserFundVO?;
          setState(() => _defaultFundId = fund?.id);
        },
      ),
    );
  }

  // ── 成员管理区块 ──

  Widget _buildMembersSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Text(
                L10nManager.l10n.members,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withAlpha(150),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_members.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              FilledButton.tonalIcon(
                onPressed: _addMember,
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                label: Text(L10nManager.l10n.inviteCode),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  minimumSize: Size.zero,
                ),
              ),
            ],
          ),
        ),
        CommonCardContainer(
          padding: EdgeInsets.zero,
          child: _members.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.people_outline, size: 36,
                            color: colorScheme.onSurfaceVariant.withAlpha(80)),
                        const SizedBox(height: 8),
                        Text(
                          L10nManager.l10n.noMembers,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _listScrollController,
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  itemCount: _members.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final member = _members[index];
                    return _MemberCard(
                      member: member,
                      onRemove: () {
                        setState(() => _members.remove(member));
                      },
                      onPermissionChanged: (key, value) =>
                          _updateMemberPermission(member, key, value),
                    );
                  },
                ),
        ),
      ],
    );
  }

  /// 搜索添加成员
  Future<void> _addMember() async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final radius = theme.extension<ThemeRadius>()?.radius ?? 12;
    final inviteController = TextEditingController();
    BookMemberVO? foundMember;
    bool isSearching = false;
    bool hasSearched = false;

    await CommonDialog.show(
      context: context,
      title: L10nManager.l10n.findUserByInviteCode,
      width: 320,
      height: 320,
      content: StatefulBuilder(
        builder: (ctx, setDialogState) {
          final isMemberExists = foundMember != null &&
              (_members.any((m) => m.userId == foundMember!.userId) ||
                  foundMember!.userId == widget.book!.createdBy);

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: inviteController,
                autofocus: true,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: L10nManager.l10n.inviteCode,
                  prefixIcon: Icon(Icons.qr_code_outlined,
                      color: colorScheme.primary),
                  suffixIcon: isSearching
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.primary,
                          ),
                        )
                      : IconButton(
                          icon: Icon(Icons.search,
                              color: inviteController.text.isEmpty
                                  ? colorScheme.outline
                                  : colorScheme.primary),
                          onPressed: inviteController.text.isEmpty
                              ? null
                              : () async {
                                  setDialogState(() {
                                    isSearching = true;
                                    hasSearched = true;
                                  });
                                  try {
                                    final result = await ServiceManager
                                        .accountBookService
                                        .gernerateDefaultMemberByInviteCode(
                                            inviteController.text);
                                    setDialogState(() {
                                      foundMember =
                                          result.ok ? result.data : null;
                                    });
                                  } finally {
                                    setDialogState(
                                        () => isSearching = false);
                                  }
                                },
                        ),
                  filled: true,
                  fillColor:
                      colorScheme.surfaceContainerHighest.withAlpha(50),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(radius),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                ),
                onChanged: (value) {
                  if (hasSearched) {
                    setDialogState(() {
                      foundMember = null;
                      hasSearched = false;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              if (foundMember != null)
                _buildSearchResult(
                  theme,
                  colorScheme,
                  radius,
                  foundMember!,
                  isMemberExists,
                  () {
                    setState(() => _members = [..._members, foundMember!]);
                    _scrollToBottom();
                    Navigator.of(ctx).pop();
                  },
                )
              else if (hasSearched && !isSearching)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer.withAlpha(100),
                    borderRadius: BorderRadius.circular(radius),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: colorScheme.error, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        L10nManager.l10n.userNotFound,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
    inviteController.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_listScrollController.hasClients) {
        _listScrollController.animateTo(
          _listScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildSearchResult(
    ThemeData theme,
    ColorScheme colorScheme,
    double radius,
    BookMemberVO member,
    bool isMemberExists,
    VoidCallback onAdd,
  ) {
    return InkWell(
      onTap: isMemberExists ? null : onAdd,
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isMemberExists
              ? colorScheme.surfaceContainerHighest
              : colorScheme.primaryContainer.withAlpha(80),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: isMemberExists
                ? colorScheme.outlineVariant
                : colorScheme.primary.withAlpha(80),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: isMemberExists
                  ? colorScheme.surfaceContainerHigh
                  : colorScheme.primaryContainer,
              child: Icon(
                Icons.person_outline,
                color: isMemberExists
                    ? colorScheme.onSurfaceVariant
                    : colorScheme.onPrimaryContainer,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.nickname ?? L10nManager.l10n.unknownUser,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isMemberExists
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (isMemberExists)
                    Text(
                      member.userId == widget.book!.createdBy
                          ? L10nManager.l10n.bookCreator
                          : L10nManager.l10n.memberAlreadyExists,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                ],
              ),
            ),
            if (!isMemberExists)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_add_outlined,
                  color: colorScheme.primary,
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 更新成员权限
  void _updateMemberPermission(
      BookMemberVO member, String permissionKey, bool value) {
    final index = _members.indexOf(member);
    if (index == -1) return;

    final newPermission = AccountBookPermissionVO(
      canViewBook: permissionKey == 'canViewBook'
          ? value
          : member.permission.canViewBook,
      canEditBook: permissionKey == 'canEditBook'
          ? value
          : member.permission.canEditBook,
      canDeleteBook: permissionKey == 'canDeleteBook'
          ? value
          : member.permission.canDeleteBook,
      canViewItem: permissionKey == 'canViewItem'
          ? value
          : member.permission.canViewItem,
      canEditItem: permissionKey == 'canEditItem'
          ? value
          : member.permission.canEditItem,
      canDeleteItem: permissionKey == 'canDeleteItem'
          ? value
          : member.permission.canDeleteItem,
    );

    setState(() {
      _members[index] = BookMemberVO(
        id: member.id,
        userId: member.userId,
        nickname: member.nickname,
        permission: newPermission,
      );
    });
  }

  // ── 保存按钮 ──

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _saving ? null : _save,
        icon: _saving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.save_outlined),
        label: Text(L10nManager.l10n.save),
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.spacing;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(isCreateMode
            ? L10nManager.l10n.addNew(L10nManager.l10n.accountBook)
            : L10nManager.l10n.editTo(L10nManager.l10n.accountBook)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: spacing.formPadding,
          children: [
            _buildAnimatedSection(0, _buildHeroSection(theme, colorScheme)),
            SizedBox(height: spacing.formGroupSpacing),
            if (!isCreateMode) ...[
              _buildAnimatedSection(1, _buildFundSection(theme, colorScheme)),
              SizedBox(height: spacing.formGroupSpacing),
            ],
            if (!isCreateMode)
              _buildAnimatedSection(2, _buildMembersSection(theme, colorScheme)),
            if (!isCreateMode)
              SizedBox(height: spacing.formGroupSpacing),
            _buildSaveButton(),
            SizedBox(height: spacing.formGroupSpacing),
          ],
        ),
      ),
    );
  }
}

// ── 成员卡片 ──

class _MemberCard extends StatelessWidget {
  final BookMemberVO member;
  final VoidCallback onRemove;
  final void Function(String key, bool value) onPermissionChanged;

  const _MemberCard({
    required this.member,
    required this.onRemove,
    required this.onPermissionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 成员信息行
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: colorScheme.secondaryContainer,
                  child: Text(
                    (member.nickname ?? '?').substring(0, 1).toUpperCase(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    member.nickname ?? L10nManager.l10n.unknownUser,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer.withAlpha(160),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close_rounded,
                        color: colorScheme.error, size: 18),
                  ),
                  onPressed: onRemove,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                ),
              ],
            ),
          ),
          // 权限区域
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 1,
                  color: colorScheme.outline.withAlpha(15),
                ),
                const SizedBox(height: 12),
                _buildPermissionRow(
                  theme: theme,
                  colorScheme: colorScheme,
                  label: L10nManager.l10n.accountBook,
                  keys: const ['canViewBook', 'canEditBook', 'canDeleteBook'],
                  labels: const ['', '', ''],
                  icons: const [
                    Icons.visibility_outlined,
                    Icons.edit_outlined,
                    Icons.delete_outline,
                  ],
                  values: [
                    member.permission.canViewBook,
                    member.permission.canEditBook,
                    member.permission.canDeleteBook,
                  ],
                ),
                const SizedBox(height: 8),
                _buildPermissionRow(
                  theme: theme,
                  colorScheme: colorScheme,
                  label: L10nManager.l10n.accountItem,
                  keys: const ['canViewItem', 'canEditItem', 'canDeleteItem'],
                  labels: const ['', '', ''],
                  icons: const [
                    Icons.visibility_outlined,
                    Icons.edit_outlined,
                    Icons.delete_outline,
                  ],
                  values: [
                    member.permission.canViewItem,
                    member.permission.canEditItem,
                    member.permission.canDeleteItem,
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionRow({
    required ThemeData theme,
    required ColorScheme colorScheme,
    required String label,
    required List<String> keys,
    required List<String> labels,
    required List<IconData> icons,
    required List<bool> values,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withAlpha(150),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
                fontSize: 10,
              ),
            ),
          ),
        ),
        Row(
          children: List.generate(keys.length, (i) {
            final permissionLabel = labels[i].isNotEmpty
                ? labels[i]
                : _defaultLabel(keys[i]);
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    right: i < keys.length - 1 ? 8 : 0),
                child: _PermissionChip(
                  icon: icons[i],
                  label: permissionLabel,
                  value: values[i],
                  onChanged: (v) => onPermissionChanged(keys[i], v),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  String _defaultLabel(String key) {
    switch (key) {
      case 'canViewBook': return L10nManager.l10n.canViewBook;
      case 'canEditBook': return L10nManager.l10n.canEditBook;
      case 'canDeleteBook': return L10nManager.l10n.canDeleteBook;
      case 'canViewItem': return L10nManager.l10n.canViewItem;
      case 'canEditItem': return L10nManager.l10n.canEditItem;
      case 'canDeleteItem': return L10nManager.l10n.canDeleteItem;
      default: return '';
    }
  }
}

// ── 权限开关芯片 ──

class _PermissionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PermissionChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        decoration: BoxDecoration(
          color: value
              ? colorScheme.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: value
                ? colorScheme.primary.withAlpha(150)
                : colorScheme.outline.withAlpha(35),
            width: value ? 1.2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: value
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: value
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                fontWeight: value ? FontWeight.w600 : null,
                fontSize: 10,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
