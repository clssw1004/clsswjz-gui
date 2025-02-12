import 'package:flutter/material.dart';
import '../manager/l10n_manager.dart';

enum DebtClearState {
  /// 未结清
  pending('pending'),

  /// 已结清
  cleared('cleared'),

  /// 已作废
  cancelled('cancelled');

  final String code;

  const DebtClearState(this.code);

  static DebtClearState fromCode(String code) {
    return DebtClearState.values.firstWhere(
      (e) => e.code == code,
      orElse: () => DebtClearState.pending,
    );
  }

  String get text {
    switch (this) {
      case DebtClearState.pending:
        return L10nManager.l10n.debtStatusUncleared;
      case DebtClearState.cleared:
        return L10nManager.l10n.debtStatusCleared;
      case DebtClearState.cancelled:
        return L10nManager.l10n.debtStatusVoided;
    }
  }

  Color get color {
    switch (this) {
      case DebtClearState.pending:
        return Colors.orange;
      case DebtClearState.cleared:
        return Colors.green;
      case DebtClearState.cancelled:
        return Colors.red;
    }
  }
}