import 'package:clsswjz/models/vo/user_book_vo.dart';
import 'package:flutter/material.dart';

import '../manager/database_manager.dart';
import '../pages/account_books_page.dart';
import '../pages/account_item_form_page.dart';
import '../pages/account_book_form_page.dart';
import '../pages/home_page.dart';
import '../pages/language_settings_page.dart';
import '../pages/server_config_page.dart';
import '../pages/settings/theme_settings_page.dart';
import '../pages/user_info_page.dart';
import '../models/vo/account_item_vo.dart';
import 'package:drift_db_viewer/drift_db_viewer.dart';

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

  /// 账本列表页面
  static const String accountBooks = '/account_books';

  /// 账目详情表单页面
  static const String accountItemForm = '/account_item_form';

  /// 账本创建页面
  static const String accountBookForm = '/account_book_form';

  static const String serverConfig = '/server-config';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => const ServerConfigPage(),
    );
  }

  /// 路由表
  static Map<String, WidgetBuilder> routes = {
    home: (context) => const HomePage(),
    userInfo: (context) => const UserInfoPage(),
    themeSettings: (context) => const ThemeSettingsPage(),
    languageSettings: (context) => const LanguageSettingsPage(),
    databaseViewer: (context) => DriftDbViewer(DatabaseManager.db),
    accountBooks: (context) => const AccountBooksPage(),
    accountBookForm: (context) => const AccountBookFormPage(),
    accountItemForm: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as List<dynamic>;
      final accountBook = args[0] as UserBookVO;
      final item = args[1] as AccountItemVO;
      return AccountItemFormPage(accountBook: accountBook, item: item);
    },
    serverConfig: (context) => const ServerConfigPage(),
  };
}
