import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/account_book_icons.dart';
import '../../drivers/driver_factory.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../models/common.dart';
import '../../models/vo/user_book_vo.dart';
import '../../models/vo/user_fund_vo.dart';
import '../../utils/toast_util.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/common_card_container.dart';
import '../../widgets/common/common_dialog.dart';
import '../../widgets/common/common_select_form_field.dart';
import '../../widgets/common/user_avatar.dart';
import '../../enums/currency_symbol.dart';
import '../../widgets/common/common_icon_picker.dart';
import '../../widgets/common/common_user_picker.dart';
import '../../models/vo/attachment_vo.dart';
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

  String? _icon;
  CurrencySymbol _currencySymbol = CurrencySymbol.cny;
  String? _defaultFundId;
  List<UserFundVO> _funds = [];
  late List<BookMemberVO> _members;
  final Map<String, AttachmentVO?> _memberAvatars = {};
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
    if (!isCreateMode) _loadMemberAvatars(_members);

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

  Future<void> _loadMemberAvatars(List<BookMemberVO> members) async {
    final futures = members.map((m) async {
      final result = await DriverFactory.driver.getUserInfo(m.userId);
      return MapEntry(m.userId, result.ok ? result.data?.avatar : null);
    });
    final entries = await Future.wait(futures);
    _memberAvatars
      ..clear()
      ..addEntries(entries);
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
            borderRadius: BorderRadius.circular(
              theme.extension<ThemeRadius>()?.radius ?? 12,
            ),
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
                  Icon(Icons.keyboard_arrow_down_rounded,
                      color: colorScheme.onSurfaceVariant, size: 22),
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
                borderRadius: BorderRadius.circular(
                    theme.extension<ThemeRadius>()?.radius ?? 12),
                borderSide: BorderSide(
                    color: colorScheme.outline.withAlpha(50)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    theme.extension<ThemeRadius>()?.radius ?? 12),
                borderSide: BorderSide(
                    color: colorScheme.outline.withAlpha(50)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                    theme.extension<ThemeRadius>()?.radius ?? 12),
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 32, height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withAlpha(60),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  L10nManager.l10n.currency,
                  style: theme.textTheme.titleMedium?.copyWith(
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
          ),
        );
      },
    );
    if (result != null) {
      setState(() => _currencySymbol = result);
    }
  }

  // ── 默认资金账户 ──

  Widget _buildFundSection(ThemeData theme, ColorScheme colorScheme) {
    return CommonSelectFormField<UserFundVO>(
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
    );
  }

  // ── 成员管理区块 ──

  Widget _buildMembersSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Icon(Icons.people_rounded, size: 18, color: colorScheme.primary),
              const SizedBox(width: 6),
              Text(
                L10nManager.l10n.members,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              if (_members.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
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
              SizedBox(
                height: 32,
                child: FilledButton.tonalIcon(
                  onPressed: _addMember,
                  icon: const Icon(Icons.person_add_rounded, size: 16),
                  label: Text(
                    L10nManager.l10n.addUser,
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        _members.isEmpty
            ? CommonCardContainer(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.people_outline_rounded, size: 40,
                          color: colorScheme.onSurfaceVariant.withAlpha(80)),
                      const SizedBox(height: 10),
                      Text(
                        L10nManager.l10n.noMembers,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        L10nManager.l10n.inviteCode,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withAlpha(120),
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
                padding: EdgeInsets.zero,
                itemCount: _members.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final member = _members[index];
                  return _MemberCard(
                    member: member,
                    avatar: _memberAvatars[member.userId],
                    onRemove: () => _confirmRemoveMember(member),
                    onPermissionChanged: (key, value) =>
                        _updateMemberPermission(member, key, value),
                  );
                },
              ),
      ],
    );
  }

  Future<void> _addMember() async {
    final excludeIds = _members.map((m) => m.userId).toSet();
    if (widget.book != null) excludeIds.add(widget.book!.createdBy);

    final result = await CommonUserPicker.showPicker(
      context: context,
      userId: AppConfigManager.instance.userId,
      excludeIds: excludeIds,
    );

    if (result != null) {
      final newMember = BookMemberVO(
        id: result.userId,
        userId: result.userId,
        nickname: result.nickname,
        permission: AccountBookPermissionVO(
          canViewBook: true,
          canEditBook: true,
          canDeleteBook: false,
          canViewItem: true,
          canEditItem: true,
          canDeleteItem: false,
        ),
      );
      final newMembers = [..._members, newMember];
      setState(() => _members = newMembers);
      _loadMemberAvatars(newMembers);
      _scrollToBottom();
    }
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

  Future<void> _confirmRemoveMember(BookMemberVO member) async {
    final result = await CommonDialog.showWarning(
      context: context,
      message: L10nManager.l10n.deleteConfirmMessage(member.nickname ?? ''),
    );
    if (result == true && mounted) {
      _members.remove(member);
      setState(() {});
      _loadMemberAvatars(_members);
    }
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
  final AttachmentVO? avatar;
  final VoidCallback onRemove;
  final void Function(String key, bool value) onPermissionChanged;

  const _MemberCard({
    required this.member,
    this.avatar,
    required this.onRemove,
    required this.onPermissionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colorScheme.outline.withAlpha(25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // member header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 0),
            child: Row(
              children: [
                UserAvatar(avatar: avatar, size: 36),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    member.nickname ?? L10nManager.l10n.unknownUser,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: IconButton(
                    icon: Icon(Icons.remove_circle_outline_rounded,
                        color: colorScheme.error, size: 20),
                    onPressed: onRemove,
                    padding: EdgeInsets.zero,
                    tooltip: L10nManager.l10n.delete(''),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(height: 16, color: colorScheme.outline.withAlpha(15)),
                const SizedBox(height: 6),
                _PermissionTable(
                  permission: member.permission,
                  onChanged: onPermissionChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 权限切换组 ──

class _PermissionTable extends StatelessWidget {
  final AccountBookPermissionVO permission;
  final void Function(String key, bool value) onChanged;

  const _PermissionTable({
    required this.permission,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRow(
          colorScheme,
          label: L10nManager.l10n.accountBook,
          icon: Icons.menu_book_rounded,
          items: [
            _PermItem(label: L10nManager.l10n.canViewBook, icon: Icons.visibility_rounded, value: permission.canViewBook, key: 'canViewBook'),
            _PermItem(label: L10nManager.l10n.canEditBook, icon: Icons.edit_rounded, value: permission.canEditBook, key: 'canEditBook'),
            _PermItem(label: L10nManager.l10n.canDeleteBook, icon: Icons.delete_outline_rounded, value: permission.canDeleteBook, key: 'canDeleteBook'),
          ],
        ),
        const SizedBox(height: 6),
        _buildRow(
          colorScheme,
          label: L10nManager.l10n.accountItem,
          icon: Icons.receipt_rounded,
          items: [
            _PermItem(label: L10nManager.l10n.canViewItem, icon: Icons.visibility_rounded, value: permission.canViewItem, key: 'canViewItem'),
            _PermItem(label: L10nManager.l10n.canEditItem, icon: Icons.edit_rounded, value: permission.canEditItem, key: 'canEditItem'),
            _PermItem(label: L10nManager.l10n.canDeleteItem, icon: Icons.delete_outline_rounded, value: permission.canDeleteItem, key: 'canDeleteItem'),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(ColorScheme colorScheme, {required String label, required IconData icon, required List<_PermItem> items}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(30),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500, fontSize: 11)),
          const Spacer(),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(left: 6),
            child: _buildChip(colorScheme, item),
          )),
        ],
      ),
    );
  }

  Widget _buildChip(ColorScheme colorScheme, _PermItem item) {
    return GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); onChanged(item.key, !item.value); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: item.value ? colorScheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: item.value ? colorScheme.primary.withAlpha(120) : colorScheme.outline.withAlpha(40)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, size: 14, color: item.value ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant),
            const SizedBox(width: 3),
            Text(
              item.label.replaceAll(RegExp(r'(账本|账目|Book|Item)'), '').trim(),
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: item.value ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermItem {
  final String label;
  final IconData icon;
  final bool value;
  final String key;
  const _PermItem({required this.label, required this.icon, required this.value, required this.key});
}
