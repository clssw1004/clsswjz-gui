import 'package:clsswjz/models/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../constants/account_book_icons.dart';
import '../../drivers/driver_factory.dart';
import '../../manager/service_manager.dart';
import '../../manager/user_config_manager.dart';
import '../../models/vo/account_book_permission_vo.dart';
import '../../models/vo/book_member_vo.dart';
import '../../models/vo/user_book_vo.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/common_dialog.dart';
import '../../widgets/common/common_text_form_field.dart';
import '../../widgets/common/common_select_form_field.dart';
import '../../enums/currency_symbol.dart';
import '../../widgets/common/common_icon_picker.dart';
import '../../theme/theme_spacing.dart';

/// 账本详情编辑页面
class AccountBookFormPage extends StatefulWidget {
  /// 账本信息（编辑模式时必传）
  final UserBookVO? book;

  const AccountBookFormPage({
    super.key,
    this.book,
  });

  @override
  State<AccountBookFormPage> createState() => _AccountBookFormPageState();
}

class _AccountBookFormPageState extends State<AccountBookFormPage> {
  /// 表单Key
  final _formKey = GlobalKey<FormState>();

  /// 名称控制器
  final _nameController = TextEditingController();

  /// 描述控制器
  final _descriptionController = TextEditingController();

  /// 图标
  String? _icon;

  /// 货币符号
  CurrencySymbol _currencySymbol = CurrencySymbol.cny;

  /// 成员列表
  late List<BookMemberVO> _members;

  /// 是否正在保存
  bool _saving = false;

  /// 是否为新增模式
  bool get isCreateMode => widget.book == null;

  @override
  void initState() {
    super.initState();
    if (!isCreateMode) {
      _nameController.text = widget.book!.name;
      _descriptionController.text = widget.book!.description ?? '';
      _icon = widget.book!.icon;
      _currencySymbol = widget.book!.currencySymbol;
      _members = List.from(widget.book!.members);
    } else {
      _members = [];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<OperateResult<void>> create() async {
    final userId = UserConfigManager.currentUserId;
    final l10n = AppLocalizations.of(context)!;
    final result = await DriverFactory.bookDataDriver.createBook(
      userId,
      name: _nameController.text,
      description: _descriptionController.text,
      currencySymbol: _currencySymbol,
      icon: _icon,
      members: _members,
    );
    if (result.ok) {
      final bookId = result.data!;
      await ServiceManager.accountBookService.initBookDefaultData(
        bookId: bookId,
        userId: userId,
        defaultCategoryName: l10n.noCategory,
        defaultShopName: l10n.noShop,
      );

      return OperateResult.success(null);
    } else {
      return OperateResult.failWithMessage(
          message: result.message, exception: result.exception);
    }
  }

  Future<OperateResult<void>> update() async {
    final userId = UserConfigManager.currentUserId;

    return await DriverFactory.bookDataDriver.updateBook(
      userId,
      widget.book!.id,
      name: _nameController.text,
      currencySymbol: _currencySymbol,
      icon: _icon,
      description: _descriptionController.text,
      members: _members,
    );
  }

  /// 保存
  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
    });

    try {
      final result = await (isCreateMode ? create() : update());

      if (!result.ok) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!
                  .saveFailed(result.message ?? '')),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        return;
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  /// 选择图标
  Future<void> _selectIcon() async {
    await CommonIconPicker.show(
      context: context,
      icons: accountBookIcons,
      selectedIconCode: _icon,
      onIconSelected: (iconCode) {
        setState(() => _icon = iconCode);
      },
    );
  }

  /// 添加成员
  Future<void> _addMember() async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String inviteCode = '';
    BookMemberVO? foundMember;
    bool isSearching = false;
    bool hasSearched = false;

