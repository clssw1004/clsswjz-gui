import 'dart:convert';
import 'package:drift/drift.dart';
import '../../enums/symbol_type.dart';
import '../../utils/date_util.dart';
import '../../utils/id_util.dart';
import '../../utils/map_util.dart';
import '../database.dart';
import 'base_table.dart';

@DataClassName('AccountSymbol')
class AccountSymbolTable extends DateBaseAccountBookTable {
  TextColumn get name => text().named('name')();
  TextColumn get code => text().named('code')();
  TextColumn get symbolType => text().named('symbol_type')();

  /// 创建更新伴生对象
  static AccountSymbolTableCompanion toUpdateCompanion(
    String who, {
    String? name,
    String? lastAccountItemAt,
    String? accountBookId,
  }) {
    return AccountSymbolTableCompanion(
      updatedBy: Value(who),
      updatedAt: Value(DateUtil.now()),
      name: Value.absentIfNull(name),
      lastAccountItemAt: Value.absentIfNull(lastAccountItemAt),
      createdBy: const Value.absent(),
      createdAt: const Value.absent(),
    );
  }

  /// 创建新建伴生对象
  static AccountSymbolTableCompanion toCreateCompanion(
    String who,
    String accountBookId, {
    required String name,
    required SymbolType symbolType,
  }) =>
      AccountSymbolTableCompanion(
        id: Value(IdUtil.genId()),
        name: Value(name),
        code: Value(IdUtil.genNanoId8()),
        accountBookId: Value(accountBookId),
        symbolType: Value(symbolType.code),
        createdBy: Value(who),
        createdAt: Value(DateUtil.now()),
        updatedBy: Value(who),
        updatedAt: Value(DateUtil.now()),
      );

  /// 转换为JSON字符串
  static String toJsonString(AccountSymbolTableCompanion companion) {
    final Map<String, dynamic> map = {};
    MapUtil.setIfPresent(map, 'id', companion.id);
    MapUtil.setIfPresent(map, 'createdAt', companion.createdAt);
    MapUtil.setIfPresent(map, 'createdBy', companion.createdBy);
    MapUtil.setIfPresent(map, 'updatedAt', companion.updatedAt);
    MapUtil.setIfPresent(map, 'updatedBy', companion.updatedBy);
    MapUtil.setIfPresent(map, 'name', companion.name);
    MapUtil.setIfPresent(map, 'code', companion.code);
    MapUtil.setIfPresent(map, 'accountBookId', companion.accountBookId);
    MapUtil.setIfPresent(map, 'symbolType', companion.symbolType);
    MapUtil.setIfPresent(map, 'lastAccountItemAt', companion.lastAccountItemAt);
    return jsonEncode(map);
  }
}
