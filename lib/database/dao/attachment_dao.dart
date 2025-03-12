import 'package:drift/drift.dart';
import '../../enums/business_type.dart';
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

  Future<void> deleteByBook(String accountBookId) async {
    try {
      final query = db.delete(table)
        ..where((t) =>
            t.businessCode.equals(BusinessType.item.code) &
            t.businessId.isInQuery(
              db.selectOnly(db.accountItemTable)
                ..addColumns([db.accountItemTable.id])
                ..where(
                    db.accountItemTable.accountBookId.equals(accountBookId)),
            ));
      await query.go();
    } catch (e, stackTrace) {
      print(stackTrace);
      rethrow;
    }
  }
}
