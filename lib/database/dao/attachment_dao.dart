import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/attachment_table.dart';
import 'base_dao.dart';

class AttachmentDao extends BaseDao<AttachmentTable, Attachment> {
  AttachmentDao(super.db);
  @override
  TableInfo<AttachmentTable, Attachment> get table => db.attachmentTable;
}
