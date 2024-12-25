import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/locale_provider.dart';

/// 语言设置页面
class LanguageSettingsPage extends StatelessWidget {
  const LanguageSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = context.watch<LocaleProvider>();
    final currentLocale = localeProvider.locale;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.languageSettings),
      ),
      body: ListView(
        children: [
          RadioListTile<Locale>(
            title: const Text('简体中文'),
            value: const Locale('zh'),
            groupValue: currentLocale,
            onChanged: (value) => localeProvider.setLocale(value),
          ),
          RadioListTile<Locale>(
            title: const Text('繁體中文'),
            value: const Locale('zh', 'TW'),
            groupValue: currentLocale,
            onChanged: (value) => localeProvider.setLocale(value),
          ),
          RadioListTile<Locale>(
            title: const Text('English'),
            value: const Locale('en'),
            groupValue: currentLocale,
            onChanged: (value) => localeProvider.setLocale(value),
          ),
        ],
      ),
    );
  }
}
