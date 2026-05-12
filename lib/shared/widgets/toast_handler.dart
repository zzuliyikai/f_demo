import 'package:flutter/material.dart';

class ToastHandler {
  static OverlayEntry? _entry;

  static void showWaitMsg() {
    // TODO: 实现顶部 Toast 样式 loading 提示
  }

  static void showMsgWithErrorIcon(String msg) {
    // TODO: 实现错误 Toast
  }

  static void showMsgWithSuccessIcon(String msg) {
    // TODO: 实现成功 Toast
  }

  static Future<void> dismissMsg() async {
    _entry?.remove();
    _entry = null;
  }
}