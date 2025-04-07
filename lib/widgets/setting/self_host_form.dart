import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../manager/l10n_manager.dart';
import '../common/common_text_form_field.dart';
import '../common/progress_indicator_bar.dart';
import '../../theme/theme_spacing.dart';
import '../../models/self_host_form_data.dart';
import '../../enums/self_host_form_type.dart';
import '../../providers/sync_provider.dart';
import 'server_url_field.dart';

class SelfHostForm extends StatefulWidget {
  final bool isLoading;
  final void Function(SelfHostFormData data, SelfHostFormType type) onSubmit;

  const SelfHostForm({
    super.key,
    this.isLoading = false,
    required this.onSubmit,
  });

  @override
  State<SelfHostForm> createState() => _SelfHostFormState();
}

class _SelfHostFormState extends State<SelfHostForm> {
  final _formKey = GlobalKey<FormState>();
  SelfHostFormType _formType = SelfHostFormType.login;

  final _serverUrlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _bookNameController = TextEditingController();

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final data = SelfHostFormData(
      serverUrl: _serverUrlController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      nickname: _formType == SelfHostFormType.register
          ? _nicknameController.text.trim()
          : null,
      phone: _formType == SelfHostFormType.register
          ? _phoneController.text.trim()
          : null,
      email: _formType == SelfHostFormType.register
          ? _emailController.text.trim()
          : null,
      bookName: _formType == SelfHostFormType.register
          ? _bookNameController.text.trim()
          : null,
    );

    widget.onSubmit(data, _formType);
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _bookNameController.dispose();
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
            controller: _serverUrlController,
          ),
          SizedBox(height: spacing.formGroupSpacing),
          // 登录注册切换
          SegmentedButton<bool>(
            segments: [
              ButtonSegment<bool>(
                value: false,
                label: Text(L10nManager.l10n.login),
                icon: const Icon(Icons.login),
              ),
              ButtonSegment<bool>(
                value: true,
                label: Text(L10nManager.l10n.register),
                icon: const Icon(Icons.person_add),
              ),
            ],
            selected: {_formType == SelfHostFormType.register},
            onSelectionChanged: widget.isLoading
                ? null
                : (values) {
                    if (values.isNotEmpty) {
                      setState(() {
                        _formType = values.first
                            ? SelfHostFormType.register
                            : SelfHostFormType.login;
                      });
                    }
                  },
            showSelectedIcon: false,
          ),
          SizedBox(height: spacing.formItemSpacing),
          _formType == SelfHostFormType.register
              ? _buildRegisterForm(spacing)
              : _buildLoginForm(spacing),
          SizedBox(height: spacing.formGroupSpacing),
          Consumer<SyncProvider>(
            builder: (context, syncProvider, child) {
              if (syncProvider.syncing && syncProvider.currentStep != null) {
                return Padding(
                  padding: EdgeInsets.only(bottom: spacing.formItemSpacing),
                  child: ProgressIndicatorBar(
                    value: syncProvider.progress,
                    label: syncProvider.currentStep!,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          FilledButton(
            onPressed: widget.isLoading ? null : _handleSubmit,
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_formType == SelfHostFormType.register
                    ? L10nManager.l10n.registerAndSync
                    : L10nManager.l10n.loginAndSync),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(ThemeSpacing spacing) {
    return Column(
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
      ],
    );
  }

  Widget _buildRegisterForm(ThemeSpacing spacing) {
    return Column(
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
          controller: _passwordController,
          labelText: L10nManager.l10n.password,
          prefixIcon: Icons.lock,
          obscureText: true,
          required: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return L10nManager.l10n.pleaseInput(L10nManager.l10n.password);
            }
            if (value.length < 6) {
              return L10nManager.l10n.passwordTooShort;
            }
            return null;
          },
        ),
        SizedBox(height: spacing.formItemSpacing),
        CommonTextFormField(
          controller: _nicknameController,
          labelText: L10nManager.l10n.nickname,
          prefixIcon: Icons.badge,
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
          controller: _bookNameController,
          labelText: L10nManager.l10n.accountBook,
          prefixIcon: Icons.book_outlined,
          required: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return L10nManager.l10n.pleaseInput(L10nManager.l10n.accountBook);
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
      ],
    );
  }
}
