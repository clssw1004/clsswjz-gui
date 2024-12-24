import 'package:drift/drift.dart';
import 'base_table.dart';

@DataClassName('Attachment')
class AttachmentTable extends BaseBusinessTable {
  TextColumn get originName => text().named('origin_name')();
  IntColumn get fileLength => integer().named('file_length')();
  TextColumn get extension => text().named('extension')();
  TextColumn get contentType => text().named('content_type')();
  TextColumn get businessCode => text().named('business_code')();
  TextColumn get businessId => text().named('business_id')();
}
