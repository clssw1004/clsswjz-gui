import 'dart:io';
import '../../database/database.dart';
import 'attachment_vo.dart';

/// 附件VO
class AttachmentShowVO extends AttachmentVO {
  /// 来源标题 笔记：笔记标题、账目：账目日期+分类+金额+备注
  final String businessName;

  const AttachmentShowVO({
    required super.id,
    required super.originName,
    required super.fileLength,
    required super.extension,
    required super.contentType,
    required super.businessCode,
    required super.businessId,
    required super.createdBy,
    required super.updatedBy,
    required super.createdAt,
    required super.updatedAt,
    required super.file,
    required this.businessName,
    super.isRemote = false,
  });
  factory AttachmentShowVO.fromAttachmentVo(
      AttachmentVO attachmentVO, String businessName) {
    return AttachmentShowVO(
      id: attachmentVO.id,
      originName: attachmentVO.originName,
      fileLength: attachmentVO.fileLength,
      extension: attachmentVO.extension,
      contentType: attachmentVO.contentType,
      businessCode: attachmentVO.businessCode,
      businessId: attachmentVO.businessId,
      createdBy: attachmentVO.createdBy,
      updatedBy: attachmentVO.updatedBy,
      createdAt: attachmentVO.createdAt,
      updatedAt: attachmentVO.updatedAt,
      businessName: businessName,
      file: attachmentVO.file,
    );
  }

  /// 从Attachment和File创建VO
  static Future<AttachmentShowVO> fromAttachment(
    Attachment attachment,
    String businessName,
  ) async {
    final attachVO = await AttachmentVO.fromAttachment(attachment);
    return AttachmentShowVO.fromAttachmentVo(
      attachVO,
      businessName,
    );
  }

  @override
  AttachmentShowVO copyWith({
    String? id,
    String? originName,
    int? fileLength,
    String? extension,
    String? contentType,
    String? businessCode,
    String? businessId,
    String? createdBy,
    String? updatedBy,
    int? createdAt,
    int? updatedAt,
    File? file,
    bool? isRemote,
    String? businessName,
  }) {
    return AttachmentShowVO(
      id: id ?? this.id,
      originName: originName ?? this.originName,
      fileLength: fileLength ?? this.fileLength,
      extension: extension ?? this.extension,
      contentType: contentType ?? this.contentType,
      businessCode: businessCode ?? this.businessCode,
      businessId: businessId ?? this.businessId,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      file: file ?? this.file,
      isRemote: isRemote ?? this.isRemote,
      businessName: businessName ?? this.businessName,
    );
  }
}
