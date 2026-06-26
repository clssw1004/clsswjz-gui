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
import '../providers/gift_card_provider.dart';
import '../providers/activity_checkin_provider.dart';
import '../providers/activity_provider.dart';
import '../providers/item_relation_provider.dart';
import '../providers/shared_module_provider.dart';
import '../providers/recurring_config_provider.dart';
import '../providers/bookkeeping_rule_provider.dart';
import '../providers/category_provider.dart';
import '../providers/shop_provider.dart';
import 'app_config_manager.dart';
import 'sync_manager.dart';

/// Provider 管理器
class ProviderManager {
  static CategoryProvider? _categoryProvider;
  static ShopProvider? _shopProvider;

  static CategoryProvider get categoryProvider =>
      _categoryProvider ??= CategoryProvider();
  static ShopProvider get shopProvider =>
      _shopProvider ??= ShopProvider();

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
          ChangeNotifierProvider(create: (_) => GiftCardProvider()),
          ChangeNotifierProvider(create: (_) => ActivityProvider()),
          ChangeNotifierProvider(create: (_) => ActivityCheckinProvider()),
          ChangeNotifierProvider(create: (_) => ItemRelationProvider()),
          ChangeNotifierProvider(create: (_) => SharedModuleProvider()),
          ChangeNotifierProvider(create: (_) => RecurringConfigProvider()),
          ChangeNotifierProvider(create: (_) => BookkeepingRuleProvider()),
          ChangeNotifierProvider(create: (_) {
            _categoryProvider = CategoryProvider();
            return _categoryProvider!;
          }),
          ChangeNotifierProvider(create: (_) {
            _shopProvider = ShopProvider();
            return _shopProvider!;
          }),
        ],
        child: child,
      ),
    );
  }
}
