import 'dart:convert';
import 'package:drift/drift.dart';
import '../../enums/fund_type.dart';
import '../../utils/date_util.dart';
import '../../utils/id_util.dart';
import '../../utils/map_util.dart';
import '../database.dart';
import 'base_table.dart';

@DataClassName('AccountFund')
class AccountFundTable extends BaseBusinessTable {
  TextColumn get name => text().named('name')();
  TextColumn get fundType => text().named('fund_type')();
  TextColumn get fundRemark => text().nullable().named('fund_remark')();
  RealColumn get fundBalance =>
      real().named('fund_balance').withDefault(const Constant(0.00))();
  BoolColumn get isDefault => boolean()
      .named('is_default')
      .nullable()
      .withDefault(const Constant(false))();

  /// 生成更新数据的伴生对象
  static AccountFundTableCompanion toUpdateCompanion(
    String who, {
    String? name,
    FundType? fundType,
    String? fundRemark,
    double? fundBalance,
    bool? isDefault,
  }) {
    return AccountFundTableCompanion(
      updatedBy: Value(who),
      updatedAt: Value(DateUtil.now()),
      name: Value.absentIfNull(name),
      fundType: Value.absentIfNull(fundType?.code),
      fundRemark: Value.absentIfNull(fundRemark),
      fundBalance: Value.absentIfNull(fundBalance),
      isDefault: Value.absentIfNull(isDefault),
      createdBy: const Value.absent(),
      createdAt: const Value.absent(),
    );
  }

  /// 生成创建数据的伴生对象
  static AccountFundTableCompanion toCreateCompanion(
    String who, {
    required String name,
    required FundType fundType,
    String? fundRemark,
    double? fundBalance,
    bool? isDefault,
  }) =>
      AccountFundTableCompanion(
        id: Value(IdUtils.genId()),
        name: Value(name),
        fundType: Value(fundType.code),
        fundRemark: Value.absentIfNull(fundRemark),
        fundBalance: Value(fundBalance ?? 0.00),
        isDefault: Value.absentIfNull(isDefault),
        createdBy: Value(who),
        createdAt: Value(DateUtil.now()),
        updatedBy: Value(who),
        updatedAt: Value(DateUtil.now()),
      );

  /// 转换为JSON字符串
  static String toJsonString(AccountFundTableCompanion companion) {
    final Map<String, dynamic> map = {};
    MapUtil.setIfPresent(map, 'id', companion.id);
    MapUtil.setIfPresent(map, 'createdAt', companion.createdAt);
    MapUtil.setIfPresent(map, 'createdBy', companion.createdBy);
    MapUtil.setIfPresent(map, 'updatedAt', companion.updatedAt);
    MapUtil.setIfPresent(map, 'updatedBy', companion.updatedBy);
    MapUtil.setIfPresent(map, 'name', companion.name);
    MapUtil.setIfPresent(map, 'fundType', companion.fundType);
    MapUtil.setIfPresent(map, 'fundRemark', companion.fundRemark);
    MapUtil.setIfPresent(map, 'fundBalance', companion.fundBalance);
    MapUtil.setIfPresent(map, 'isDefault', companion.isDefault);
    return jsonEncode(map);
  }
}
