import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/theme_radius.dart';

/// 共用选择触发器 — 图标文本模式下的 TextFormField
/// 供 [TreeSelectFormField] 和 [CommonSelectFormField] 共用
class SelectionTrigger extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? errorText;
  final String displayText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final double? prefixIconSize;

  const SelectionTrigger({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    required this.displayText,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.prefixIconSize,
  });

  @override
  State<SelectionTrigger> createState() => _SelectionTriggerState();
}

class _SelectionTriggerState extends State<SelectionTrigger>
    with SingleTickerProviderStateMixin {
  bool _isOpening = false;

  void _handleTap() {
    setState(() => _isOpening = true);
    HapticFeedback.selectionClick();
    widget.onTap?.call();
    // 延迟重置动画状态，等 sheet 关闭
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _isOpening = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final radius = theme.extension<ThemeRadius>()?.radius ?? 12;

    return TextFormField(
      readOnly: true,
      onTap: _handleTap,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        errorText: widget.errorText,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withAlpha(30),
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon,
                size: widget.prefixIconSize ?? 20,
                color: colorScheme.onSurfaceVariant)
            : null,
        suffixIcon: widget.suffixIcon ??
            AnimatedRotation(
              turns: _isOpening ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: const Icon(Icons.keyboard_arrow_down_rounded),
            ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: colorScheme.outline.withAlpha(60)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: colorScheme.outline.withAlpha(60)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(
            color: colorScheme.primary.withAlpha(120),
            width: 1.5,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: colorScheme.outline.withAlpha(30)),
        ),
      ),
      controller: TextEditingController(text: widget.displayText),
      style: theme.textTheme.bodyLarge,
    );
  }
}
