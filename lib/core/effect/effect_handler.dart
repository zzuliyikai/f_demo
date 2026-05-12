import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:f_demo/core/effect/app_effect.dart';
import 'package:f_demo/shared/widgets/loading_overlay.dart';
import 'package:f_demo/shared/widgets/toast_handler.dart';

class EffectHandler {
  static Future<void> handleEffect(BuildContext context, Effect? effect) async {
    if (effect == null) return;

    // 先 dismiss 之前的 loading
    if (effect is! EffectPageLoading) {
      await LoadingOverlay.dismiss();
      await ToastHandler.dismissMsg();
    }

    switch (effect) {
      case EffectPageLoading():
        break;
      case EffectOverlayLoading():
        LoadingOverlay.show(context);
      case EffectToastLoading():
        ToastHandler.showWaitMsg();
      case EffectErrorToast(:final value):
        ToastHandler.showMsgWithErrorIcon(value.toString());
      case EffectSuccessToast(:final value):
        ToastHandler.showMsgWithSuccessIcon(value.toString());
      case EffectNavigate(:final route, :final extra):
        context.push(route, extra: extra);
      case EffectDialog(:final dialog):
        showDialog(context: context, builder: (_) => dialog);
    }
  }
}