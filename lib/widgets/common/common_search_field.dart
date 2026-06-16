import 'package:flutter/material.dart';

class CommonSearchField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final double? width;
  final double? expandedWidth;
  final bool autofocus;
  final bool showBorder;
  final bool enableShadow;
  final FocusNode? focusNode;
  final ValueChanged<bool>? onFocusChange;

  const CommonSearchField({
    super.key,
    this.controller,
    this.hintText,
    this.onSubmitted,
    this.onChanged,
    this.onClear,
    this.width,
    this.expandedWidth,
    this.autofocus = false,
    this.showBorder = false,
    this.enableShadow = false,
    this.focusNode,
    this.onFocusChange,
  });

  @override
  State<CommonSearchField> createState() => _CommonSearchFieldState();
}

class _CommonSearchFieldState extends State<CommonSearchField> {
  TextEditingController _controller = TextEditingController();
  FocusNode _focusNode = FocusNode();
  bool _showClear = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller.dispose();
      _controller = widget.controller!;
    }
    _controller.addListener(_handleTextChanged);
    if (widget.focusNode != null) {
      _focusNode.dispose();
      _focusNode = widget.focusNode!;
    }
    _focusNode.addListener(_handleFocusChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
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

  void _handleFocusChanged() {
    if (_isFocused != _focusNode.hasFocus) {
      setState(() => _isFocused = _focusNode.hasFocus);
      widget.onFocusChange?.call(_isFocused);
    }
  }

  void _handleClear() {
    _controller.clear();
    _focusNode.unfocus();
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final expand = _showClear;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: expand ? (widget.expandedWidth ?? widget.width) : widget.width,
      height: expand ? 44 : 40,
      decoration: BoxDecoration(
        color: expand
            ? colorScheme.surfaceContainerHighest
            : colorScheme.surfaceContainerHighest.withAlpha(128),
        borderRadius: BorderRadius.circular(22),
        border: expand
            ? Border.all(color: colorScheme.primary.withAlpha(80), width: 1.5)
            : null,
        boxShadow: expand
            ? [BoxShadow(color: colorScheme.primary.withAlpha(20), blurRadius: 8, offset: const Offset(0, 2))]
            : null,
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        style: theme.textTheme.bodyMedium?.copyWith(height: 1.0),
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          hintText: widget.hintText,
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            height: 1.0,
          ),
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.search_rounded,
            size: 20,
            color: expand ? colorScheme.primary : colorScheme.onSurfaceVariant,
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          suffixIcon: _showClear
              ? IconButton(
                  icon: Icon(Icons.close_rounded, size: 18, color: colorScheme.onSurfaceVariant),
                  onPressed: _handleClear,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                )
              : null,
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: (v) {
          _focusNode.unfocus();
          widget.onSubmitted?.call(v);
        },
      ),
    );
  }
} 