import 'package:flutter/material.dart';
import '../../manager/l10n_manager.dart';
import '../../theme/theme_spacing.dart';
import '../common/common_text_form_field.dart';
import 'server_url_field.dart';

class SelfHostAuthForm extends StatefulWidget {
  final bool isLoading;
  final void Function(String serverUrl, String username, String password) onSubmit;
  final String submitText;
  final String? initServerUrl;

  const SelfHostAuthForm({
    super.key,
    this.isLoading = false,
    required this.onSubmit,
    required this.submitText,
    this.initServerUrl,
  });

  @override
  State<SelfHostAuthForm> createState() => _SelfHostAuthFormState();
}

class _SelfHostAuthFormState extends State<SelfHostAuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _serverController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    widget.onSubmit(
      _serverController.text.trim(),
      _usernameController.text.trim(),
      _passwordController.text,
    );
  }

  @override
  void initState() {
    super.initState();
    _serverController.text = widget.initServerUrl ?? '';
  }

  @override
  void dispose() {
    _serverController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).spacing;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          ServerUrlField(
            controller: _serverController,
          ),
          SizedBox(height: spacing.formItemSpacing),
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
            controller: _passwordController,
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
          ),
          SizedBox(height: spacing.formGroupSpacing),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: widget.isLoading ? null : _handleSubmit,
              child: widget.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(widget.submitText),
            ),
          ),
        ],
      ),
    );
  }
} 