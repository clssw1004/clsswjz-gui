import 'dart:convert';
import 'package:drift/drift.dart';
import '../../utils/date_util.dart';
import '../../utils/id_util.dart';
import '../../utils/map_util.dart';
import '../database.dart';
import 'base_table.dart';

@DataClassName('AccountCategory')
class AccountCategoryTable extends BaseAccountBookTable {
  TextColumn get name => text().named('name')();
  TextColumn get code => text().named('code')();
  TextColumn get categoryType => text().named('category_type')();
  TextColumn get lastAccountItemAt => text().nullable().named('last_account_item_at')();

  @override
  List<Set<Column<Object>>>? get uniqueKeys => [
        {name, accountBookId, categoryType},
      ];

  /// 创建更新伴生对象
  static AccountCategoryTableCompanion toUpdateCompanion(
    String who, {
    String? name,
    String? lastAccountItemAt,
  }) {
    return AccountCategoryTableCompanion(
      updatedBy: Value(who),
      updatedAt: Value(DateUtil.now()),
      name: Value.absentIfNull(name),
      lastAccountItemAt: Value.absentIfNull(lastAccountItemAt),
      createdBy: const Value.absent(),
      createdAt: const Value.absent(),
    );
  }

  /// 创建新建伴生对象
  static AccountCategoryTableCompanion toCreateCompanion(
    String who,
    String accountBookId, {
    required String name,
    required String categoryType,
    String? code,
  }) =>
      AccountCategoryTableCompanion(
        id: Value(IdUtil.genId()),
        name: Value(name),
        code: Value(code ?? IdUtil.genNanoId8()),
        accountBookId: Value(accountBookId),
        categoryType: Value(categoryType),
        createdBy: Value(who),
        createdAt: Value(DateUtil.now()),
        updatedBy: Value(who),
        updatedAt: Value(DateUtil.now()),
      );

  /// 转换为JSON字符串
  static String toJsonString(AccountCategoryTableCompanion companion) {
    final Map<String, dynamic> map = {};
    MapUtil.setIfPresent(map, 'id', companion.id);
    MapUtil.setIfPresent(map, 'createdAt', companion.createdAt);
    MapUtil.setIfPresent(map, 'createdBy', companion.createdBy);
    MapUtil.setIfPresent(map, 'updatedAt', companion.updatedAt);
    MapUtil.setIfPresent(map, 'updatedBy', companion.updatedBy);
    MapUtil.setIfPresent(map, 'name', companion.name);
    MapUtil.setIfPresent(map, 'code', companion.code);
    MapUtil.setIfPresent(map, 'accountBookId', companion.accountBookId);
    MapUtil.setIfPresent(map, 'categoryType', companion.categoryType);
    MapUtil.setIfPresent(map, 'lastAccountItemAt', companion.lastAccountItemAt);
    return jsonEncode(map);
  }
}