    await CommonDialog.show(
      context: context,
      title: l10n.findUserByInviteCode,
      width: 320,
      height: 250,
      content: StatefulBuilder(
        builder: (context, setState) {
          final bool isMemberExists = foundMember != null &&
              (_members.any((m) => m.userId == foundMember!.userId) ||
                  foundMember!.userId == widget.book!.createdBy);

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonTextFormField(
                labelText: l10n.inviteCode,
                required: true,
                onChanged: (value) {
                  inviteCode = value;
                  if (hasSearched) {
                    setState(() {
                      foundMember = null;
                      hasSearched = false;
                    });
                  }
                },
                suffixIcon: IconButton(
                  icon: isSearching
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search),
                  onPressed: inviteCode.isEmpty || isSearching
                      ? null
                      : () async {
                          setState(() {
                            isSearching = true;
                            hasSearched = true;
                          });
                          try {
                            final result = await ServiceManager
                                .accountBookService
                                .gernerateDefaultMemberByInviteCode(inviteCode);
                            setState(() {
                              foundMember = result.ok ? result.data : null;
                            });
                          } finally {
                            setState(() {
                              isSearching = false;
                            });
                          }
                        },
                ),
              ),
              const SizedBox(height: 16),
              if (foundMember != null)
                InkWell(
                  onTap: isMemberExists
                      ? null
                      : () {
                          this.setState(() {
                            _members = [..._members, foundMember!];
                          });
                          Navigator.of(context).pop();
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isMemberExists
                          ? colorScheme.outline
                          : colorScheme.primaryContainer.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                foundMember!.nickname ?? l10n.unknownUser,
                                style: theme.textTheme.bodyLarge,
                              ),
                              if (isMemberExists)
                                Text(
                                  foundMember!.userId == widget.book!.createdBy
                                      ? l10n.bookCreator
                                      : l10n.memberAlreadyExists,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.outline,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (!isMemberExists)
                          Icon(
                            Icons.person_add_outlined,
                            color: colorScheme.primary,
                          ),
                      ],
                    ),
                  ),
                )
              else if (hasSearched && !isSearching)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    l10n.userNotFound,
                    style: TextStyle(color: colorScheme.error),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// 删除成员
  void _removeMember(BookMemberVO member) {
    setState(() {
      _members.remove(member);
    });
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
        userId: member.userId,
        nickname: member.nickname,
        permission: newPermission,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.spacing;

    return Scaffold(
      appBar: CommonAppBar(
        title: Text(isCreateMode
            ? l10n.addNew(l10n.accountBook)
            : l10n.editTo(l10n.accountBook)),
        actions: [
          IconButton(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
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
            Text(
              l10n.basicInfo,
              style: theme.textTheme.titleMedium,
            ),
            SizedBox(height: spacing.formItemSpacing),
            CommonTextFormField(
              initialValue: _nameController.text,
              labelText: l10n.name,
              required: true,
              prefixIcon: InkWell(
                onTap: _selectIcon,
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Icon(
                    _icon != null
                        ? IconData(int.parse(_icon!),
                            fontFamily: 'MaterialIcons')
                        : Icons.book_outlined,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.required;
                }
                return null;
              },
              onChanged: (value) => _nameController.text = value,
            ),
            SizedBox(height: spacing.formItemSpacing),
            CommonTextFormField(
              initialValue: _descriptionController.text,
              labelText: l10n.description,
              prefixIcon: Icons.description_outlined,
              onChanged: (value) => _descriptionController.text = value,
            ),
            SizedBox(height: spacing.formItemSpacing),
            CommonSelectFormField<CurrencySymbol>(
              items: CurrencySymbol.values,
              value: _currencySymbol.symbol,
              displayMode: DisplayMode.iconText,
              displayField: (item) => '${item.symbol} - ${item.code}',
              keyField: (item) => item.symbol,
              icon: Icons.currency_exchange,
              label: l10n.currency,
              required: true,
              onChanged: (value) {
                setState(() {
                  _currencySymbol = value;
                });
              },
            ),
            if (!isCreateMode) ...[
              SizedBox(height: spacing.formItemSpacing),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.members,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: _addMember,
                    icon: const Icon(Icons.person_add_outlined),
                  ),
                ],
              ),
              if (_members.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      l10n.noMembers,
                      style: TextStyle(color: colorScheme.outline),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _members.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final member = _members[index];
                    return _MemberItem(
                      member: member,
                      onRemove: () => _removeMember(member),
                      onPermissionChanged: (key, value) =>
                          _updateMemberPermission(member, key, value),
                    );
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 成员列表项
class _MemberItem extends StatelessWidget {
  final BookMemberVO member;
  final VoidCallback onRemove;
  final void Function(String key, bool value) onPermissionChanged;

  const _MemberItem({
    required this.member,
    required this.onRemove,
    required this.onPermissionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ExpansionTile(
      title: Text(member.nickname ?? l10n.unknownUser),
      leading: const Icon(Icons.person_outline),
      trailing: IconButton(
        icon: const Icon(Icons.remove_circle_outline),
        onPressed: onRemove,
      ),
      children: [
        _buildPermissionSwitch(
          context,
          l10n.canViewBook,
          'canViewBook',
          member.permission.canViewBook,
        ),
        _buildPermissionSwitch(
          context,
          l10n.canEditBook,
          'canEditBook',
          member.permission.canEditBook,
        ),
        _buildPermissionSwitch(
          context,
          l10n.canDeleteBook,
          'canDeleteBook',
          member.permission.canDeleteBook,
        ),
        _buildPermissionSwitch(
          context,
          l10n.canViewItem,
          'canViewItem',
          member.permission.canViewItem,
        ),
        _buildPermissionSwitch(
          context,
          l10n.canEditItem,
          'canEditItem',
          member.permission.canEditItem,
        ),
        _buildPermissionSwitch(
          context,
          l10n.canDeleteItem,
          'canDeleteItem',
          member.permission.canDeleteItem,
        ),
      ],
    );
  }

  Widget _buildPermissionSwitch(
    BuildContext context,
    String label,
    String key,
    bool value,
  ) {
    return SwitchListTile(
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      value: value,
      onChanged: (newValue) => onPermissionChanged(key, newValue),
    );
  }
}
