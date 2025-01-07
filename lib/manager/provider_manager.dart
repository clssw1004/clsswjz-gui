import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_init.dart';
import '../providers/account_books_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/common/restart_widget.dart';
import 'user_config_manager.dart';

/// Provider 管理器
class ProviderManager {
  /// 初始化所有 Provider
  static Widget init({required Widget child}) {
    return RestartWidget(
      initFunction: initApp,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<LocaleProvider>(
            create: (_) => LocaleProvider(),
          ),
          ChangeNotifierProvider<ThemeProvider>(
            create: (_) => ThemeProvider(),
          ),
          ChangeNotifierProvider<UserProvider>(
            create: (_) => UserProvider()..refreshUserInfo(),
          ),
          ChangeNotifierProvider<AccountBooksProvider>(
            create: (_) =>
                AccountBooksProvider()..init(UserConfigManager.currentUserId),
          ),
        ],
        child: child,
      ),
    );
  }
}
