import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../common/common_text_form_field.dart';

class OfflineForm extends StatelessWidget {
  final String username;
  final String nickname;
  final String? email;
  final String? phone;
  final bool isLoading;
  final ValueChanged<String> onUsernameChanged;
  final ValueChanged<String> onNicknameChanged;
  final ValueChanged<String>? onEmailChanged;
  final ValueChanged<String>? onPhoneChanged;
  final VoidCallback onSubmit;

  const OfflineForm({
    super.key,
    required this.username,
    required this.nickname,
    this.email,
    this.phone,
    required this.isLoading,
    required this.onUsernameChanged,
    required this.onNicknameChanged,
    this.onEmailChanged,
    this.onPhoneChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        CommonTextFormField(
          labelText: l10n.username,
          prefixIcon: const Icon(Icons.person),
          required: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.pleaseInputUsername;
            }
            return null;
          },
          onChanged: onUsernameChanged,
        ),
        CommonTextFormField(
          labelText: l10n.nickname,
          prefixIcon: const Icon(Icons.face),
          required: true,
          onChanged: onNicknameChanged,
        ),
        if (onEmailChanged != null) ...[
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
            onChanged: onEmailChanged,
          ),
        ],
        if (onPhoneChanged != null) ...[
          CommonTextFormField(
            labelText: l10n.phone,
            prefixIcon: const Icon(Icons.phone),
            keyboardType: TextInputType.phone,
            onChanged: onPhoneChanged,
          ),
        ],
        const SizedBox(height: 32),
        FilledButton(
          onPressed: isLoading ? null : onSubmit,
          child: isLoading
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
