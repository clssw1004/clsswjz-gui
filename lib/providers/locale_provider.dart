import 'package:flutter/material.dart';
import '../models/app_config.dart';

/// 语言设置状态管理
class LocaleProvider with ChangeNotifier {
  /// 当前语言
  Locale get locale => AppConfig.instance.locale;

  /// 设置语言
  Future<void> setLocale(Locale? newLocale) async {
    if (newLocale == null || locale == newLocale) return;

    await AppConfig.instance.setLocale(newLocale);
    notifyListeners();
  }

  /// 初始化语言设置
  static Future<LocaleProvider> init() async {
    await AppConfig.init();
    return LocaleProvider();
  }
}
