import './manager/app_config_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'generated/l10n/app_localizations.dart';
import 'manager/cache_manager.dart';
import 'manager/l10n_manager.dart';
import 'providers/locale_provider.dart';
import 'manager/provider_manager.dart';
import 'providers/theme_provider.dart';
import 'routes/app_routes.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //  初始化缓存工具
  await CacheManager.init();
  //  初始化配置管理器
  await AppConfigManager.init();
  runApp(
    ProviderManager.init(
      child: const ClsswjzApp(),
    ),
  );
}

class ClsswjzApp extends StatelessWidget {
  const ClsswjzApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Clsswjz',
      theme: themeProvider.getLightTheme(context),
      darkTheme: themeProvider.getDarkTheme(context),
      themeMode: themeProvider.themeMode,
      locale: localeProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('zh'),
        Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
      ],
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      initialRoute: AppConfigManager.isAppInit()
          ? AppRoutes.home
          : AppRoutes.serverConfig,
      builder: (context, child) {
        final l10n = AppLocalizations.of(context)!;
        L10nManager.init(l10n);
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
