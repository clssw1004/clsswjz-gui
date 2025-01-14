import 'dart:io';

import '../enums/import_source.dart';
import '../models/vo/book_meta.dart';

abstract class ImportInterface {
  /// 将source 数据源的file 导入到 accountBookId 的账本中
  Future<void> importData(String who, {required BookMetaVO bookMeta, required ImportSource source, required File file});
}
