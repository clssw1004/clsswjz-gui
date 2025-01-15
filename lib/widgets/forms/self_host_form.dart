import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../manager/l10n_manager.dart';
import '../common/common_text_form_field.dart';
import '../../theme/theme_spacing.dart';

class SelfHostForm extends StatelessWidget {
  final TextEditingController serverUrlController;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool isChecking;
  final bool serverValid;
  final bool isLoading;
  final ValueChanged<String>? onServerUrlChanged;
  final ValueChanged<String>? onUsernameChanged;
  final ValueChanged<String>? onPasswordChanged;
  final VoidCallback? onCheckServer;
  final VoidCallback? onSubmit;

  const SelfHostForm({
    super.key,
    required this.serverUrlController,
    required this.usernameController,
    required this.passwordController,
    this.isChecking = false,
    this.serverValid = false,
    this.isLoading = false,
    this.onServerUrlChanged,
    this.onUsernameChanged,
    this.onPasswordChanged,
    this.onCheckServer,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).spacing;

    return Column(
      children: [
        CommonTextFormField(
          controller: serverUrlController,
          labelText: L10nManager.l10n.serverAddress,
          hintText: 'http://example.com',
          prefixIcon: Icons.computer,
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isChecking)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  serverValid ? Icons.check_circle : Icons.error,
                  color: serverValid ? Colors.green : Colors.red,
                ),
              IconButton(
                onPressed: isChecking ? null : onCheckServer,
                icon: const Icon(Icons.refresh),
                tooltip: L10nManager.l10n.checkServer,
              ),
            ],
          ),
          required: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return L10nManager.l10n.pleaseInput(L10nManager.l10n.serverAddress);
            }
            return null;
          },
          onChanged: onServerUrlChanged,
        ),
        SizedBox(height: spacing.formItemSpacing),
        CommonTextFormField(
          controller: usernameController,
          labelText: L10nManager.l10n.username,
          prefixIcon: Icons.person,
          required: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return L10nManager.l10n.pleaseInput(L10nManager.l10n.username);
            }
            return null;
          },
          onChanged: onUsernameChanged,
        ),
        SizedBox(height: spacing.formItemSpacing),
        CommonTextFormField(
          controller: passwordController,
          labelText: L10nManager.l10n.password,
          prefixIcon: Icons.lock,
          obscureText: true,
          required: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return L10nManager.l10n.pleaseInput(L10nManager.l10n.password);
            }
            return null;
          },
          onChanged: onPasswordChanged,
        ),
        SizedBox(height: spacing.formGroupSpacing),
        FilledButton(
          onPressed: isLoading ? null : onSubmit,
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(L10nManager.l10n.connectServer),
        ),
      ],
    );
  }
}
