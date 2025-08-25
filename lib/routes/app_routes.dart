import 'package:flutter/material.dart';

import '../manager/app_config_manager.dart';
import '../manager/database_manager.dart';
import '../models/vo/book_meta.dart';
import '../models/vo/user_book_vo.dart' show UserBookVO;
import '../models/vo/user_debt_vo.dart';
import '../models/vo/user_item_vo.dart';
import '../pages/book/book_list_page.dart';
import '../pages/book/item_add_page.dart';
import '../pages/book/item_edit_page.dart';
import '../pages/book/book_form_page.dart';
import '../pages/book/merchants_page.dart';
import '../pages/book/refund_form_page.dart';
import '../pages/home_page.dart';
import '../pages/import/import_page.dart';
import '../pages/settings/language_settings_page.dart';
import '../pages/settings/server_config_page.dart';
import '../pages/settings/theme_settings_page.dart';
import '../pages/user_info_page.dart';
import 'package:drift_db_viewer/drift_db_viewer.dart';
import '../pages/book/tags_page.dart';
import '../pages/book/projects_page.dart';
import '../pages/book/categories_page.dart';
import '../pages/book/fund_list_page.dart';
import '../pages/settings/about_page.dart';
import '../pages/settings/sync_settings_page.dart';
import '../pages/book/note_form_page.dart';
import '../models/vo/user_note_vo.dart';
import '../pages/settings/reset_auth_page.dart';
import '../pages/settings/ui_layout_config_page.dart';
import '../pages/book/debt_add_page.dart';
import '../pages/book/item_list_page.dart';
import '../pages/book/items.page.dart';
import '../models/dto/item_filter_dto.dart';
import '../pages/book/debt_list_page.dart';
import '../pages/book/debt_edit_page.dart';
import '../pages/book/debt_payment_page.dart';
import '../pages/attachment/attachment_list_page.dart';

/// 应用路由配置
class AppRoutes {
  static const String home = '/home';

  /// 用户信息页面
  static const String userInfo = '/user_info';

  /// 主题设置页面
  static const String themeSettings = '/theme_settings';

  /// 语言设置页面
  static const String languageSettings = '/language_settings';

  /// 数据库查看器页面
  static const String databaseViewer = '/database_viewer';

  /// UI布局设置页面
  static const String uiLayoutSettings = '/ui_layout_settings';

  /// 账本列表页面
  static const String accountBooks = '/books';

  /// 账目详情表单页面
  static const String itemAdd = '/item_add';

  /// 账目编辑页面
  static const String itemEdit = '/item_edit';

  /// 账目退款页面
  static const String itemRefund = '/item_refund';

  /// 账目列表页面
  static const String itemsList = '/items_list';

  /// 通用账目列表页面（可接收筛选条件）
  static const String items = '/items';

  /// 账本创建页面
  static const String bookForm = '/book_form';

  static const String serverConfig = '/server_config';

  static const String merchants = '/merchants';

  static const String tags = '/tags';

  static const String projects = '/projects';

  static const String categories = '/categories';

  /// 资金账户列表页面
  static const String funds = '/funds';

  static const String about = '/about';

  static const String syncSettings = '/sync_settings';

  static const String import = '/import';

  static const String noteAdd = '/note_add';

  static const String noteEdit = '/note_edit';

  static const String resetAuth = '/reset_auth';

  static const String debtAdd = '/debt/add';

  static const String debtList = '/debt/list';

  static const String debtEdit = '/debt/edit';

  static const String debtPayment = '/debt/payment';

  static const String attachments = '/attachments';

  static const String todoAdd = '/todo/add';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => AppConfigManager.isAppInit()
          ? const HomePage()
          : const ServerConfigPage(),
    );
  }

  /// 路由表
  static Map<String, WidgetBuilder> routes = {
    home: (context) => const HomePage(),
    userInfo: (context) => const UserInfoPage(),
    themeSettings: (context) => const ThemeSettingsPage(),
    languageSettings: (context) => const LanguageSettingsPage(),
    databaseViewer: (context) => DriftDbViewer(DatabaseManager.db),
    uiLayoutSettings: (context) => const UiConfigPage(),
    accountBooks: (context) => const BookListPage(),
    bookForm: (context) => const BookFormPage(),
    itemAdd: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as List<dynamic>;

      final accountBook = args[0] as BookMetaVO;
      return ItemAddPage(bookMeta: accountBook);
    },
    itemEdit: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as List<dynamic>;
      final accountBook = args[0] as BookMetaVO;
      final item = args[1] as UserItemVO;
      return ItemEditPage(bookMeta: accountBook, item: item);
    },
    itemRefund: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as List<dynamic>;
      final accountBook = args[0] as BookMetaVO;
      final item = args[1] as UserItemVO;
      return RefundFormPage(bookMeta: accountBook, originalItem: item);
    },
    itemsList: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as BookMetaVO;
      return ItemListPage(accountBook: args);
    },
    items: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as List<dynamic>;
      final bookMeta = args[0] as BookMetaVO;
      final filter = args.length > 1 ? args[1] as ItemFilterDTO? : null;
      final title = args.length > 2 ? args[2] as String? : null;
      return ItemsPage(bookMeta: bookMeta, initialFilter: filter, title: title);
    },
    serverConfig: (context) => const ServerConfigPage(),
    merchants: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as BookMetaVO;
      return MerchantsPage(accountBook: args);
    },
    tags: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as BookMetaVO;
      return TagsPage(accountBook: args);
    },
    projects: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as BookMetaVO;
      return ProjectsPage(accountBook: args);
    },
    categories: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as BookMetaVO;
      return AccountCategoriesPage(accountBook: args);
    },
    funds: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as BookMetaVO;
      return FundListPage(accountBook: args);
    },
    about: (context) => const AboutPage(),
    syncSettings: (context) => const SyncSettingsPage(),
    import: (context) => const ImportPage(),
    resetAuth: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as String;
      return ResetAuthPage(serverUrl: args);
    },
    noteAdd: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as List<dynamic>;
      final accountBook = args[0] as UserBookVO;
      return NoteFormPage(book: accountBook);
    },
    noteEdit: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as List<dynamic>;
      final note = args[0] as UserNoteVO;
      final accountBook = args[1] as UserBookVO;
      return NoteFormPage(note: note, book: accountBook);
    },
    debtAdd: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as List<dynamic>;
      final accountBook = args[0] as BookMetaVO;
      final debtor = args.length > 1 ? args[1] as String? : null;
      return DebtAddPage(book: accountBook, debtor: debtor);
    },
    debtList: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as BookMetaVO;
      return DebtListPage(bookMeta: args);
    },
    debtEdit: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as List<dynamic>;
      final accountBook = args[0] as BookMetaVO;
      final debt = args[1] as UserDebtVO;
      return DebtEditPage(book: accountBook, debt: debt);
    },
    debtPayment: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as List<dynamic>;
      final title = args[0] as String;
      final accountBook = args[1] as BookMetaVO;
      final debt = args[2] as UserDebtVO;
      final categoryCode = args[3] as String;

      return DebtPaymentPage(
        title: title,
        book: accountBook,
        debt: debt,
        categoryCode: categoryCode,
      );
    },
    attachments: (context) => const AttachmentListPage(),
  };
}
