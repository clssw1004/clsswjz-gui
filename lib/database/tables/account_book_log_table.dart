import 'package:drift/drift.dart';
import 'base_table.dart';

/// 账本操作日志表
@DataClassName('AccountBookLog')
class AccountBookLogTable extends StringIdTable {
  /// 账本ID
  TextColumn get accountBookId => text().named('account_book_id')();

  /// 操作人
  TextColumn get operatorId => text().named('operator_id')();

  /// 操作时间戳
  IntColumn get operatedAt => integer().named('operated_at')();

  /// 操作业务
  /// item-账目、book-账本、fund-账户、category-分类、shop-商家、symbol-标识、user-用户，attachment-附件
  TextColumn get businessType => text().named('business_type')();

  /// 操作类型
  /// update-更新、create-创建、delete-删除
  /// batchUpdate-批量更新、batchCreate-批量创建、batchDelete-批量删除
  TextColumn get operateType => text().named('operate_type')();

  /// 操作数据主键
  TextColumn get businessId => text().named('business_id')();

  /// 操作数据json
  TextColumn get operateData => text().named('operate_data')();

  @override
  List<String> get customConstraints => [
        'UNIQUE (account_book_id, business_type, business_id,operator_id, operated_at)',
      ];
}
