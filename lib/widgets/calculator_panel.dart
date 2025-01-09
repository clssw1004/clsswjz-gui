import 'package:flutter/material.dart';

class CalculatorPanel extends StatefulWidget {
  final double? initialValue;
  final ValueChanged<double> onConfirm;

  const CalculatorPanel({
    super.key,
    this.initialValue,
    required this.onConfirm,
  });

  @override
  State<CalculatorPanel> createState() => _CalculatorPanelState();
}

class _CalculatorPanelState extends State<CalculatorPanel> {
  static const String _operatorPattern = '[+\\-*/]';
  static final RegExp _operatorRegex = RegExp(_operatorPattern);

  String _displayText = '';
  String _expression = '';
  bool _hasOperator = false;
  bool _isCalculated = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _displayText = widget.initialValue.toString();
      _expression = widget.initialValue.toString();
      _isCalculated = true;
    }
  }

  void _addNumber(String number) {
    setState(() {
      if (_isCalculated) {
        _expression = '';
        _displayText = '';
        _isCalculated = false;
      }

      // 处理小数点
      if (number == '.') {
        if (_expression.isEmpty) {
          _expression = '0.';
        } else if (_expression.contains('.')) {
          return;
        } else if (_hasOperator) {
          final parts = _expression.split(_operatorPattern);
          if (parts.last.contains('.')) return;
        }
      }

      _expression += number;
      _displayText = _expression;

      if (!_hasOperator) {}
    });
  }

  bool _endsWithOperator(String value) {
    return value.endsWith('+') || value.endsWith('-') || value.endsWith('*') || value.endsWith('/');
  }

  void _addOperator(String operator) {
    if (_expression.isEmpty) {
      if (operator == '-') {
        setState(() {
          _expression = operator;
          _displayText = operator;
        });
      }
      return;
    }

    if (_expression == '-') return;

    if (_hasOperator) {
      if (_endsWithOperator(_expression)) {
        // 替换最后的操作符
        setState(() {
          _expression = _expression.substring(0, _expression.length - 1) + operator;
          _displayText = _expression;
        });
        return;
      }
      _calculate();
    }

    setState(() {
      _expression += operator;
      _displayText = _expression;
      _hasOperator = true;
      _isCalculated = false;
    });
  }

  void _calculate() {
    if (!_hasOperator || _endsWithOperator(_expression)) return;

    try {
      final parts = _expression.split(_operatorRegex);
      final operator = _operatorRegex.firstMatch(_expression)?.group(0);

      if (parts.length != 2 || operator == null) return;

      final validParts = parts.where((part) => part.isNotEmpty).toList();
      if (validParts.length != 2) return;

      final num1 = double.parse(validParts[0]);
      final num2 = double.parse(validParts[1]);

      double result = 0;
      switch (operator) {
        case '+':
          result = num1 + num2;
          break;
        case '-':
          result = num1 - num2;
          break;
        case '*':
          result = num1 * num2;
          break;
        case '/':
          if (num2 == 0) {
            setState(() {
              _displayText = '错误';
              _expression = '';
              _hasOperator = false;
              _isCalculated = true;
            });
            return;
          }
          result = num1 / num2;
          break;
      }

      setState(() {
        _expression = result.toString().replaceAll(RegExp(r'\.0$'), '');
        _displayText = _expression;
        _hasOperator = false;
        _isCalculated = true;
      });
    } catch (e) {
      setState(() {
        _displayText = '错误';
        _expression = '';
        _hasOperator = false;
        _isCalculated = true;
      });
    }
  }

  void _backspace() {
    if (_expression.isEmpty) return;

    setState(() {
      if (_endsWithOperator(_expression)) {
        _hasOperator = false;
      }
      _expression = _expression.substring(0, _expression.length - 1);
      _displayText = _expression;
      _isCalculated = false;

      if (_expression.isNotEmpty && !_hasOperator) {
      } else {}
    });
  }

  void _clear() {
    setState(() {
      _expression = '';
      _displayText = '';
      _hasOperator = false;
      _isCalculated = false;
    });
  }

  bool get _canConfirmOrCalculate {
    if (_displayText.isEmpty || _displayText == '错误' || _endsWithOperator(_expression)) {
      return false;
    }
    return true;
  }

  void _handleConfirmOrCalculate() {
    if (_hasOperator && !_endsWithOperator(_expression)) {
      _calculate();
    } else if (_canConfirmOrCalculate) {
      widget.onConfirm(double.parse(_displayText));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      height: 380 + bottomPadding,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
      ),
      child: Column(
        children: [
          // 显示区域
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '¥',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _displayText.isEmpty ? '0' : _displayText,
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // 按键区域
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomPadding),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final buttonWidth = constraints.maxWidth / 4;
                  final buttonHeight = constraints.maxHeight / 5;

                  return Stack(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // 第一行：C、÷、×、退格
                          SizedBox(
                            height: buttonHeight,
                            child: Row(
                              children: [
                                _buildCalculatorButton(
                                  child: const Text('C'),
                                  onPressed: _clear,
                                  width: buttonWidth,
                                  height: buttonHeight,
                                  isOperator: true,
                                ),
                                _buildCalculatorButton(
                                  child: const Text('÷'),
                                  onPressed: () => _addOperator('/'),
                                  width: buttonWidth,
                                  height: buttonHeight,
                                  isOperator: true,
                                ),
                                _buildCalculatorButton(
                                  child: const Text('×'),
                                  onPressed: () => _addOperator('*'),
                                  width: buttonWidth,
                                  height: buttonHeight,
                                  isOperator: true,
                                ),
                                _buildCalculatorButton(
                                  child: const Icon(Icons.backspace_outlined),
                                  onPressed: _backspace,
                                  width: buttonWidth,
                                  height: buttonHeight,
                                  isOperator: true,
                                ),
                              ],
                            ),
                          ),
                          // 第二行：7、8、9、-
                          SizedBox(
                            height: buttonHeight,
                            child: Row(
                              children: [
                                _buildCalculatorButton(
                                  child: const Text('7'),
                                  onPressed: () => _addNumber('7'),
                                  width: buttonWidth,
                                  height: buttonHeight,
                                  isOperator: false,
                                ),
                                _buildCalculatorButton(
                                  child: const Text('8'),
                                  onPressed: () => _addNumber('8'),
                                  width: buttonWidth,
                                  height: buttonHeight,
                                  isOperator: false,
                                ),
                                _buildCalculatorButton(
                                  child: const Text('9'),
                                  onPressed: () => _addNumber('9'),
                                  width: buttonWidth,
                                  height: buttonHeight,
                                  isOperator: false,
                                ),
                                _buildCalculatorButton(
                                  child: const Text('-'),
                                  onPressed: () => _addOperator('-'),
                                  width: buttonWidth,
                                  height: buttonHeight,
                                  isOperator: true,
                                ),
                              ],
                            ),
                          ),
                          // 第三行：4、5、6、+
                          SizedBox(
                            height: buttonHeight,
                            child: Row(
                              children: [
                                _buildCalculatorButton(
                                  child: const Text('4'),
                                  onPressed: () => _addNumber('4'),
                                  width: buttonWidth,
                                  height: buttonHeight,
                                  isOperator: false,
                                ),
                                _buildCalculatorButton(
                                  child: const Text('5'),
                                  onPressed: () => _addNumber('5'),
                                  width: buttonWidth,
                                  height: buttonHeight,
                                  isOperator: false,
                                ),
                                _buildCalculatorButton(
                                  child: const Text('6'),
                                  onPressed: () => _addNumber('6'),
                                  width: buttonWidth,
                                  height: buttonHeight,
                                  isOperator: false,
                                ),
                                _buildCalculatorButton(
                                  child: const Text('+'),
                                  onPressed: () => _addOperator('+'),
                                  width: buttonWidth,
                                  height: buttonHeight,
                                  isOperator: true,
                                ),
                              ],
                            ),
                          ),
                          // 第四行：1、2、3
                          SizedBox(
                            height: buttonHeight,
                            child: Row(
                              children: [
                                _buildCalculatorButton(
                                  child: const Text('1'),
                                  onPressed: () => _addNumber('1'),
                                  width: buttonWidth,
                                  height: buttonHeight,
                                  isOperator: false,
                                ),
                                _buildCalculatorButton(
                                  child: const Text('2'),
                                  onPressed: () => _addNumber('2'),
                                  width: buttonWidth,
                                  height: buttonHeight,
                                  isOperator: false,
                                ),
                                _buildCalculatorButton(
                                  child: const Text('3'),
                                  onPressed: () => _addNumber('3'),
                                  width: buttonWidth,
                                  height: buttonHeight,
                                  isOperator: false,
                                ),
                                SizedBox(width: buttonWidth), // 为确认按钮预留空间
                              ],
                            ),
                          ),
                          // 第五行：0、.
                          SizedBox(
                            height: buttonHeight,
                            child: Row(
                              children: [
                                _buildCalculatorButton(
                                  child: const Text('0'),
                                  onPressed: () => _addNumber('0'),
                                  width: buttonWidth * 2,
                                  height: buttonHeight,
                                  isOperator: false,
                                ),
                                _buildCalculatorButton(
                                  child: const Text('.'),
                                  onPressed: () => _addNumber('.'),
                                  width: buttonWidth,
                                  height: buttonHeight,
                                  isOperator: false,
                                ),
                                SizedBox(width: buttonWidth), // 为确认按钮预留空间
                              ],
                            ),
                          ),
                        ],
                      ),
                      // 确认按钮
                      Positioned(
                        right: 0,
                        bottom: 0,
                        width: buttonWidth,
                        height: buttonHeight * 2,
                        child: _buildCalculatorButton(
                          child: Text(
                            _hasOperator && !_endsWithOperator(_expression) ? '=' : 'OK',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                          onPressed: _handleConfirmOrCalculate,
                          width: buttonWidth,
                          height: buttonHeight * 2,
                          isConfirmButton: true,
                          isOperator: false,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorButton({
    required Widget child,
    required VoidCallback onPressed,
    required double width,
    required double height,
    required bool isOperator,
    bool isConfirmButton = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: isConfirmButton ? colorScheme.primary : colorScheme.surface,
        child: InkWell(
          onTap: onPressed,
          child: Center(
            child: DefaultTextStyle(
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: child is Icon && child.icon == Icons.backspace_outlined
                    ? colorScheme.error
                    : isConfirmButton
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
