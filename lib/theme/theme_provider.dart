import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 主题管理器
class ThemeProvider extends ChangeNotifier {
  static const String _themePrefsKey = 'theme_mode';
  static const String _colorPrefsKey = 'theme_color';
  static const String _fontSizePrefsKey = 'font_size';
  static const String _radiusPrefsKey = 'radius';
  static const String _useMaterial3PrefsKey = 'use_material3';

  late SharedPreferences _prefs;
  ThemeMode _themeMode = ThemeMode.system;
  MaterialColor _themeColor = Colors.blue;
  double _fontSize = FontSize.normal; // 字体缩放比例
  double _radius = Radius.medium; // 圆角大小
  bool _useMaterial3 = true; // 是否使用 Material 3

  ThemeProvider() {
    _loadPreferences();
  }

  /// 初始化
  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();

    // 加载主题模式
    final themeModeString = _prefs.getString(_themePrefsKey);
    if (themeModeString != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == themeModeString,
        orElse: () => ThemeMode.system,
      );
    }

    // 加载主题颜色
    final colorValue = _prefs.getInt(_colorPrefsKey);
    if (colorValue != null) {
      _themeColor = _getMaterialColor(colorValue);
    }

    // 加载字体大小
    _fontSize = _prefs.getDouble(_fontSizePrefsKey) ?? FontSize.normal;

    // 加载圆角大小
    _radius = _prefs.getDouble(_radiusPrefsKey) ?? Radius.medium;

    // 加载是否使用 Material 3
    _useMaterial3 = _prefs.getBool(_useMaterial3PrefsKey) ?? true;

    notifyListeners();
  }

  /// 获取当前主题模式
  ThemeMode get themeMode => _themeMode;

  /// 获取当前主题颜色
  MaterialColor get themeColor => _themeColor;

  /// 获取字体缩放比例
  double get fontSize => _fontSize;

  /// 获取圆角大小
  double get radius => _radius;

  /// 是否使用 Material 3
  bool get useMaterial3 => _useMaterial3;

  /// 获取亮色主题
  ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _themeColor,
        brightness: Brightness.light,
      ),
      useMaterial3: _useMaterial3,
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
        seedColor: _themeColor,
        brightness: Brightness.dark,
      ),
      useMaterial3: _useMaterial3,
      textTheme: _getTextTheme(Brightness.dark),
      cardTheme: _getCardTheme(),
      inputDecorationTheme: _getInputDecorationTheme(),
      buttonTheme: _getButtonTheme(),
      elevatedButtonTheme: _getElevatedButtonTheme(Brightness.dark),
      outlinedButtonTheme: _getOutlinedButtonTheme(Brightness.dark),
      textButtonTheme: _getTextButtonTheme(Brightness.dark),
    );
  }

  /// 设置主题模式
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      await _prefs.setString(_themePrefsKey, mode.toString());
      notifyListeners();
    }
  }

  /// 设置主题颜色
  Future<void> setThemeColor(MaterialColor color) async {
    if (_themeColor != color) {
      _themeColor = color;
      await _prefs.setInt(_colorPrefsKey, color.value);
      notifyListeners();
    }
  }

  /// 设置字体大小
  Future<void> setFontSize(double size) async {
    if (_fontSize != size) {
      _fontSize = size;
      await _prefs.setDouble(_fontSizePrefsKey, size);
      notifyListeners();
    }
  }

  /// 设置圆角大小
  Future<void> setRadius(double radius) async {
    if (_radius != radius) {
      _radius = radius;
      await _prefs.setDouble(_radiusPrefsKey, radius);
      notifyListeners();
    }
  }

  /// 设置是否使用 Material 3
  Future<void> setUseMaterial3(bool use) async {
    if (_useMaterial3 != use) {
      _useMaterial3 = use;
      await _prefs.setBool(_useMaterial3PrefsKey, use);
      notifyListeners();
    }
  }

  /// 根据颜色值获取 MaterialColor
  MaterialColor _getMaterialColor(int value) {
    return Colors.primaries.firstWhere(
      (color) => color.value == value,
      orElse: () => Colors.blue,
    );
  }

  /// 获取文本主题
  TextTheme _getTextTheme(Brightness brightness) {
    final baseTheme = brightness == Brightness.light
        ? ThemeData.light().textTheme
        : ThemeData.dark().textTheme;

    return baseTheme.copyWith(
      displayLarge: baseTheme.displayLarge?.copyWith(fontSize: 96 * _fontSize),
      displayMedium:
          baseTheme.displayMedium?.copyWith(fontSize: 60 * _fontSize),
      displaySmall: baseTheme.displaySmall?.copyWith(fontSize: 48 * _fontSize),
      headlineLarge:
          baseTheme.headlineLarge?.copyWith(fontSize: 40 * _fontSize),
      headlineMedium:
          baseTheme.headlineMedium?.copyWith(fontSize: 34 * _fontSize),
      headlineSmall:
          baseTheme.headlineSmall?.copyWith(fontSize: 24 * _fontSize),
      titleLarge: baseTheme.titleLarge?.copyWith(fontSize: 20 * _fontSize),
      titleMedium: baseTheme.titleMedium?.copyWith(fontSize: 16 * _fontSize),
      titleSmall: baseTheme.titleSmall?.copyWith(fontSize: 14 * _fontSize),
      bodyLarge: baseTheme.bodyLarge?.copyWith(fontSize: 16 * _fontSize),
      bodyMedium: baseTheme.bodyMedium?.copyWith(fontSize: 14 * _fontSize),
      bodySmall: baseTheme.bodySmall?.copyWith(fontSize: 12 * _fontSize),
      labelLarge: baseTheme.labelLarge?.copyWith(fontSize: 14 * _fontSize),
      labelMedium: baseTheme.labelMedium?.copyWith(fontSize: 12 * _fontSize),
      labelSmall: baseTheme.labelSmall?.copyWith(fontSize: 10 * _fontSize),
    );
  }

  /// 获取卡片主题
  CardTheme _getCardTheme() {
    return CardTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radius),
      ),
      clipBehavior: Clip.antiAlias,
    );
  }

  /// 获取输入框装饰主题
  InputDecorationTheme _getInputDecorationTheme() {
    return InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_radius),
      ),
    );
  }

  /// 获取按钮主题
  ButtonThemeData _getButtonTheme() {
    return ButtonThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_radius),
      ),
    );
  }

  /// 获取凸起按钮主题
  ElevatedButtonThemeData _getElevatedButtonTheme(Brightness brightness) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
      ),
    );
  }

  /// 获取轮廓按钮主题
  OutlinedButtonThemeData _getOutlinedButtonTheme(Brightness brightness) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
      ),
    );
  }

  /// 获取文本按钮主题
  TextButtonThemeData _getTextButtonTheme(Brightness brightness) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
      ),
    );
  }

  /// 获取所有可用的主题颜色
  static List<MaterialColor> get availableColors => Colors.primaries;
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
