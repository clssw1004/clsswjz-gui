import 'package:flutter/material.dart';

import '../../manager/l10n_manager.dart';

/// 通用文本输入框表单组件
class CommonTextFormField extends StatefulWidget {
  /// 初始值
  final String? initialValue;

  /// 标签文本
  final String? labelText;

  /// 提示文本
  final String? hintText;

  /// 前缀图标
  final dynamic prefixIcon;

  /// 后缀图标
  final dynamic suffixIcon;

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

  /// 文本控制器
  final TextEditingController? controller;

  /// 点击回调
  final VoidCallback? onTap;

  /// 最大行数，默认1行，null表示不限制行数
  final int? maxLines;

  /// 最小行数，默认等于maxLines
  final int? minLines;

  /// 文本样式
  final TextStyle? style;

  const CommonTextFormField({
    super.key,
    this.controller,
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
    this.onTap,
    this.maxLines = 1,
    this.minLines,
    this.style,
  });

  @override
  State<CommonTextFormField> createState() => _CommonTextFormFieldState();
}

class _CommonTextFormFieldState extends State<CommonTextFormField> {
  final _formKey = GlobalKey<FormFieldState>();
  final _focusNode = FocusNode();
  late TextEditingController _internalController;

  @override
  void initState() {
    super.initState();
    // 如果外部提供了controller就使用外部的，否则创建内部的
    _internalController = widget.controller ?? TextEditingController();
    // 如果没有外部controller但有initialValue，设置initialValue
    if (widget.controller == null && widget.initialValue != null) {
      _internalController.text = widget.initialValue!;
    }
  }

  @override
  void didUpdateWidget(CommonTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果initialValue改变且没有外部controller，更新文本
    if (widget.controller == null && widget.initialValue != oldWidget.initialValue) {
      _internalController.text = widget.initialValue ?? '';
    }
  }

  @override
  void dispose() {
    // 只有在使用内部controller时才dispose
    if (widget.controller == null) {
      _internalController.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  Widget? _buildIcon(dynamic icon) {
    if (icon == null) return null;
    if (icon is Widget) return icon;
    if (icon is IconData) return Icon(icon);
    if (icon is Icon) return icon;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
      child: Focus(
        onFocusChange: (hasFocus) {
          if (!hasFocus) {
            _formKey.currentState?.save();
          }
        },
        child: GestureDetector(
          onTap: widget.enabled ? null : widget.onTap,
          child: TextFormField(
            key: _formKey,
            focusNode: _focusNode,
            controller: _internalController,
            enabled: widget.enabled,
            maxLines: widget.maxLines,
            minLines: widget.minLines ?? widget.maxLines,
            style: widget.style ?? theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              labelText: widget.required ? '${widget.labelText} *' : widget.labelText,
              hintText: widget.hintText ?? (widget.required ? null : L10nManager.l10n.optional),
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
              prefixIcon: _buildIcon(widget.prefixIcon),
              suffixIcon: _buildIcon(widget.suffixIcon),
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
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withOpacity(0.5),
                ),
              ),
            ),
            onChanged: widget.onChanged,
            validator: widget.validator ??
                (widget.required
                    ? (value) {
                        if (value == null || value.isEmpty) {
                          return L10nManager.l10n.required;
                        }
                        return null;
                      }
                    : null),
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
      ),
    );
  }
}
