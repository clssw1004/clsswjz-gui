import 'package:flutter/material.dart';
import './calculator_panel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../constants/enums.dart';
import '../utils/color_util.dart';

class AmountInput extends StatefulWidget {
  final double? initialValue;
  final ValueChanged<double> onChanged;
  final String type;
  final FocusNode? focusNode;
  final TextEditingController controller;

  const AmountInput({
    Key? key,
    this.initialValue,
    required this.onChanged,
    required this.type,
    this.focusNode,
    required this.controller,
  }) : super(key: key);

  @override
  State<AmountInput> createState() => _AmountInputState();
}

class _AmountInputState extends State<AmountInput> {
  String? _errorText;

  void _showCalculator() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CalculatorPanel(
        initialValue: widget.controller.text.isEmpty
            ? null
            : double.tryParse(widget.controller.text),
        onConfirm: (value) {
          setState(() {
            widget.controller.text = value.toString();
            _errorText = _validateAmount(value.toString());
          });
          widget.onChanged(value);
        },
      ),
    );
  }

  String? _validateAmount(String? value) {
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    // 获取金额颜色
    final amountColor = ColorUtil.getAmountColor(context, widget.type);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _showCalculator,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.amountLabel,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.controller.text.isEmpty
                            ? l10n.amountHint
                            : widget.controller.text,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: widget.controller.text.isEmpty
                              ? colorScheme.onSurfaceVariant
                              : amountColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.calculate_outlined,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
        if (_errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Text(
              _errorText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}
