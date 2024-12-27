import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../common/common_text_form_field.dart';

class SelfHostForm extends StatelessWidget {
  final String serverUrl;
  final String username;
  final String password;
  final bool isChecking;
  final bool serverValid;
  final bool isLoading;
  final ValueChanged<String> onServerUrlChanged;
  final ValueChanged<String> onUsernameChanged;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onCheckServer;
  final VoidCallback onSubmit;

  const SelfHostForm({
    super.key,
    required this.serverUrl,
    required this.username,
    required this.password,
    required this.isChecking,
    required this.serverValid,
    required this.isLoading,
    required this.onServerUrlChanged,
    required this.onUsernameChanged,
    required this.onPasswordChanged,
    required this.onCheckServer,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CommonTextFormField(
                labelText: l10n.serverAddress,
                hintText: 'http://example.com',
                prefixIcon: const Icon(Icons.computer),
                suffixIcon: isChecking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        serverValid ? Icons.check_circle : Icons.error,
                        color: serverValid ? Colors.green : Colors.red,
                      ),
                required: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseInputServerAddress;
                  }
                  return null;
                },
                onChanged: onServerUrlChanged,
              ),
            ),
            IconButton(
              onPressed: isChecking ? null : onCheckServer,
              icon: const Icon(Icons.refresh),
              tooltip: l10n.checkServer,
            ),
          ],
        ),
        const SizedBox(height: 16),
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
        const SizedBox(height: 16),
        CommonTextFormField(
          labelText: l10n.password,
          prefixIcon: const Icon(Icons.lock),
          obscureText: true,
          required: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.pleaseInputPassword;
            }
            return null;
          },
          onChanged: onPasswordChanged,
        ),
        const SizedBox(height: 32),
        FilledButton(
          onPressed: isLoading ? null : onSubmit,
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.connectServer),
        ),
      ],
    );
  }
}
