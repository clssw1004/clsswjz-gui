import 'dart:io';

import '../enums/import_source.dart';

class ImportService {
  /// 导入数据
  Future<void> importData({required ImportSource source, required String accountBookId, required File file}) async {
    switch (source) {
      case ImportSource.bohe:
        return _importBoheData(accountBookId: accountBookId, file: file);
    }
  }

  /// 导入薄荷记账数据
  Future<void> _importBoheData({required String accountBookId, required File file}) async {}
}
