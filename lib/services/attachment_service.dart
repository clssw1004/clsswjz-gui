import 'dart:io';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as path;
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import '../database/dao/attachment_dao.dart';
import '../database/database.dart';
import '../enums/business_type.dart';
import '../manager/database_manager.dart';
import '../models/common.dart';
import 'base_service.dart';
import '../models/vo/attachment_vo.dart';
import '../utils/date_util.dart';

/// 附件服务
class AttachmentService extends BaseService {
  final AttachmentDao _attachmentDao;

  AttachmentService() : _attachmentDao = AttachmentDao(DatabaseManager.db);

  Future<AttachmentVO?> getAttachment(String? id) async {
    if (id == null) return null;
    final attachment = await _attachmentDao.findById(id);
    if (attachment == null) {
      return null;
    }
    return toAttachmentVO(attachment);
  }

  /// 获取附件存储目录
  Future<Directory> get _attachmentDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final attachmentDir = Directory(path.join(appDir.path, 'attachments'));
    if (!await attachmentDir.exists()) {
      await attachmentDir.create(recursive: true);
    }
    return attachmentDir;
  }

  /// 根据附件ID获取文件路径
  Future<String> getAttachmentPath(
      String attachmentId, String extension) async {
    final dir = await _attachmentDir;
    return path.join(dir.path, '$attachmentId$extension');
  }

  /// 保存文件
  /// [businessCode] 业务代码
  /// [businessId] 业务ID
  /// [file] 文件
  /// [userId] 用户ID
  /// 返回附件ID
  Future<String> saveFile(BusinessType businessType, String businessId,
      File file, String userId) async {
    AttachmentVO attachment =
        generateVoFromFile(businessType, businessId, file, userId);
    await saveAttachments(
        businessType: businessType,
        businessId: businessId,
        attachments: [attachment],
        userId: userId,
        isDelete: false);
    return attachment.id;
  }

  /// 批量保存附件（处理更新、删除、新增）
  /// [businessCode] 业务代码
  /// [businessId] 业务ID
  /// [attachments] 附件列表
  /// [userId] 用户ID
  Future<OperateResult<void>> saveAttachments({
    required BusinessType businessType,
    required String businessId,
    required List<AttachmentVO> attachments,
    required String userId,
    bool isDelete = true,
  }) async {
    try {
      final attachmentDir = await _attachmentDir;

      // 获取现有附件
      final existingAttachments = await (db.select(db.attachmentTable)
            ..where((t) =>
                t.businessId.equals(businessId) &
                t.businessCode.equals(businessType.code)))
          .get();

      await db.transaction(() async {
        // 处理需要删除的附件
        final attachmentsToDelete = existingAttachments
            .where((existing) =>
                !attachments.any((attachment) => attachment.id == existing.id))
            .toList();

        if (attachmentsToDelete.isNotEmpty && isDelete) {
          // 批量删除文件
          for (var attachment in attachmentsToDelete) {
            final filePath =
                await getAttachmentPath(attachment.id, attachment.extension);
            final file = File(filePath);
            if (await file.exists()) {
              await file.delete();
            }
          }

          // 批量删除数据库记录
          await (db.delete(db.attachmentTable)
                ..where((t) => t.id.isIn(attachmentsToDelete.map((a) => a.id))))
              .go();
        }

        // 处理需要新增的附件
        final attachmentsToAdd = attachments
            .where((attachment) => !existingAttachments
                .any((existing) => existing.id == attachment.id))
            .toList();

        if (attachmentsToAdd.isNotEmpty) {
          // 批量保存文件
          final fileSaveOperations =
              attachmentsToAdd.where((vo) => vo.file != null).map((vo) async {
            final targetPath =
                path.join(attachmentDir.path, '${vo.id}${vo.extension}');
            await vo.file!.copy(targetPath);
          }).toList();
          await Future.wait(fileSaveOperations);

          // 批量插入数据库记录
          await db.batch((batch) {
            for (var vo in attachmentsToAdd) {
              if (vo.file != null) {
                batch.insert(
                  db.attachmentTable,
                  AttachmentTableCompanion.insert(
                    id: vo.id,
                    createdBy: vo.createdBy,
                    updatedBy: vo.updatedBy,
                    createdAt: vo.createdAt,
                    updatedAt: vo.updatedAt,
                    originName: vo.originName,
                    fileLength: vo.fileLength,
                    extension: vo.extension,
                    contentType: vo.contentType,
                    businessCode: vo.businessCode,
                    businessId: vo.businessId,
                  ),
                );
              }
            }
          });
        }

        // 处理需要更新的附件
        final attachmentsToUpdate = attachments
            .where((attachment) => existingAttachments
                .any((existing) => existing.id == attachment.id))
            .toList();

        if (attachmentsToUpdate.isNotEmpty) {
          // 批量更新数据库记录
          await db.batch((batch) {
            for (var vo in attachmentsToUpdate) {
              batch.update(
                db.attachmentTable,
                vo.toAttachment(),
                where: (t) => t.id.equals(vo.id),
              );
            }
          });
        }
      });

      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage(
        message: '批量保存附件失败',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 获取业务相关的所有附件
  Future<OperateResult<List<AttachmentVO>>> getAttachmentsByBusiness(
    BusinessType businessType,
    String businessId,
  ) async {
    try {
      final attachments = await (db.select(db.attachmentTable)
            ..where((t) =>
                t.businessId.equals(businessId) &
                t.businessCode.equals(businessType.code)))
          .get();

      final attachmentVOs = <AttachmentVO>[];
      for (var attachment in attachments) {
        attachmentVOs.add(await toAttachmentVO(attachment));
      }

      return OperateResult.success(attachmentVOs);
    } catch (e) {
      return OperateResult.failWithMessage(
        message: '获取业务附件失败',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 从文件生成附件VO
  AttachmentVO generateVoFromFile(
    BusinessType businessType,
    String businessId,
    File file,
    String userId,
  ) {
    final fileName = path.basename(file.path);
    final extension = path.extension(file.path).toLowerCase();
    final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
    final fileLength = file.lengthSync();
    final now = DateUtil.now();
    final id = generateUuid();

    return AttachmentVO(
      id: id,
      originName: fileName,
      fileLength: fileLength,
      extension: extension,
      contentType: mimeType,
      businessCode: businessType.code,
      businessId: businessId,
      createdBy: userId,
      updatedBy: userId,
      createdAt: now,
      updatedAt: now,
      file: file,
    );
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
              createdAt: DateUtil.now(),
              updatedAt: DateUtil.now(),
            ),
          );
      return OperateResult.success(id);
    } catch (e) {
      return OperateResult.failWithMessage(
        message: '创建附件失败',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 更新附件
  Future<OperateResult<void>> updateAttachment(Attachment attachment) async {
    try {
      await db.update(db.attachmentTable).replace(attachment);
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage(
        message: '更新附件失败',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 删除附件（包括文件）
  Future<OperateResult<void>> deleteAttachment(String id) async {
    try {
      final attachment = await _attachmentDao.findById(id);
      await _attachmentDao.delete(id);
      if (attachment != null) {
        // 删除文件
        final filePath = await getAttachmentPath(id, attachment.extension);
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }
        // 删除数据库记录
        await (db.delete(db.attachmentTable)..where((t) => t.id.equals(id)))
            .go();
      }
      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage(
        message: '删除附件失败',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  /// 批量删除业务相关的附件（包括文件）
  Future<OperateResult<void>> deleteAttachmentsByBusiness(
      String businessId, String businessCode) async {
    try {
      // 先查询所有相关附件
      final attachments = await (db.select(db.attachmentTable)
            ..where((t) =>
                t.businessId.equals(businessId) &
                t.businessCode.equals(businessCode)))
          .get();

      // 删除文件和数据库记录
      for (var attachment in attachments) {
        final filePath =
            await getAttachmentPath(attachment.id, attachment.extension);
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
        }
      }

      // 删除数据库记录
      await (db.delete(db.attachmentTable)
            ..where((t) =>
                t.businessId.equals(businessId) &
                t.businessCode.equals(businessCode)))
          .go();

      return OperateResult.success(null);
    } catch (e) {
      return OperateResult.failWithMessage(
        message: '删除业务附件失败',
        exception: e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  Future<AttachmentVO> toAttachmentVO(Attachment attachment) async {
    final filePath =
        await getAttachmentPath(attachment.id, attachment.extension);
    final file = File(filePath);
    final exists = await file.exists();
    return AttachmentVO.fromAttachment(
      attachment: attachment,
      file: exists ? file : null,
    );
  }
}
