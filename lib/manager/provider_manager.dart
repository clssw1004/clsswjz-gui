import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_init.dart';
import '../providers/books_provider.dart';
import '../providers/item_list_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/note_list_provider.dart';
import '../providers/statistics_provider.dart';
import '../providers/sync_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/common/restart_widget.dart';
import '../providers/debt_list_provider.dart';
import 'app_config_manager.dart';
import 'sync_manager.dart';

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
          ChangeNotifierProvider<SyncProvider>(
            create: (context) {
              final syncProvider = SyncProvider();
              // 初始化同步管理器
              SyncManager().initialize(syncProvider);
              return syncProvider;
            },
          ),
          ChangeNotifierProvider<BooksProvider>(
            create: (_) =>
                BooksProvider()..init(AppConfigManager.instance.userId),
          ),
          ChangeNotifierProvider<ItemListProvider>(
            create: (_) => ItemListProvider(),
          ),
          ChangeNotifierProvider<NoteListProvider>(
            create: (_) => NoteListProvider(),
          ),
          ChangeNotifierProvider(create: (_) => DebtListProvider()),
          ChangeNotifierProvider(create: (_) => StatisticsProvider()),
        ],
        child: child,
      ),
    );
  }
}
