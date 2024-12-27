import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// 通用文本输入框表单组件
class CommonTextFormField extends StatefulWidget {
  /// 初始值
  final String? initialValue;

  /// 标签文本
  final String? labelText;

  /// 提示文本
  final String? hintText;

  /// 前缀图标
  final Widget? prefixIcon;

  /// 后缀图标
  final Widget? suffixIcon;

  /// 是否禁用
  final bool enabled;

  /// 值改变回调
  final ValueChanged<String>? onChanged;

  /// 验证器
  final String? Function(String?)? validator;

  /// 保存回调
  final void Function(String?)? onSaved;

  /// 是否密码输入
  final bool obscureText;

  /// 键盘类型
  final TextInputType? keyboardType;

  /// 是否必填
  final bool required;

  const CommonTextFormField({
    super.key,
    this.initialValue,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.onChanged,
    this.validator,
    this.onSaved,
    this.obscureText = false,
    this.keyboardType,
    this.required = false,
  });

  @override
  State<CommonTextFormField> createState() => _CommonTextFormFieldState();
}

class _CommonTextFormFieldState extends State<CommonTextFormField> {
  final _formKey = GlobalKey<FormFieldState>();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: theme.colorScheme.surface,
      child: Focus(
        onFocusChange: (hasFocus) {
          if (!hasFocus) {
            _formKey.currentState?.save();
          }
        },
        child: TextFormField(
          key: _formKey,
          focusNode: _focusNode,
          initialValue: widget.initialValue,
          enabled: widget.enabled,
          decoration: InputDecoration(
            labelText: widget.required ? '${widget.labelText} *' : widget.labelText,
            hintText: widget.hintText ?? (widget.required ? null : l10n.optional),
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            contentPadding: const EdgeInsets.all(16),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: theme.colorScheme.primary),
            ),
            disabledBorder: UnderlineInputBorder(
              borderSide:
                  BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
            ),
          ),
          style: theme.textTheme.bodyLarge,
          onChanged: widget.onChanged,
          validator: widget.validator ?? (widget.required ? (value) {
            if (value == null || value.isEmpty) {
              return l10n.required;
            }
            return null;
          } : null),
          onSaved: widget.onSaved,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          onEditingComplete: () {
            _focusNode.unfocus();
          },
          onFieldSubmitted: (_) {
            _focusNode.unfocus();
          },
        ),
      ),
    );
  }
}
