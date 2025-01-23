import 'package:flutter/material.dart';
import '../../constants/account_book_icons.dart';
import '../../manager/l10n_manager.dart';
import '../common/common_text_form_field.dart';
import '../common/common_icon_picker.dart';
import '../../theme/theme_spacing.dart';

/// 离线表单数据
class OfflineFormData {
  final String username;
  final String nickname;
  final String? email;
  final String? phone;
  final String bookName;
  final String bookIcon;

  const OfflineFormData({
    required this.username,
    required this.nickname,
    required this.bookName,
    required this.bookIcon,
    this.email,
    this.phone,
  });
}

class OfflineForm extends StatefulWidget {
  final bool isLoading;
  final void Function(OfflineFormData data)? onSubmit;

  const OfflineForm({
    super.key,
    this.isLoading = false,
    this.onSubmit,
  });

  @override
  State<OfflineForm> createState() => _OfflineFormState();
}

class _OfflineFormState extends State<OfflineForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bookNameController = TextEditingController();
  String _bookIcon = Icons.book_outlined.codePoint.toString();

  /// 选择图标
  Future<void> _selectIcon() async {
    await CommonIconPicker.show(
      context: context,
      icons: accountBookIcons,
      selectedIconCode: _bookIcon,
      onIconSelected: (iconCode) {
        setState(() {
          _bookIcon = iconCode;
        });
      },
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final data = OfflineFormData(
      username: _usernameController.text.trim(),
      nickname: _nicknameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      bookName: _bookNameController.text.trim(),
      bookIcon: _bookIcon,
    );

    widget.onSubmit?.call(data);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nicknameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bookNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.spacing;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          CommonTextFormField(
            controller: _usernameController,
            labelText: L10nManager.l10n.username,
            prefixIcon: Icons.person,
            required: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return L10nManager.l10n.pleaseInput(L10nManager.l10n.username);
              }
              return null;
            },
          ),
          SizedBox(height: spacing.formItemSpacing),
          CommonTextFormField(
            controller: _nicknameController,
            labelText: L10nManager.l10n.nickname,
            prefixIcon: Icons.face,
            required: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return L10nManager.l10n.pleaseInput(L10nManager.l10n.nickname);
              }
              return null;
            },
          ),
          SizedBox(height: spacing.formItemSpacing),
          CommonTextFormField(
            controller: _emailController,
            labelText: L10nManager.l10n.email,
            prefixIcon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value)) {
                  return L10nManager.l10n.invalidEmail;
                }
              }
              return null;
            },
          ),
          SizedBox(height: spacing.formItemSpacing),
          CommonTextFormField(
            controller: _phoneController,
            labelText: L10nManager.l10n.phone,
            prefixIcon: Icons.phone,
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: spacing.formItemSpacing),
          CommonTextFormField(
            controller: _bookNameController,
            labelText: '${L10nManager.l10n.accountBook}${L10nManager.l10n.name}',
            prefixIcon: InkWell(
              onTap: _selectIcon,
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Icon(
                  IconData(int.parse(_bookIcon), fontFamily: 'MaterialIcons'),
                  color: colorScheme.primary,
                ),
              ),
            ),
            required: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return L10nManager.l10n.pleaseInput(L10nManager.l10n.accountBook);
              }
              return null;
            },
          ),
          SizedBox(height: spacing.formGroupSpacing),
          FilledButton(
            onPressed: widget.isLoading ? null : _handleSubmit,
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(L10nManager.l10n.createLocalDatabase),
          ),
        ],
      ),
    );
  }
}
