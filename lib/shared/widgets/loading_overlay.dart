import 'package:flutter/material.dart';

class LoadingOverlay {
  static OverlayEntry? _entry;

  static void show(BuildContext context) {
    _entry = OverlayEntry(builder: (_) => const _LoadingMask());
    Overlay.of(context).insert(_entry!);
  }

  static Future<void> dismiss() async {
    _entry?.remove();
    _entry = null;
  }
}

class _LoadingMask extends StatelessWidget {
  const _LoadingMask();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: const Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}