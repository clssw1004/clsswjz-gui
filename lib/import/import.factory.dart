import 'dart:io';

import '../enums/import_source.dart';
import '../manager/service_manager.dart';
import '../models/vo/book_meta.dart';
import 'bohe/bohe_data.import.dart';
import 'import.dart';

class ImportFactory {
  static final ImportInterface _boheImport = BoheDataImport();

  /// 导入数据
  static Future<void> importData(String userId, Function(double percent, String message) importProgress,
      {required ImportSource source, required String accountBookId, required File file}) async {
    final BookMetaVO? bookMeta = await ServiceManager.accountBookService.getBookMeta(userId, accountBookId);
    if (bookMeta == null) {
      throw Exception('账本不存在');
    }
    switch (source) {
      case ImportSource.bohe:
        await _boheImport.importData(userId, importProgress, bookMeta: bookMeta, source: source, file: file);
        break;
    }
  }
}
