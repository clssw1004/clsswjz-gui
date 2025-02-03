import 'package:flutter/material.dart';

class CommonSearchField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final double? width;
  final bool autofocus;
  final bool showBorder;
  final bool enableShadow;

  const CommonSearchField({
    super.key,
    this.controller,
    this.hintText,
    this.onSubmitted,
    this.onChanged,
    this.onClear,
    this.width,
    this.autofocus = false,
    this.showBorder = false,
    this.enableShadow = false,
  });

  @override
  State<CommonSearchField> createState() => _CommonSearchFieldState();
}

class _CommonSearchFieldState extends State<CommonSearchField> {
  late final TextEditingController _controller;
  bool _showClear = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_handleTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (_showClear != hasText) {
      setState(() => _showClear = hasText);
    }
    widget.onChanged?.call(_controller.text);
  }

  void _handleClear() {
    _controller.clear();
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: widget.width,
      height: 40,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(128),
        borderRadius: BorderRadius.circular(20),
        border: widget.showBorder
            ? Border.all(color: colorScheme.outline.withAlpha(51))
            : null,
        boxShadow: widget.enableShadow
            ? [
                BoxShadow(
                  color: colorScheme.shadow.withAlpha(26),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: TextField(
        controller: _controller,
        autofocus: widget.autofocus,
        style: theme.textTheme.bodyMedium?.copyWith(
          height: 1.0,
        ),
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          hintText: widget.hintText,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant.withOpacity(0.7),
            height: 1.0,
          ),
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20,
            color: colorScheme.onSurfaceVariant,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
          suffixIcon: _showClear
              ? IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: _handleClear,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                )
              : null,
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: widget.onSubmitted,
      ),
    );
  }
} 