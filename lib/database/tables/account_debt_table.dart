import 'dart:convert';
import 'package:drift/drift.dart';
import '../../enums/debt_clear_state.dart';
import '../../enums/debt_type.dart';
import '../../utils/date_util.dart';
import '../../utils/id_util.dart';
import '../../utils/map_util.dart';
import '../database.dart';
import 'base_table.dart';

@DataClassName('AccountDebt')
class AccountDebtTable extends BaseAccountBookTable {
  /// 债务类型（借入/借出）
  TextColumn get debtType => text().named('debt_type')();

  /// 债务人
  TextColumn get debtor => text().named('debtor')();

  /// 金额
  RealColumn get amount => real().named('amount')();

  /// 账户ID
  TextColumn get fundId => text().named('fund_id')();

  /// 日期
  TextColumn get debtDate => text().named('debt_date')();

  /// 结清日期
  TextColumn get clearDate => text().nullable().named('clear_date')();

  /// 预计结清日期
  TextColumn get expectedClearDate =>
      text().nullable().named('expected_clear_date')();

  /// 结清状态
  TextColumn get clearState =>
      text().named("clear_state").withDefault(const Constant('pending'))();

  static AccountDebtTableCompanion toUpdateCompanion(
    String who, {
    String? debtor,
    double? amount,
    String? fundId,
    String? debtDate,
    String? accountBookId,
    DebtClearState? clearState,
    String? clearDate,
    String? expectedClearDate,
  }) {
    return AccountDebtTableCompanion(
      updatedBy: Value(who),
      updatedAt: Value(DateUtil.now()),
      debtor: Value.absentIfNull(debtor),
      amount: Value.absentIfNull(amount),
      fundId: Value.absentIfNull(fundId),
      debtDate: Value.absentIfNull(debtDate),
      accountBookId: Value.absentIfNull(accountBookId),
      clearState: Value.absentIfNull(clearState?.code),
      expectedClearDate: Value.absentIfNull(expectedClearDate),
      clearDate: Value.absentIfNull(clearDate),
      createdBy: const Value.absent(),
      createdAt: const Value.absent(),
    );
  }

  static AccountDebtTableCompanion toCreateCompanion(
    String who,
    String accountBookId, {
    required DebtType debtType,
    required String debtor,
    required double amount,
    required String fundId,
    required String debtDate,
    String? expectedClearDate,
  }) =>
      AccountDebtTableCompanion(
        id: Value(IdUtil.genId()),
        accountBookId: Value(accountBookId),
        debtType: Value(debtType.code),
        debtor: Value(debtor),
        amount: Value(amount),
        fundId: Value(fundId),
        debtDate: Value(debtDate),
        expectedClearDate: Value.absentIfNull(expectedClearDate),
        clearState: Value(DebtClearState.pending.code),
        createdBy: Value(who),
        createdAt: Value(DateUtil.now()),
        updatedBy: Value(who),
        updatedAt: Value(DateUtil.now()),
      );

  static String toJsonString(AccountDebtTableCompanion companion) {
    final Map<String, dynamic> map = {};
    MapUtil.setIfPresent(map, 'id', companion.id);
    MapUtil.setIfPresent(map, 'createdAt', companion.createdAt);
    MapUtil.setIfPresent(map, 'createdBy', companion.createdBy);
    MapUtil.setIfPresent(map, 'updatedAt', companion.updatedAt);
    MapUtil.setIfPresent(map, 'updatedBy', companion.updatedBy);
    MapUtil.setIfPresent(map, 'debtType', companion.debtType);
    MapUtil.setIfPresent(map, 'debtor', companion.debtor);
    MapUtil.setIfPresent(map, 'amount', companion.amount);
    MapUtil.setIfPresent(map, 'fundId', companion.fundId);
    MapUtil.setIfPresent(map, 'debtDate', companion.debtDate);
    MapUtil.setIfPresent(map, 'clearDate', companion.clearDate);
    MapUtil.setIfPresent(map, 'expectedClearDate', companion.expectedClearDate);
    MapUtil.setIfPresent(map, 'clearState', companion.clearState);
    MapUtil.setIfPresent(map, 'accountBookId', companion.accountBookId);
    return jsonEncode(map);
  }
}
