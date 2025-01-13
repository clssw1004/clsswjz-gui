import 'package:flutter/material.dart';
import '../main.dart';

class ToastUtil {
  static void showSuccess(String message) {
    _show(message, Colors.green);
  }

  static void showError(String message) {
    _show(message, Colors.red);
  }

  static void showInfo(String message) {
    _show(message, Colors.blue);
  }

  static void showWarning(String message) {
    _show(message, Colors.orange);
  }

  static void _show(String message, Color backgroundColor) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }
}
