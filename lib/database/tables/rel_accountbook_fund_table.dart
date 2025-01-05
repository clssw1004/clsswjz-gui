import 'dart:convert';
import 'package:drift/drift.dart';
import '../../utils/date_util.dart';
import '../../utils/id_util.dart';
import '../../utils/map_util.dart';
import '../database.dart';
import 'base_table.dart';

@DataClassName('RelAccountbookFund')
class RelAccountbookFundTable extends BaseTable {
  TextColumn get accountBookId => text().named('account_book_id')();
  TextColumn get fundId => text().named('fund_id')();
  BoolColumn get fundIn =>
      boolean().named('fund_in').withDefault(const Constant(true))();
  BoolColumn get fundOut =>
      boolean().named('fund_out').withDefault(const Constant(true))();
  BoolColumn get isDefault =>
      boolean().named('is_default').withDefault(const Constant(false))();

  /// 生成更新数据的伴生对象
  static RelAccountbookFundTableCompanion toUpdateCompanion({
    bool? fundIn,
    bool? fundOut,
  }) {
    return RelAccountbookFundTableCompanion(
      updatedAt: Value(DateUtil.now()),
      fundIn: Value.absentIfNull(fundIn),
      fundOut: Value.absentIfNull(fundOut),
    );
  }

  /// 生成创建数据的伴生对象
  static RelAccountbookFundTableCompanion toCreateCompanion({
    required String accountBookId,
    required String fundId,
    bool fundIn = true,
    bool fundOut = true,
  }) =>
      RelAccountbookFundTableCompanion(
        id: Value(IdUtil.genId()),
        accountBookId: Value(accountBookId),
        fundId: Value(fundId),
        fundIn: Value(fundIn),
        fundOut: Value(fundOut),
        isDefault: const Value(false),
        createdAt: Value(DateUtil.now()),
        updatedAt: Value(DateUtil.now()),
      );

  /// 转换为JSON字符串
  static String toJsonString(RelAccountbookFundTableCompanion companion) {
    final Map<String, dynamic> map = {};
    MapUtil.setIfPresent(map, 'id', companion.id);
    MapUtil.setIfPresent(map, 'accountBookId', companion.accountBookId);
    MapUtil.setIfPresent(map, 'fundId', companion.fundId);
    MapUtil.setIfPresent(map, 'fundIn', companion.fundIn);
    MapUtil.setIfPresent(map, 'fundOut', companion.fundOut);
    MapUtil.setIfPresent(map, 'isDefault', companion.isDefault);
    MapUtil.setIfPresent(map, 'createdAt', companion.createdAt);
    MapUtil.setIfPresent(map, 'updatedAt', companion.updatedAt);
    return jsonEncode(map);
  }
}
