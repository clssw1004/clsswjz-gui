import 'package:flutter/material.dart';
import '../manager/app_config_manager.dart';

/// 主题管理器
class ThemeProvider extends ChangeNotifier {
  /// 当前主题模式
  ThemeMode get themeMode => AppConfigManager.instance.themeMode;

  /// 当前主题颜色
  Color get themeColor => AppConfigManager.instance.themeColor;

  /// 当前字体大小
  double get fontSize => AppConfigManager.instance.fontSize;

  /// 当前圆角大小
  double get radius => AppConfigManager.instance.radius;

  /// 是否使用 Material 3
  bool get useMaterial3 => AppConfigManager.instance.useMaterial3;

  /// 获取所有可用的主题颜色
  List<MaterialColor> get availableColors => Colors.primaries;

  /// 设置主题模式
  Future<void> setThemeMode(ThemeMode mode) async {
    if (themeMode == mode) return;

    await AppConfigManager.instance.setThemeMode(mode);
    notifyListeners();
  }

  /// 设置主题颜色
  Future<void> setThemeColor(Color color) async {
    if (themeColor.value == color.value) return;

    await AppConfigManager.instance.setThemeColor(color);
    notifyListeners();
  }

  /// 设置字体大小
  Future<void> setFontSize(double size) async {
    if (fontSize == size) return;

    await AppConfigManager.instance.setFontSize(size);
    notifyListeners();
  }

  /// 设置圆角大小
  Future<void> setRadius(double radius) async {
    if (this.radius == radius) return;

    await AppConfigManager.instance.setRadius(radius);
    notifyListeners();
  }

  /// 设置是否使用 Material 3
  Future<void> setUseMaterial3(bool use) async {
    if (useMaterial3 == use) return;

    await AppConfigManager.instance.setUseMaterial3(use);
    notifyListeners();
  }

  /// 获取亮色主题
  ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: themeColor,
        brightness: Brightness.light,
      ),
      useMaterial3: useMaterial3,
      textTheme: _getTextTheme(Brightness.light),
      cardTheme: _getCardTheme(),
      inputDecorationTheme: _getInputDecorationTheme(),
      buttonTheme: _getButtonTheme(),
      elevatedButtonTheme: _getElevatedButtonTheme(Brightness.light),
      outlinedButtonTheme: _getOutlinedButtonTheme(Brightness.light),
      textButtonTheme: _getTextButtonTheme(Brightness.light),
    );
  }

  /// 获取暗色主题
  ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: themeColor,
        brightness: Brightness.dark,
      ),
      useMaterial3: useMaterial3,
      textTheme: _getTextTheme(Brightness.dark),
      cardTheme: _getCardTheme(),
      inputDecorationTheme: _getInputDecorationTheme(),
      buttonTheme: _getButtonTheme(),
      elevatedButtonTheme: _getElevatedButtonTheme(Brightness.dark),
      outlinedButtonTheme: _getOutlinedButtonTheme(Brightness.dark),
      textButtonTheme: _getTextButtonTheme(Brightness.dark),
    );
  }

  /// 获取文本主题
  TextTheme _getTextTheme(Brightness brightness) {
    final baseTheme = brightness == Brightness.light
        ? ThemeData.light().textTheme
        : ThemeData.dark().textTheme;

    return baseTheme.copyWith(
      displayLarge: baseTheme.displayLarge?.copyWith(fontSize: 96 * fontSize),
      displayMedium: baseTheme.displayMedium?.copyWith(fontSize: 60 * fontSize),
      displaySmall: baseTheme.displaySmall?.copyWith(fontSize: 48 * fontSize),
      headlineLarge: baseTheme.headlineLarge?.copyWith(fontSize: 40 * fontSize),
      headlineMedium:
          baseTheme.headlineMedium?.copyWith(fontSize: 34 * fontSize),
      headlineSmall: baseTheme.headlineSmall?.copyWith(fontSize: 24 * fontSize),
      titleLarge: baseTheme.titleLarge?.copyWith(fontSize: 20 * fontSize),
      titleMedium: baseTheme.titleMedium?.copyWith(fontSize: 16 * fontSize),
      titleSmall: baseTheme.titleSmall?.copyWith(fontSize: 14 * fontSize),
      bodyLarge: baseTheme.bodyLarge?.copyWith(fontSize: 16 * fontSize),
      bodyMedium: baseTheme.bodyMedium?.copyWith(fontSize: 14 * fontSize),
      bodySmall: baseTheme.bodySmall?.copyWith(fontSize: 12 * fontSize),
      labelLarge: baseTheme.labelLarge?.copyWith(fontSize: 14 * fontSize),
      labelMedium: baseTheme.labelMedium?.copyWith(fontSize: 12 * fontSize),
      labelSmall: baseTheme.labelSmall?.copyWith(fontSize: 10 * fontSize),
    );
  }

  /// 获取卡片主题
  CardTheme _getCardTheme() {
    return CardTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      clipBehavior: Clip.antiAlias,
    );
  }

  /// 获取输入框装饰主题
  InputDecorationTheme _getInputDecorationTheme() {
    return InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  /// 获取按钮主题
  ButtonThemeData _getButtonTheme() {
    return ButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  /// 获取凸起按钮主题
  ElevatedButtonThemeData _getElevatedButtonTheme(Brightness brightness) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  /// 获取轮廓按钮主题
  OutlinedButtonThemeData _getOutlinedButtonTheme(Brightness brightness) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  /// 获取文本按钮主题
  TextButtonThemeData _getTextButtonTheme(Brightness brightness) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// 字体大小常量
class FontSize {
  static const double smaller = 0.85;
  static const double normal = 1.0;
  static const double larger = 1.15;
  static const double largest = 1.3;

  static const List<Map<String, dynamic>> options = [
    {'label': '较小', 'value': smaller},
    {'label': '默认', 'value': normal},
    {'label': '较大', 'value': larger},
    {'label': '最大', 'value': largest},
  ];
}

/// 圆角大小常量
class Radius {
  static const double none = 0.0;
  static const double small = 4.0;
  static const double medium = 8.0;
  static const double large = 12.0;

  static const List<Map<String, dynamic>> options = [
    {'label': '无', 'value': none},
    {'label': '小', 'value': small},
    {'label': '中', 'value': medium},
    {'label': '大', 'value': large},
  ];
}
