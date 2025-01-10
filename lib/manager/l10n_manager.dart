import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// 国际化管理器
class L10nManager {
  static AppLocalizations? _l10n;

  /// 获取当前的 AppLocalizations 实例
  static AppLocalizations get l10n {
    if (_l10n == null) {
      throw Exception('L10nManager not initialized. Call L10nManager.init() first.');
    }
    return _l10n!;
  }

  /// 初始化 AppLocalizations 实例
  static void init(AppLocalizations l10n) {
    _l10n = l10n;
  }
}
