import 'dart:convert';
import 'dart:io';
import 'package:clsswjz/models/vo/attachment_vo.dart';
import '../../../../database/database.dart';
import '../../../../enums/business_type.dart';
import '../../../../manager/dao_manager.dart';
import '../../../../utils/attachment.util.dart';
import 'builder.dart';

class AttachmentCULog extends LogBuilder<AttachmentVO, String> {
  AttachmentCULog() : super() {
    doWith(BusinessType.attachment);
  }

  @override
  Future<String> executeLog() async {
    await DaoManager.attachmentDao.insert(data!.toAttachment());
    await AttachmentUtil.copyFileToLocal(data!);
    subject(data!.id);
    return data!.id;
  }

  static AttachmentCULog fromFile(
    String who, {
    required BusinessType belongType,
    required String belongId,
    required File file,
  }) {
    AttachmentVO vo =
        AttachmentUtil.generateVoFromFile(belongType, belongId, file, who);
    return fromVO(who, belongType: belongType, belongId: belongId, vo: vo);
  }

  static AttachmentCULog fromVO(String who,
      {required BusinessType belongType,
      required String belongId,
      required AttachmentVO vo}) {
    return AttachmentCULog()
        .who(who)
        .withBelong(belongType, belongId)
        .doCreate()
        .withData(vo) as AttachmentCULog;
  }

  static AttachmentCULog fromLog(LogSync log) {
    return AttachmentCULog().who(log.operatorId).doCreate().withData(
            Attachment.fromJson(jsonDecode(log.operateData)).toCompanion(true))
        as AttachmentCULog;
  }
}

class AttachmentDeleteLog extends DeleteLog {
  AttachmentDeleteLog() {
    doWith(BusinessType.attachment);
  }

  @override
  Future<void> executeLog() async {
    Attachment? attachment =
        await DaoManager.attachmentDao.findById(businessId!);
    if (attachment == null) return;
    final filePath = await AttachmentUtil.getAttachmentPath(
        attachment.id, attachment.extension);
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
    DaoManager.attachmentDao.delete(businessId!);
  }

  static AttachmentDeleteLog fromAttachmentId(String who,
      {required BusinessType belongType,
      required String belongId,
      required String attachmentId}) {
    return AttachmentDeleteLog()
        .who(who)
        .withBelong(belongType, belongId)
        .subject(attachmentId) as AttachmentDeleteLog;
  }
}
