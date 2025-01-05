import 'dart:convert';
import 'package:drift/drift.dart';
import '../../utils/date_util.dart';
import '../../utils/id_util.dart';
import '../../utils/map_util.dart';
import '../database.dart';
import 'base_table.dart';

@DataClassName('AccountShop')
class AccountShopTable extends BaseBusinessTable {
  TextColumn get name => text().named('name')();
  TextColumn get code => text().named('code')();
  TextColumn get accountBookId => text().named('account_book_id')();

  /// 创建更新伴生对象
  static AccountShopTableCompanion toUpdateCompanion(
    String who, {
    String? name,
  }) {
    return AccountShopTableCompanion(
      updatedBy: Value(who),
      updatedAt: Value(DateUtil.now()),
      name: Value.absentIfNull(name),
      createdBy: const Value.absent(),
      createdAt: const Value.absent(),
    );
  }

  /// 创建新建伴生对象
  static AccountShopTableCompanion toCreateCompanion(
    String who,
    String accountBookId, {
    required String name,
  }) =>
      AccountShopTableCompanion(
        id: Value(IdUtil.genId()),
        name: Value(name),
        code: Value(IdUtil.genNanoId8()),
        accountBookId: Value(accountBookId),
        createdBy: Value(who),
        createdAt: Value(DateUtil.now()),
        updatedBy: Value(who),
        updatedAt: Value(DateUtil.now()),
      );

  /// 转换为JSON字符串
  static String toJsonString(AccountShopTableCompanion companion) {
    final Map<String, dynamic> map = {};
    MapUtil.setIfPresent(map, 'id', companion.id);
    MapUtil.setIfPresent(map, 'createdAt', companion.createdAt);
    MapUtil.setIfPresent(map, 'createdBy', companion.createdBy);
    MapUtil.setIfPresent(map, 'updatedAt', companion.updatedAt);
    MapUtil.setIfPresent(map, 'updatedBy', companion.updatedBy);
    MapUtil.setIfPresent(map, 'name', companion.name);
    MapUtil.setIfPresent(map, 'code', companion.code);
    MapUtil.setIfPresent(map, 'accountBookId', companion.accountBookId);
    return jsonEncode(map);
  }
}
