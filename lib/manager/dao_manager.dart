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
  static late BookDao bookDao;
  static late CategoryDao categoryDao;
  static late ItemDao itemDao;
  static late FundDao fundDao;
  static late ShopDao shopDao;
  static late SymbolDao symbolDao;
  static late RelBookUserDao relbookUserDao;
  static late LogSyncDao logSyncDao;
  static late UserDao userDao;
  static late AttachmentDao attachmentDao;
  static late NoteDao noteDao;

  static void refreshDaos() {
    bookDao = BookDao(DatabaseManager.db);
    categoryDao = CategoryDao(DatabaseManager.db);
    itemDao = ItemDao(DatabaseManager.db);
    fundDao = FundDao(DatabaseManager.db);
    shopDao = ShopDao(DatabaseManager.db);
    symbolDao = SymbolDao(DatabaseManager.db);
    relbookUserDao = RelBookUserDao(DatabaseManager.db);
    logSyncDao = LogSyncDao(DatabaseManager.db);
    userDao = UserDao(DatabaseManager.db);
    attachmentDao = AttachmentDao(DatabaseManager.db);
    noteDao = NoteDao(DatabaseManager.db);
  }
}
