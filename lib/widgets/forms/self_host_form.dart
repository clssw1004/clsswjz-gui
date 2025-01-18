import 'package:flutter/material.dart';
import '../../manager/l10n_manager.dart';
import '../common/common_text_form_field.dart';
import '../../theme/theme_spacing.dart';

/// 表单数据
class SelfHostFormData {
  final String serverUrl;
  final String username;
  final String password;
  final String? nickname;
  final String? phone;
  final String? email;
  final String? bookName;

  const SelfHostFormData({
    required this.serverUrl,
    required this.username,
    required this.password,
    this.nickname,
    this.phone,
    this.email,
    this.bookName,
  });
}

enum SelfHostFormType {
  login,
  register,
}

class SelfHostForm extends StatefulWidget {
  final bool isChecking;
  final bool serverValid;
  final bool isLoading;
  final void Function(String serverUrl) onCheckServer;
  final void Function(SelfHostFormData data, SelfHostFormType type) onSubmit;

  const SelfHostForm({
    super.key,
    this.isChecking = false,
    this.serverValid = false,
    this.isLoading = false,
    required this.onCheckServer,
    required this.onSubmit,
  });

  @override
  State<SelfHostForm> createState() => _SelfHostFormState();
}

class _SelfHostFormState extends State<SelfHostForm> {
  final _formKey = GlobalKey<FormState>();
  SelfHostFormType _formType = SelfHostFormType.login;

  final _serverUrlController = TextEditingController(text: 'http://192.168.2.147:3000');
  final _usernameController = TextEditingController(text: 'lss');
  final _passwordController = TextEditingController(text: '123456');
  final _nicknameController = TextEditingController(text: 'lss');
  final _phoneController = TextEditingController(text: '13800138000');
  final _emailController = TextEditingController(text: 'admin@example.com');
  final _bookNameController = TextEditingController(text: '我的账本');

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final data = SelfHostFormData(
      serverUrl: _serverUrlController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      nickname: _formType == SelfHostFormType.register ? _nicknameController.text.trim() : null,
      phone: _formType == SelfHostFormType.register ? _phoneController.text.trim() : null,
      email: _formType == SelfHostFormType.register ? _emailController.text.trim() : null,
      bookName: _formType == SelfHostFormType.register ? _bookNameController.text.trim() : null,
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
          CommonTextFormField(
            controller: _serverUrlController,
            labelText: L10nManager.l10n.serverAddress,
            hintText: 'http://example.com',
            prefixIcon: Icons.computer,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.isChecking)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    widget.serverValid ? Icons.check_circle : Icons.error,
                    color: widget.serverValid ? Colors.green : Colors.red,
                  ),
                IconButton(
                  onPressed: widget.isChecking ? null : () => widget.onCheckServer(_serverUrlController.text.trim()),
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
            onSaved: (value) {
              if (value != null && value.isNotEmpty) {
                widget.onCheckServer(value.trim());
              }
            },
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
                        _formType = values.first ? SelfHostFormType.register : SelfHostFormType.login;
                      });
                    }
                  },
            showSelectedIcon: false,
          ),
          SizedBox(height: spacing.formItemSpacing),
          _formType == SelfHostFormType.register ? _buildRegisterForm(spacing) : _buildLoginForm(spacing),
          SizedBox(height: spacing.formGroupSpacing),
          FilledButton(
            onPressed: widget.isLoading || !widget.serverValid ? null : _handleSubmit,
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_formType == SelfHostFormType.register ? L10nManager.l10n.register : L10nManager.l10n.connectServer),
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
