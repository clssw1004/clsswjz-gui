import 'package:clsswjz/models/common.dart';
import 'package:clsswjz/utils/toast_util.dart';
import 'package:flutter/material.dart';
import '../../constants/account_book_icons.dart';
import '../../drivers/driver_factory.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../manager/service_manager.dart';
import '../../models/vo/user_book_vo.dart';
import '../../widgets/common/common_app_bar.dart';
import '../../widgets/common/common_dialog.dart';
import '../../widgets/common/common_text_form_field.dart';
import '../../widgets/common/common_select_form_field.dart';
import '../../enums/currency_symbol.dart';
import '../../widgets/common/common_icon_picker.dart';
import '../../theme/theme_spacing.dart';
import '../../widgets/common/common_card_container.dart';

/// 账本详情编辑页面
class BookFormPage extends StatefulWidget {
  /// 账本信息（编辑模式时必传）
  final UserBookVO? book;

  const BookFormPage({
    super.key,
    this.book,
  });

  @override
  State<BookFormPage> createState() => _BookFormPageState();
}

class _BookFormPageState extends State<BookFormPage> {
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

  final inviteCodeController = TextEditingController();

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
    inviteCodeController.dispose();
    super.dispose();
  }

  Future<OperateResult<void>> create() async {
    final userId = AppConfigManager.instance.userId;
    return await DriverFactory.driver.createBook(
      userId,
      name: _nameController.text,
      description: _descriptionController.text,
      currencySymbol: _currencySymbol,
      icon: _icon,
      members: _members,
    );
  }

  Future<OperateResult<void>> update() async {
    final userId = AppConfigManager.instance.userId;

    return await DriverFactory.driver.updateBook(
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
          ToastUtil.showError(
              L10nManager.l10n.saveFailed(result.message ?? ''));
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    BookMemberVO? foundMember;
    bool isSearching = false;
    bool hasSearched = false;

    await CommonDialog.show(
      context: context,
      title: L10nManager.l10n.findUserByInviteCode,
      width: 320,
      height: 320,
      content: StatefulBuilder(
        builder: (context, setState) {
          final bool isMemberExists = foundMember != null &&
              (_members.any((m) => m.userId == foundMember!.userId) ||
                  foundMember!.userId == widget.book!.createdBy);

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withOpacity(0.5),
                  ),
                ),
                child: CommonTextFormField(
                  controller: inviteCodeController,
                  labelText: L10nManager.l10n.inviteCode,
                  required: true,
                  onChanged: (value) {
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
                        : Icon(
                            Icons.search,
                            color: inviteCodeController.text.isEmpty
                                ? colorScheme.outline
                                : colorScheme.primary,
                          ),
                    onPressed: isSearching
                        ? null
                        : () async {
                            setState(() {
                              isSearching = true;
                              hasSearched = true;
                            });
                            try {
                              final result = await ServiceManager
                                  .accountBookService
                                  .gernerateDefaultMemberByInviteCode(
                                      inviteCodeController.text);
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
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: isMemberExists
                          ? colorScheme.surfaceContainerHighest
                          : colorScheme.primaryContainer.withAlpha(100),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isMemberExists
                            ? colorScheme.outlineVariant
                            : colorScheme.primary.withAlpha(100),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isMemberExists
                                ? colorScheme.surfaceContainerHigh
                                : colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person_outline,
                            color: isMemberExists
                                ? colorScheme.onSurfaceVariant
                                : colorScheme.onPrimaryContainer,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                foundMember!.nickname ??
                                    L10nManager.l10n.unknownUser,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: isMemberExists
                                      ? colorScheme.onSurfaceVariant
                                      : colorScheme.onSurface,
                                ),
                              ),
                              if (isMemberExists)
                                Text(
                                  foundMember!.userId == widget.book!.createdBy
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
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.1),
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
                )
              else if (hasSearched && !isSearching)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer.withAlpha(100),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.error.withAlpha(100),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: colorScheme.error,
                        size: 20,
                      ),
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
        id: member.id,
        userId: member.userId,
        nickname: member.nickname,
        permission: newPermission,
      );
    });
  }

  /// 构建权限项
  Widget _buildPermissionItem(
    BuildContext context,
    String label,
    bool value,
    ValueChanged<bool> onChanged,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: value 
              ? colorScheme.primaryContainer 
              : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value 
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: value 
                    ? colorScheme.primary.withOpacity(0.2)
                    : colorScheme.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: value 
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: value 
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                fontWeight: value ? FontWeight.w600 : null,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
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
              L10nManager.l10n.basicInfo,
              style: theme.textTheme.titleMedium,
            ),
            SizedBox(height: spacing.formItemSpacing),
            CommonTextFormField(
              initialValue: _nameController.text,
              labelText: L10nManager.l10n.name,
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
                  return L10nManager.l10n.required;
                }
                return null;
              },
              onChanged: (value) => _nameController.text = value,
            ),
            SizedBox(height: spacing.formItemSpacing),
            CommonSelectFormField<CurrencySymbol>(
              items: CurrencySymbol.values,
              value: _currencySymbol.symbol,
              displayMode: DisplayMode.iconText,
              displayField: (item) => '${item.symbol} - ${item.code}',
              keyField: (item) => item.symbol,
              icon: Icons.currency_exchange,
              label: L10nManager.l10n.currency,
              required: true,
              onChanged: (value) {
                setState(() {
                  _currencySymbol = value;
                });
              },
            ),
            SizedBox(height: spacing.formItemSpacing),
            CommonTextFormField(
              initialValue: _descriptionController.text,
              labelText: L10nManager.l10n.description,
              prefixIcon: Icons.description_outlined,
              onChanged: (value) => _descriptionController.text = value,
            ),
            if (!isCreateMode) ...[
              SizedBox(height: spacing.formItemSpacing),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      L10nManager.l10n.members,
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
                      L10nManager.l10n.noMembers,
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
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final member = _members[index];
                    return CommonCardContainer(
                      padding: EdgeInsets.zero,
                      margin: EdgeInsets.zero,
                      child: _MemberItem(
                        member: member,
                        onRemove: () => _removeMember(member),
                        onPermissionChanged: (key, value) =>
                            _updateMemberPermission(member, key, value),
                      ),
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
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 用户信息头部
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_outline,
                  color: colorScheme.onPrimaryContainer,
                  size: 24,
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
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: colorScheme.error,
                  ),
                ),
                onPressed: onRemove,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // 权限设置区域
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.admin_panel_settings_outlined,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '权限设置',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.start,
                  children: [
                    _buildPermissionItem(
                      context,
                      L10nManager.l10n.canViewBook,
                      member.permission.canViewBook,
                      (value) => onPermissionChanged('canViewBook', value),
                      Icons.visibility_outlined,
                    ),
                    _buildPermissionItem(
                      context,
                      L10nManager.l10n.canEditBook,
                      member.permission.canEditBook,
                      (value) => onPermissionChanged('canEditBook', value),
                      Icons.edit_outlined,
                    ),
                    _buildPermissionItem(
                      context,
                      L10nManager.l10n.canDeleteBook,
                      member.permission.canDeleteBook,
                      (value) => onPermissionChanged('canDeleteBook', value),
                      Icons.delete_outline,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.start,
                  children: [
                    _buildPermissionItem(
                      context,
                      L10nManager.l10n.canViewItem,
                      member.permission.canViewItem,
                      (value) => onPermissionChanged('canViewItem', value),
                      Icons.visibility_outlined,
                    ),
                    _buildPermissionItem(
                      context,
                      L10nManager.l10n.canEditItem,
                      member.permission.canEditItem,
                      (value) => onPermissionChanged('canEditItem', value),
                      Icons.edit_outlined,
                    ),
                    _buildPermissionItem(
                      context,
                      L10nManager.l10n.canDeleteItem,
                      member.permission.canDeleteItem,
                      (value) => onPermissionChanged('canDeleteItem', value),
                      Icons.delete_outline,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionItem(
    BuildContext context,
    String label,
    bool value,
    ValueChanged<bool> onChanged,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: value 
              ? colorScheme.primaryContainer 
              : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value 
                ? colorScheme.primary
                : colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: value 
                    ? colorScheme.primary.withOpacity(0.2)
                    : colorScheme.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: value 
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: value 
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                fontWeight: value ? FontWeight.w600 : null,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
