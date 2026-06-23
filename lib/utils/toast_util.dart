import 'package:flutter/material.dart';
import '../main.dart';

/// 语义化提示工具
class ToastUtil {
  ToastUtil._();

  static void showSuccess(String msg) => _show(msg, _c(Colors.green));
  static void showError(String msg)   => _show(msg, _c(Colors.red));
  static void showInfo(String msg)    => _show(msg, _c(Colors.blue));
  static void showWarning(String msg) => _show(msg, _c(Colors.orange));

  /// 亮色用 shade600，暗色用 shade700，保持视觉舒适
  static Color _c(MaterialColor c) {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return c;
    return Theme.of(ctx).brightness == Brightness.dark ? c.shade700 : c.shade600;
  }

  static void _show(String message, Color bg) {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;

    ScaffoldMessenger.of(ctx).clearSnackBars();
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
      backgroundColor: bg,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      duration: const Duration(seconds: 3),
      dismissDirection: DismissDirection.horizontal,
    ));
  }
}
