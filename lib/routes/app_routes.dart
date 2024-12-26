import 'package:flutter/material.dart';

import '../manager/database_manager.dart';
import '../manager/user_config_manager.dart';
import '../pages/account_books_page.dart';
import '../pages/language_settings_page.dart';
import '../pages/theme_settings_page.dart';
import '../pages/user_info_page.dart';
import 'package:drift_db_viewer/drift_db_viewer.dart';

/// 应用路由配置
class AppRoutes {
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

  /// 路由表
  static Map<String, WidgetBuilder> routes = {
    userInfo: (context) => const UserInfoPage(),
    themeSettings: (context) => const ThemeSettingsPage(),
    languageSettings: (context) => const LanguageSettingsPage(),
    databaseViewer: (context) => DriftDbViewer(DatabaseManager.db),
    accountBooks: (context) => const AccountBooksPage(),
  };
}
