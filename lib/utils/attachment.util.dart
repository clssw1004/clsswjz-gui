import 'dart:io';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../enums/business_type.dart';
import '../models/vo/attachment_vo.dart';
import 'date_util.dart';
import 'id_util.dart';

class AttachmentUtil {
  static const String ATTACHMENT_DIR = 'attachments';

  /// 获取附件存储目录
  static Future<Directory> getAttachmentDir() async {
    final appDir = await getApplicationDocumentsDirectory();
    final attachmentDir = Directory(path.join(appDir.path, ATTACHMENT_DIR));
    if (!await attachmentDir.exists()) {
      await attachmentDir.create(recursive: true);
    }
    return attachmentDir;
  }

  /// 根据附件ID获取文件路径
  static Future<String> getAttachmentPath(String attachmentId, String extension) async {
    final dir = await getAttachmentDir();
    return path.join(dir.path, '$attachmentId$extension');
  }

  static Future<void> copyFileToLocal(AttachmentVO vo) async {
    if (vo.file == null) throw Exception("文件为空");
    final targetPath = await getAttachmentPath(vo.id, vo.extension);
    await vo.file!.copy(targetPath);
  }

  /// 从文件生成附件VO
  static AttachmentVO generateVoFromFile(
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
    final id = IdUtil.genId();

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
}
