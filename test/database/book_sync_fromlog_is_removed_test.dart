import 'package:clsswjz_gui/database/database.dart';
import 'package:clsswjz_gui/database/tables/account_book_table.dart';
import 'package:clsswjz_gui/drivers/special/log/builder/book.builder.dart';
import 'package:clsswjz_gui/enums/operate_type.dart';
import 'package:clsswjz_gui/enums/sync_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fromCreateLog 能处理服务端回环的账本日志（operateData 不含 isRemoved）', () {
    // 本地创建账本时序列化的日志数据（AccountBookTable.toJsonString 不写 isRemoved）
    final companion = AccountBookTable.toCreateCompanion('u1',
        name: '账本', currencySymbol: '¥');
    final operateData = AccountBookTable.toJsonString(companion);
    expect(operateData.contains('isRemoved'), isFalse,
        reason: '日志数据是本地私有标记，isRemoved 不应被序列化到日志');

    final log = LogSync(
      id: 'log-1',
      parentType: 'book',
      parentId: 'book-1',
      operatorId: 'u1',
      operatedAt: 1000,
      businessType: 'book',
      operateType: OperateType.create.code,
      businessId: 'book-1',
      operateData: operateData,
      syncState: SyncState.unsynced.value,
      syncTime: -1,
    );

    // 同步应用该日志不应抛异常，且账本默认可见（isRemoved = false）
    final builder = BookCULog.fromCreateLog(log);
    expect(builder.data, isNotNull);
    expect(builder.data!.isRemoved.value, isFalse);
  });
}
