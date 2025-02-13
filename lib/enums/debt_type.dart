import '../manager/l10n_manager.dart';

enum DebtType {
  /// 借出
  lend('LEND'),

  /// 借入
  borrow('BORROW');

  final String code;
  const DebtType(this.code);
  String get text {
    switch (this) {
      case DebtType.lend:
        return L10nManager.l10n.lend;
      case DebtType.borrow:
        return L10nManager.l10n.borrow;
    }
  }

  static DebtType fromCode(String code) {
    return DebtType.values.firstWhere(
      (type) => type.code == code,
      orElse: () => DebtType.lend,
    );
  }
}
