import 'package:flutter/material.dart';
import '../manager/app_config_manager.dart';

/// 语言设置状态管理
class LocaleProvider with ChangeNotifier {
  /// 当前语言
  Locale get locale => AppConfigManager.instance.locale;

  /// 设置语言
  Future<void> setLocale(Locale? newLocale) async {
    if (newLocale == null || locale == newLocale) return;

    await AppConfigManager.instance.setLocale(newLocale);
    notifyListeners();
  }
}
