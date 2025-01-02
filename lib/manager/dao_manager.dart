import '../database/dao/account_book_dao.dart';
import '../database/dao/account_book_log_dao.dart';
import '../database/dao/account_category_dao.dart';
import '../database/dao/account_fund_dao.dart';
import '../database/dao/account_item_dao.dart';
import '../database/dao/account_shop_dao.dart';
import '../database/dao/account_symbol_dao.dart';
import '../database/dao/rel_accountbook_fund_dao.dart';
import '../database/dao/rel_accountbook_user_dao.dart';
import 'database_manager.dart';

class DaoManager {
  static AccountBookDao accountBookDao = AccountBookDao(DatabaseManager.db);
  static AccountCategoryDao accountCategoryDao =
      AccountCategoryDao(DatabaseManager.db);
  static AccountItemDao accountItemDao = AccountItemDao(DatabaseManager.db);
  static AccountFundDao accountFundDao = AccountFundDao(DatabaseManager.db);
  static AccountShopDao accountShopDao = AccountShopDao(DatabaseManager.db);
  static AccountSymbolDao accountSymbolDao =
      AccountSymbolDao(DatabaseManager.db);
  static RelAccountbookFundDao relAccountbookFundDao =
      RelAccountbookFundDao(DatabaseManager.db);
  static RelAccountbookUserDao relAccountbookUserDao =
      RelAccountbookUserDao(DatabaseManager.db);
  static AccountBookLogDao accountBookLogDao =
      AccountBookLogDao(DatabaseManager.db);
}
