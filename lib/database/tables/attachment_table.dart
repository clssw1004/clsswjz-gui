import 'dart:convert';

import 'package:drift/drift.dart';
import '../../utils/date_util.dart';
import '../../utils/id_util.dart';
import '../../utils/map_util.dart';
import '../database.dart';
import 'base_table.dart';

@DataClassName('Attachment')
class AttachmentTable extends BaseBusinessTable {
  TextColumn get originName => text().named('origin_name')();
  IntColumn get fileLength => integer().named('file_length')();
  TextColumn get extension => text().named('extension')();
  TextColumn get contentType => text().named('content_type')();
  TextColumn get businessCode => text().named('business_code')();
  TextColumn get businessId => text().named('business_id')();

  static AttachmentTableCompanion toUpdateCompanion(
    String who, {
    String? originName,
    int? fileLength,
    String? extension,
    String? contentType,
    String? businessCode,
    String? businessId,
  }) {
    return AttachmentTableCompanion(
      updatedBy: Value(who),
      updatedAt: Value(DateUtil.now()),
      originName: Value.absentIfNull(originName),
      fileLength: Value.absentIfNull(fileLength),
      extension: Value.absentIfNull(extension),
      contentType: Value.absentIfNull(contentType),
      businessCode: Value.absentIfNull(businessCode),
      businessId: Value.absentIfNull(businessId),
      createdBy: const Value.absent(),
      createdAt: const Value.absent(),
    );
  }

  static AttachmentTableCompanion toCreateCompanion(
    String who, {
    required String originName,
    required int fileLength,
    required String extension,
    required String contentType,
    required String businessCode,
    required String businessId,
  }) =>
      AttachmentTableCompanion(
        id: Value(IdUtil.genId()),
        originName: Value(originName),
        fileLength: Value(fileLength),
        extension: Value(extension),
        contentType: Value(contentType),
        businessCode: Value(businessCode),
        businessId: Value(businessId),
        createdBy: Value(who),
        createdAt: Value(DateUtil.now()),
        updatedBy: Value(who),
        updatedAt: Value(DateUtil.now()),
      );

  static String toJsonString(AttachmentTableCompanion companion) {
    final Map<String, dynamic> map = {};
    MapUtil.setIfPresent(map, 'id', companion.id);
    MapUtil.setIfPresent(map, 'createdAt', companion.createdAt);
    MapUtil.setIfPresent(map, 'createdBy', companion.createdBy);
    MapUtil.setIfPresent(map, 'updatedAt', companion.updatedAt);
    MapUtil.setIfPresent(map, 'updatedBy', companion.updatedBy);
    MapUtil.setIfPresent(map, 'originName', companion.originName);
    MapUtil.setIfPresent(map, 'fileLength', companion.fileLength);
    MapUtil.setIfPresent(map, 'extension', companion.extension);
    MapUtil.setIfPresent(map, 'contentType', companion.contentType);
    MapUtil.setIfPresent(map, 'businessCode', companion.businessCode);
    MapUtil.setIfPresent(map, 'businessId', companion.businessId);
    return jsonEncode(map);
  }
}
