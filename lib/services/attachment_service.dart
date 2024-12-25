import 'package:drift/drift.dart';
import '../database/database.dart';
import '../models/common.dart';
import 'base_service.dart';

/// 附件服务
class AttachmentService extends BaseService {
  /// 批量插入附件
  Future<OperateResult<void>> batchInsertAttachments(
      List<Attachment> attachments) async {
    try {
      await db.transaction(() async {
        await db.batch((batch) {
          for (var attachment in attachments) {
            batch.insert(
              db.attachmentTable,
              AttachmentTableCompanion.insert(
                id: attachment.id,
                originName: attachment.originName,
                fileLength: attachment.fileLength,
                extension: attachment.extension,
                contentType: attachment.contentType,
                businessCode: attachment.businessCode,
                businessId: attachment.businessId,
                createdBy: attachment.createdBy,
                updatedBy: attachment.updatedBy,
                createdAt: attachment.createdAt,
                updatedAt: attachment.updatedAt,
              ),
              mode: InsertMode.insertOrReplace,
            );
          }
        });
      });
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.fail(
        '批量插入附件失败',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 获取业务相关的所有附件
  Future<OperateResult<List<Attachment>>> getAttachmentsByBusiness(
      String businessId, String businessCode) async {
    try {
      final attachments = await (db.select(db.attachmentTable)
            ..where((t) =>
                t.businessId.equals(businessId) &
                t.businessCode.equals(businessCode)))
          .get();
      return OperateResult.success(attachments);
    } catch (e) {
      return OperateResult.fail(
        '获取业务附件失败',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 创建附件
  Future<OperateResult<String>> createAttachment({
    required String originName,
    required int fileLength,
    required String extension,
    required String contentType,
    required String businessCode,
    required String businessId,
    required String createdBy,
    required String updatedBy,
  }) async {
    try {
      final id = generateUuid();
      await db.into(db.attachmentTable).insert(
            AttachmentTableCompanion.insert(
              id: id,
              originName: originName,
              fileLength: fileLength,
              extension: extension,
              contentType: contentType,
              businessCode: businessCode,
              businessId: businessId,
              createdBy: createdBy,
              updatedBy: updatedBy,
              createdAt: DateTime.now().millisecondsSinceEpoch,
              updatedAt: DateTime.now().millisecondsSinceEpoch,
            ),
          );
      return OperateResult.success(id);
    } catch (e) {
      return OperateResult.fail(
        '创建附件失败',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 更新附件
  Future<OperateResult<void>> updateAttachment(Attachment attachment) async {
    try {
      await db.update(db.attachmentTable).replace(attachment);
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.fail(
        '更新附件失败',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 删除附件
  Future<OperateResult<void>> deleteAttachment(String id) async {
    try {
      await (db.delete(db.attachmentTable)..where((t) => t.id.equals(id))).go();
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.fail(
        '删除附件失败',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 批量删除业务相关的附件
  Future<OperateResult<void>> deleteAttachmentsByBusiness(
      String businessId, String businessCode) async {
    try {
      await (db.delete(db.attachmentTable)
            ..where((t) =>
                t.businessId.equals(businessId) &
                t.businessCode.equals(businessCode)))
          .go();
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.fail(
        '删除业务附件失败',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }
}
