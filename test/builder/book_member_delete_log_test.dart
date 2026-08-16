import 'dart:convert';

import 'package:clsswjz_gui/drivers/special/log/builder/builder.dart';
import 'package:clsswjz_gui/enums/business_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bookMember delete log carries userId/accountBookId for removal notify',
      () {
    final deleteLog = DeleteLog.buildBookSub(
      'operator-1',
      'book-1',
      BusinessType.bookMember,
      'rel-1',
    ).withData(jsonEncode({'userId': 'removed-user', 'accountBookId': 'book-1'}));

    final syncLog = deleteLog.toSyncLog();

    final operateData = jsonDecode(syncLog.operateData) as Map<String, dynamic>;
    expect(operateData['userId'], 'removed-user');
    expect(operateData['accountBookId'], 'book-1');
    expect(syncLog.businessType, BusinessType.bookMember.code);
    expect(syncLog.operateType, 'delete');
    expect(syncLog.parentId, 'book-1');
  });
}
