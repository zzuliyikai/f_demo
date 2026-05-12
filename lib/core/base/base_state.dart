import '../effect/app_effect.dart';

abstract class BaseState {
  bool isLoading = false;
  final Map<String, bool> _loadingSlots = {};
  Effect? effect;

  BaseState copy();

  bool isLoadingSlot(String key) => _loadingSlots[key] ?? false;
  void setLoadingSlot(String key, bool value) => _loadingSlots[key] = value;
  bool get isAnyLoading => isLoading || _loadingSlots.values.any((v) => v);

  void clearEffect() => effect = null;
}