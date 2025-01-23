import '../database/dao/book_dao.dart';
import '../database/dao/note_dao.dart';
import '../database/dao/attachment_dao.dart';
import '../database/dao/log_sync_dao.dart';
import '../database/dao/category_dao.dart';
import '../database/dao/fund_dao.dart';
import '../database/dao/item_dao.dart';
import '../database/dao/shop_dao.dart';
import '../database/dao/symbol_dao.dart';
import '../database/dao/rel_book_user_dao.dart';
import '../database/dao/user_dao.dart';
import 'database_manager.dart';

class DaoManager {
  static BookDao bookDao = BookDao(DatabaseManager.db);
  static CategoryDao categoryDao = CategoryDao(DatabaseManager.db);
  static ItemDao itemDao = ItemDao(DatabaseManager.db);
  static FundDao fundDao = FundDao(DatabaseManager.db);
  static ShopDao shopDao = ShopDao(DatabaseManager.db);
  static SymbolDao symbolDao = SymbolDao(DatabaseManager.db);
  static RelBookUserDao relbookUserDao = RelBookUserDao(DatabaseManager.db);
  static LogSyncDao logSyncDao = LogSyncDao(DatabaseManager.db);
  static UserDao userDao = UserDao(DatabaseManager.db);
  static AttachmentDao attachmentDao = AttachmentDao(DatabaseManager.db);
  static NoteDao noteDao = NoteDao(DatabaseManager.db);
}
