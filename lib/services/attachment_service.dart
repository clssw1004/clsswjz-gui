import 'package:drift/drift.dart';
import '../enums/business_type.dart';
import '../manager/dao_manager.dart';
import '../manager/database_manager.dart';
import 'base_service.dart';
import '../models/vo/attachment_vo.dart';

/// 附件服务
class AttachmentService extends BaseService {
  Future<AttachmentVO?> getAttachment(String? id) async {
    if (id == null) return null;
    final attachment = await DaoManager.attachmentDao.findById(id);
    if (attachment == null) {
      return null;
    }
    return await AttachmentVO.fromAttachment(attachment);
  }

  Future<List<AttachmentVO>> getAttachments(List<String>? ids) async {
    if (ids == null || ids.isEmpty) return [];
    final attachments = await DaoManager.attachmentDao.findByIds(ids);
    if (attachments.isEmpty) return [];
    final attachmentVOs = <AttachmentVO>[];
    for (var attachment in attachments) {
      attachmentVOs.add(await AttachmentVO.fromAttachment(attachment));
    }
    return attachmentVOs;
  }

  /// 获取业务相关的所有附件
  Future<List<AttachmentVO>> getAttachmentsByBusiness(
    BusinessType businessType,
    String businessId,
  ) async {
    final attachments = await (DatabaseManager.db.select(DatabaseManager.db.attachmentTable)
          ..where((t) => t.businessId.equals(businessId) & t.businessCode.equals(businessType.code)))
        .get();
    final attachmentVOs = <AttachmentVO>[];
    for (var attachment in attachments) {
      attachmentVOs.add(await AttachmentVO.fromAttachment(attachment));
    }
    return attachmentVOs;
  }
}
