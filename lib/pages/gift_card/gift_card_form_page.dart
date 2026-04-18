import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/gift_card_icons.dart';
import '../../manager/app_config_manager.dart';
import '../../manager/dao_manager.dart';
import '../../manager/l10n_manager.dart';
import '../../models/vo/gift_card_vo.dart';
import '../../providers/gift_card_provider.dart';
import '../../widgets/common/common_icon_picker.dart';
import '../../widgets/common/common_select_form_field.dart';
import '../../widgets/common/common_text_form_field.dart';

/// 接收人选项
class RecipientOption {
  final String userId;
  final String nickname;
  final bool isFromInviteCode;

  const RecipientOption({
    required this.userId,
    required this.nickname,
    this.isFromInviteCode = false,
  });
}

/// 礼物卡表单页面（创建/编辑）
class GiftCardFormPage extends StatefulWidget {
  const GiftCardFormPage({super.key, this.giftCard});

  final GiftCardVO? giftCard;

  @override
  State<GiftCardFormPage> createState() => _GiftCardFormPageState();
}

class _GiftCardFormPageState extends State<GiftCardFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _inviteCodeController = TextEditingController();

  /// 图标
  String? _icon;

  DateTime? _expiredTime;
  bool _saving = false;
  bool _searching = false;
  bool _loadingRecipients = false;
  String? _toUserId;
  String? _toUserNickname;
  List<RecipientOption> _recipientOptions = [];
  RecipientOption? _selectedRecipient;


  bool get isCreateMode => widget.giftCard == null;
  bool get isEditable => isCreateMode || widget.giftCard!.status.code == 'draft';

  @override
  void initState() {
    super.initState();
    _loadCurrentUserName();
    _loadRecipientOptions();

    if (!isCreateMode) {
      _descriptionController.text = widget.giftCard!.description ?? '';
      _toUserId = widget.giftCard!.toUserId;
      _toUserNickname = widget.giftCard!.toUserNickname;
      if (widget.giftCard!.expiredTime > 0) {
        _expiredTime = DateTime.fromMillisecondsSinceEpoch(widget.giftCard!.expiredTime);
      }
      // 确保当前接收人在下拉选项中（可能不在账本成员中）
      _ensureRecipientInOptions();
    }
  }

  /// 确保接收人在下拉选项中
  void _ensureRecipientInOptions() {
    if (_toUserId != null && _toUserNickname != null) {
      final exists = _recipientOptions.any((o) => o.userId == _toUserId);
      if (!exists) {
        _recipientOptions.add(RecipientOption(
          userId: _toUserId!,
          nickname: _toUserNickname!,
        ));
      }
    }
  }

  /// 加载当前用户名称
  String _currentUserName = '';

  Future<void> _loadCurrentUserName() async {
    final user = await DaoManager.userDao.findById(AppConfigManager.instance.userId);
    if (mounted && user != null) {
      setState(() {
        _currentUserName = user.nickname.isNotEmpty ? user.nickname : user.username;
      });
    }
  }

  /// 加载可选接收人列表（从账本关联成员中获取）
  Future<void> _loadRecipientOptions() async {
    setState(() => _loadingRecipients = true);

    try {
      final provider = context.read<GiftCardProvider>();
      final recipients = await provider.getSelectableRecipients();

      if (mounted) {
        setState(() {
          _recipientOptions = recipients
              .map((r) => RecipientOption(
                    userId: r.id,
                    nickname: r.nickname,
                  ))
              .toList();
          _loadingRecipients = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingRecipients = false);
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isCreateMode ? L10nManager.l10n.createGiftCard : L10nManager.l10n.editGiftCard),
        actions: [
          TextButton(
            onPressed: _saving || !isEditable ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(L10nManager.l10n.save),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 赠送人（只读，显示当前用户名称）
            _buildInfoRow(
              icon: Icons.person_outline,
              label: L10nManager.l10n.sender,
              value: _currentUserName,
            ),
            const SizedBox(height: 20),

            // 接收人选择
            Text(
              L10nManager.l10n.recipient,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            if (!isEditable)
              _buildInfoRow(
                icon: Icons.person,
                label: L10nManager.l10n.recipient,
                value: _toUserNickname ?? '',
              )
            else
              _buildRecipientSelector(),
            const SizedBox(height: 20),

            // 礼品描述（必填）
            CommonTextFormField(
              initialValue: _descriptionController.text,
              labelText: L10nManager.l10n.giftDescription,
              hintText: L10nManager.l10n.giftDescriptionHint,
              required: true,
              prefixIcon: isEditable
                  ? InkWell(
                      onTap: _selectIcon,
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Icon(
                          _icon != null
                              ? IconData(int.parse(_icon!), fontFamily: 'MaterialIcons')
                              : Icons.card_giftcard,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    )
                  : Icon(
                      _icon != null
                          ? IconData(int.parse(_icon!), fontFamily: 'MaterialIcons')
                          : Icons.card_giftcard,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              maxLines: 3,
              maxLength: 500,
              onChanged: (value) => _descriptionController.text = value,
              enabled: isEditable,
            ),
            const SizedBox(height: 20),

            // 过期时间
            if (isEditable) ...[
              Text(
                L10nManager.l10n.expiredTime,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              _buildExpiredTimeSelector(),
            ] else ...[
              _buildInfoRow(
                icon: Icons.calendar_today,
                label: L10nManager.l10n.expiredTime,
                value: _expiredTime != null
                    ? DateFormat('yyyy-MM-dd 23:59:59').format(_expiredTime!)
                    : L10nManager.l10n.permanent,
              ),
            ],

            // 提示信息
            if (!isCreateMode) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${L10nManager.l10n.status}: ${widget.giftCard!.status.text}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${L10nManager.l10n.createdAt}: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(widget.giftCard!.createdAt))}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建信息行（只读显示）
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 切换方式：false = 下拉选择, true = 邀请码搜索
  bool _useInviteCode = false;

  /// 构建接收人选择器
  Widget _buildRecipientSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 切换按钮
        Row(
          children: [
            Expanded(
              child: _buildToggleButton(
                label: L10nManager.l10n.selectFromMembers,
                icon: Icons.people_outline,
                isSelected: !_useInviteCode,
                onTap: _loadingRecipients
                    ? null
                    : () {
                        setState(() {
                          _useInviteCode = false;
                        });
                      },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildToggleButton(
                label: L10nManager.l10n.searchByInviteCode,
                icon: Icons.qr_code,
                isSelected: _useInviteCode,
                onTap: () {
                  setState(() {
                    _useInviteCode = true;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 根据切换状态显示不同输入组件
        if (!_useInviteCode)
          _buildDropdownSelector()
        else
          _buildInviteCodeInput(),
      ],
    );
  }

  /// 构建切换按钮
  Widget _buildToggleButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer : colorScheme.surface,
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? colorScheme.primary : colorScheme.onSurface,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建下拉选择器（使用通用选择组件）
  Widget _buildDropdownSelector() {
    if (_loadingRecipients) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return CommonSelectFormField<RecipientOption>(
      items: _recipientOptions,
      value: _toUserId,
      displayMode: DisplayMode.iconText,
      displayField: (item) => item.nickname,
      keyField: (item) => item.userId,
      icon: Icons.person_outline,
      label: L10nManager.l10n.recipient,
      allowCreate: false,
      onChanged: (value) {
        final option = value as RecipientOption?;
        if (option != null) {
          setState(() {
            _toUserId = option.userId;
            _toUserNickname = option.nickname;
            _selectedRecipient = option;
          });
        } else {
          setState(() {
            _toUserId = null;
            _toUserNickname = null;
            _selectedRecipient = null;
          });
        }
        _formKey.currentState?.validate();
      },
      validator: (value) {
        if (value == null) {
          return L10nManager.l10n.selectRecipient;
        }
        return null;
      },
    );
  }

  /// 构建邀请码输入
  Widget _buildInviteCodeInput() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _inviteCodeController,
          decoration: InputDecoration(
            hintText: L10nManager.l10n.inviteCode,
            prefixIcon: const Icon(Icons.qr_code),
            suffixIcon: _searching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: isEditable ? _searchUserByInviteCode : null,
                  ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          textInputAction: TextInputAction.search,
          onFieldSubmitted: isEditable ? (_) => _searchUserByInviteCode() : null,
          enabled: isEditable,
        ),

        // 显示已选择的邀请码用户
        if (_selectedRecipient != null && _selectedRecipient!.isFromInviteCode) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 20,
                  color: colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${L10nManager.l10n.recipient}: ${_selectedRecipient!.nickname}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// 构建过期时间选择器
  Widget _buildExpiredTimeSelector() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 永久有效开关
        Row(
          children: [
            Expanded(
              child: Text(
                L10nManager.l10n.permanent,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            Switch(
              value: _expiredTime == null,
              onChanged: (value) {
                setState(() {
                  if (value) {
                    _expiredTime = null;
                  } else {
                    _expiredTime = DateTime.now().add(const Duration(days: 365));
                  }
                });
              },
            ),
          ],
        ),
        if (_expiredTime != null) ...[
          const SizedBox(height: 8),
          InkWell(
            onTap: _selectExpiredTime,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.outline),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      DateFormat('yyyy-MM-dd').format(_expiredTime!),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                  Text(
                    '23:59:59',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    color: colorScheme.outline,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _selectExpiredTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expiredTime ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (date != null && mounted) {
      setState(() {
        _expiredTime = DateTime(
          date.year,
          date.month,
          date.day,
          23,
          59,
          59,
        );
      });
    }
  }

  /// 选择图标
  Future<void> _selectIcon() async {
    await CommonIconPicker.show(
      context: context,
      icons: giftCardIcons,
      selectedIconCode: _icon,
      onIconSelected: (iconCode) {
        setState(() => _icon = iconCode);
      },
    );
  }

  /// 根据邀请码查找用户
  Future<void> _searchUserByInviteCode() async {
    final inviteCode = _inviteCodeController.text.trim();
    if (inviteCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(L10nManager.l10n.inviteCode)),
      );
      return;
    }

    setState(() => _searching = true);

    try {
      final provider = context.read<GiftCardProvider>();
      final result = await provider.findUserByInviteCode(inviteCode);

      if (result.ok && result.data != null && mounted) {
        final data = result.data!;
        setState(() {
          _toUserId = data.id;
          _toUserNickname = data.nickname;
          _selectedRecipient = RecipientOption(
            userId: data.id,
            nickname: data.nickname,
            isFromInviteCode: true,
          );
        });
        _formKey.currentState?.validate();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message ?? L10nManager.l10n.invalidInviteCode)),
        );
        setState(() {
          _toUserId = null;
          _toUserNickname = null;
          _selectedRecipient = null;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _searching = false);
      }
    }
  }

  Future<void> _save() async {
    // 验证表单
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 验证接收人
    if (_toUserId == null || _toUserNickname == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(L10nManager.l10n.selectRecipient)),
      );
      return;
    }

    // 验证不能赠送给自己
    if (_toUserId == AppConfigManager.instance.userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(L10nManager.l10n.cannotSendToSelf)),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final provider = context.read<GiftCardProvider>();

      if (isCreateMode) {
        final result = await provider.createGiftCard(
          toUserId: _toUserId!,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          expiredTime: _expiredTime?.millisecondsSinceEpoch,
        );

        if (result.ok && mounted) {
          Navigator.pop(context, true);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.message ?? L10nManager.l10n.operationFailed)),
          );
        }
      } else {
        final result = await provider.updateGiftCard(
          id: widget.giftCard!.id,
          toUserId: _toUserId!,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          expiredTime: _expiredTime?.millisecondsSinceEpoch,
        );

        if (result.ok && mounted) {
          Navigator.pop(context, true);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.message ?? L10nManager.l10n.operationFailed)),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}