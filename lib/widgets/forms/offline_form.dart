import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../constants/account_book_icons.dart';
import '../common/common_text_form_field.dart';
import '../common/common_icon_picker.dart';
import '../../theme/theme_spacing.dart';

class OfflineForm extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController nicknameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController bookNameController;
  final String bookIcon;
  final bool isLoading;
  final ValueChanged<String>? onUsernameChanged;
  final ValueChanged<String>? onNicknameChanged;
  final ValueChanged<String>? onEmailChanged;
  final ValueChanged<String>? onPhoneChanged;
  final ValueChanged<String>? onBookNameChanged;
  final ValueChanged<String>? onBookIconChanged;
  final VoidCallback? onSubmit;

  const OfflineForm({
    super.key,
    required this.usernameController,
    required this.nicknameController,
    required this.emailController,
    required this.phoneController,
    required this.bookNameController,
    required this.bookIcon,
    this.isLoading = false,
    this.onUsernameChanged,
    this.onNicknameChanged,
    this.onEmailChanged,
    this.onPhoneChanged,
    this.onBookNameChanged,
    this.onBookIconChanged,
    this.onSubmit,
  });

  @override
  State<OfflineForm> createState() => _OfflineFormState();
}

class _OfflineFormState extends State<OfflineForm> {
  String? _selectedIcon;

  @override
  void initState() {
    super.initState();
    _selectedIcon = widget.bookIcon;
  }

  /// 选择图标
  Future<void> _selectIcon() async {
    await CommonIconPicker.show(
      context: context,
      icons: accountBookIcons,
      selectedIconCode: _selectedIcon,
      onIconSelected: (iconCode) {
        setState(() {
          _selectedIcon = iconCode;
        });
        widget.onBookIconChanged?.call(_selectedIcon!);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.spacing;

    return Column(
      children: [
        CommonTextFormField(
          controller: widget.usernameController,
          labelText: l10n.username,
          prefixIcon: const Icon(Icons.person),
          required: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.pleaseInput(l10n.username);
            }
            return null;
          },
          onChanged: widget.onUsernameChanged,
        ),
        SizedBox(height: spacing.formItemSpacing),
        CommonTextFormField(
          controller: widget.nicknameController,
          labelText: l10n.nickname,
          prefixIcon: const Icon(Icons.face),
          required: true,
          onChanged: widget.onNicknameChanged,
        ),
        if (widget.onEmailChanged != null) ...[
          SizedBox(height: spacing.formItemSpacing),
          CommonTextFormField(
            controller: widget.emailController,
            labelText: l10n.email,
            prefixIcon: const Icon(Icons.email),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegex.hasMatch(value)) {
                  return l10n.invalidEmail;
                }
              }
              return null;
            },
            onChanged: widget.onEmailChanged,
          ),
        ],
        if (widget.onPhoneChanged != null) ...[
          SizedBox(height: spacing.formItemSpacing),
          CommonTextFormField(
            controller: widget.phoneController,
            labelText: l10n.phone,
            prefixIcon: const Icon(Icons.phone),
            keyboardType: TextInputType.phone,
            onChanged: widget.onPhoneChanged,
          ),
        ],
        SizedBox(height: spacing.formItemSpacing),
        CommonTextFormField(
          controller: widget.bookNameController,
          labelText: '${l10n.accountBook}${l10n.name}',
          prefixIcon: InkWell(
            onTap: _selectIcon,
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 48,
              height: 48,
              child: Icon(
                _selectedIcon != null
                    ? IconData(int.parse(_selectedIcon!),
                        fontFamily: 'MaterialIcons')
                    : Icons.book_outlined,
                color: colorScheme.primary,
              ),
            ),
          ),
          required: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.pleaseInput(l10n.accountBook);
            }
            return null;
          },
          onChanged: widget.onBookNameChanged,
        ),
        SizedBox(height: spacing.formGroupSpacing),
        FilledButton(
          onPressed: widget.isLoading ? null : widget.onSubmit,
          child: widget.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.createLocalDatabase),
        ),
      ],
    );
  }
}
