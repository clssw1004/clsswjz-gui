import 'package:clsswjz/enums/business_type.dart';
import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/attachment_table.dart';
import 'base_dao.dart';

class AttachmentDao extends BaseDao<AttachmentTable, Attachment> {
  AttachmentDao(super.db);
  @override
  TableInfo<AttachmentTable, Attachment> get table => db.attachmentTable;

  Future<List<Attachment>> findByBusinessId(
      BusinessType businessType, String businessId) async {
    return (db.select(db.attachmentTable)
          ..where((t) =>
              t.businessId.equals(businessId) &
              t.businessCode.equals(businessType.code)))
        .get();
  }
}
