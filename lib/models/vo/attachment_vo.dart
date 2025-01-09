import 'dart:io';
import '../../database/database.dart';
import '../../utils/attachment.util.dart';

/// 附件VO
class AttachmentVO {
  /// ID
  final String id;

  /// 原始文件名
  final String originName;

  /// 文件大小
  final int fileLength;

  /// 文件扩展名
  final String extension;

  /// 内容类型
  final String contentType;

  /// 业务代码
  final String businessCode;

  /// 业务ID
  final String businessId;

  /// 创建人
  final String createdBy;

  /// 更新人
  final String updatedBy;

  /// 创建时间
  final int createdAt;

  /// 更新时间
  final int updatedAt;

  /// 文件对象
  final File? file;

  const AttachmentVO({
    required this.id,
    required this.originName,
    required this.fileLength,
    required this.extension,
    required this.contentType,
    required this.businessCode,
    required this.businessId,
    required this.createdBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
    this.file,
  });

  /// 从Attachment和File创建VO
  static Future<AttachmentVO> fromAttachment(
    Attachment attachment,
  ) async {
    final filePath = await AttachmentUtil.getAttachmentPath(attachment.id);
    final file = File(filePath);
    final exists = await file.exists();
    return AttachmentVO(
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
      file: exists ? file : null,
    );
  }

  Attachment toAttachment() {
    return Attachment(
      createdBy: createdBy,
      updatedBy: updatedBy,
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      originName: originName,
      fileLength: fileLength,
      extension: extension,
      contentType: contentType,
      businessCode: businessCode,
      businessId: businessId,
    );
  }
}
