import 'package:flutter/material.dart';

sealed class Effect {}

class EffectPageLoading extends Effect {}
class EffectOverlayLoading extends Effect {}
class EffectToastLoading extends Effect {}

class EffectErrorToast<T> extends Effect {
  final T value;
  EffectErrorToast(this.value);
}
class EffectSuccessToast<T> extends Effect {
  final T value;
  EffectSuccessToast(this.value);
}

class EffectNavigate extends Effect {
  final String route;
  final Object? extra;
  EffectNavigate(this.route, {this.extra});
}
class EffectDialog extends Effect {
  final Widget dialog;
  EffectDialog(this.dialog);
}