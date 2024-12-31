import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../constants/account_book_icons.dart';
import '../common/common_text_form_field.dart';
import '../common/common_icon_picker.dart';

class OfflineForm extends StatefulWidget {
  final String username;
  final String nickname;
  final String? email;
  final String? phone;
  final String bookName;
  final String bookIcon;
  final bool isLoading;
  final ValueChanged<String> onUsernameChanged;
  final ValueChanged<String> onNicknameChanged;
  final ValueChanged<String>? onEmailChanged;
  final ValueChanged<String>? onPhoneChanged;
  final ValueChanged<String> onBookNameChanged;
  final ValueChanged<String> onBookIconChanged;
  final VoidCallback onSubmit;

  const OfflineForm({
    super.key,
    required this.username,
    required this.nickname,
    this.email,
    this.phone,
    required this.bookName,
    required this.bookIcon,
    required this.isLoading,
    required this.onUsernameChanged,
    required this.onNicknameChanged,
    this.onEmailChanged,
    this.onPhoneChanged,
    required this.onBookNameChanged,
    required this.onBookIconChanged,
    required this.onSubmit,
  });

  @override
  State<OfflineForm> createState() => _OfflineFormState();
}

class _OfflineFormState extends State<OfflineForm> {
  String? _selectedIcon;

  /// 选择图标
  Future<void> _selectIcon() async {
    await CommonIconPicker.show(
      context: context,
      icons: accountBookIcons,
      selectedIconCode: _selectedIcon,
      onIconSelected: (iconCode) {
        setState(() => _selectedIcon = iconCode);
        widget.onBookIconChanged(_selectedIcon!);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        CommonTextFormField(
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
        CommonTextFormField(
          labelText: l10n.nickname,
          prefixIcon: const Icon(Icons.face),
          required: true,
          onChanged: widget.onNicknameChanged,
        ),
        if (widget.onEmailChanged != null) ...[
          CommonTextFormField(
            labelText: l10n.email,
            prefixIcon: const Icon(Icons.email),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                return l10n.invalidEmail;
              }
              return null;
            },
            onChanged: widget.onEmailChanged,
          ),
        ],
        if (widget.onPhoneChanged != null) ...[
          CommonTextFormField(
            labelText: l10n.phone,
            prefixIcon: const Icon(Icons.phone),
            keyboardType: TextInputType.phone,
            onChanged: widget.onPhoneChanged,
          ),
        ],
        CommonTextFormField(
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
        const SizedBox(height: 32),
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
