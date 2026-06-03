import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../enums/account_type.dart';
import '../../manager/l10n_manager.dart';
import '../../utils/color_util.dart';

/// 自定义动画类型切换器
/// 替换 SegmentedButton，提供弹性动画和触觉反馈
class AnimatedTypeToggle extends StatelessWidget {
  final AccountItemType value;
  final ValueChanged<AccountItemType> onChanged;

  const AnimatedTypeToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(40),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: AccountItemType.values.map((type) {
          final selected = value == type;
          final color = _colorForType(type);
          return Expanded(
            child: _TypePill(
              type: type,
              selected: selected,
              color: color,
              onTap: () {
                if (!selected) {
                  HapticFeedback.selectionClick();
                  onChanged(type);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  static Color _colorForType(AccountItemType type) {
    switch (type) {
      case AccountItemType.expense:
        return ColorUtil.EXPENSE;
      case AccountItemType.income:
        return ColorUtil.INCOME;
      case AccountItemType.transfer:
        return ColorUtil.TRANSFER;
    }
  }
}

class _TypePill extends StatelessWidget {
  final AccountItemType type;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _TypePill({
    required this.type,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  IconData get _icon {
    switch (type) {
      case AccountItemType.expense:
        return Icons.remove_circle_outline;
      case AccountItemType.income:
        return Icons.add_circle_outline;
      case AccountItemType.transfer:
        return Icons.swap_horizontal_circle_outlined;
    }
  }

  String get _label {
    switch (type) {
      case AccountItemType.expense:
        return L10nManager.l10n.expense;
      case AccountItemType.income:
        return L10nManager.l10n.income;
      case AccountItemType.transfer:
        return L10nManager.l10n.transfer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: AnimatedScale(
          scale: selected ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  _icon,
                  size: 18,
                  color: selected
                      ? Colors.white
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                _label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: selected
                      ? Colors.white
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
