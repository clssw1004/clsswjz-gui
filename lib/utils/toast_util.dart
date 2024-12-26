import 'package:flutter/material.dart';

class ToastUtil {
  static void showSuccess(String message) {
    _show(message, Colors.green);
  }

  static void showError(String message) {
    _show(message, Colors.red);
  }

  static void _show(String message, Color backgroundColor) {
    // TODO: 实现具体的Toast显示逻辑，可以使用第三方包如fluttertoast
    print(message);
  }
}
