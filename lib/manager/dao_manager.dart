import '../database/dao/account_book_dao.dart';
import '../database/dao/attachment_dao.dart';
import '../database/dao/log_sync_dao.dart';
import '../database/dao/account_category_dao.dart';
import '../database/dao/account_fund_dao.dart';
import '../database/dao/account_item_dao.dart';
import '../database/dao/account_shop_dao.dart';
import '../database/dao/account_symbol_dao.dart';
import '../database/dao/rel_accountbook_user_dao.dart';
import '../database/dao/user_dao.dart';
import 'database_manager.dart';

class DaoManager {
  static AccountBookDao accountBookDao = AccountBookDao(DatabaseManager.db);
  static AccountCategoryDao accountCategoryDao = AccountCategoryDao(DatabaseManager.db);
  static AccountItemDao accountItemDao = AccountItemDao(DatabaseManager.db);
  static AccountFundDao accountFundDao = AccountFundDao(DatabaseManager.db);
  static AccountShopDao accountShopDao = AccountShopDao(DatabaseManager.db);
  static AccountSymbolDao accountSymbolDao = AccountSymbolDao(DatabaseManager.db);
  static RelAccountbookUserDao relAccountbookUserDao = RelAccountbookUserDao(DatabaseManager.db);
  static LogSyncDao logSyncDao = LogSyncDao(DatabaseManager.db);
  static UserDao userDao = UserDao(DatabaseManager.db);
  static AttachmentDao attachmentDao = AttachmentDao(DatabaseManager.db);
}
