import '../../database/database.dart';
import '../../enums/debt_clear_state.dart';

class UserDebtVO {
  final String id;

  final String accountBookId;

  /// 债务类型（借入/借出）
  final String debtType;

  /// 债务人
  final String debtor;

  /// 债务剩余金额
  final double remainAmount;

  /// 债务总金额
  final double totalAmount;

  /// 账户ID
  final String fundId;

  /// 日期
  final String debtDate;

  /// 债务状态
  final DebtClearState clearState;

  /// 结清日期
  final String? clearDate;

  /// 账户名称
  final String fundName;

  /// 预计结清日期
  final String? expectedClearDate;

  final String createdBy;
  final String updatedBy;
  final int createdAt;
  final int updatedAt;

  UserDebtVO({
    required this.id,
    required this.accountBookId,
    required this.debtType,
    required this.debtor,
    required this.totalAmount,
    required this.remainAmount,
    required this.fundId,
    required this.debtDate,
    required this.clearState,
    this.clearDate,
    this.expectedClearDate,
    required this.fundName,
    required this.createdBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  static UserDebtVO fromDebt({
    required AccountDebt debt,
    required double totalAmount,
    required double remainAmount,
    required String fundName,
  }) {
    return UserDebtVO(
      id: debt.id,
      accountBookId: debt.accountBookId,
      debtType: debt.debtType,
      debtor: debt.debtor,
      totalAmount: totalAmount,
      remainAmount: remainAmount,
      fundId: debt.fundId,
      clearState: DebtClearState.fromCode(debt.clearState),
      debtDate: debt.debtDate,
      clearDate: debt.clearDate,
      expectedClearDate: debt.expectedClearDate,
      fundName: fundName,
      createdBy: debt.createdBy,
      updatedBy: debt.updatedBy,
      createdAt: debt.createdAt,
      updatedAt: debt.updatedAt,
    );
  }
}
