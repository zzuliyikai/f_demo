import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:f_demo/core/network/api_result.dart';
import 'package:f_demo/core/effect/app_effect.dart';
import 'base_state.dart';

abstract class BaseCubit<T extends BaseState> extends Cubit<T> {
  BaseCubit(super.initialState);

  T nextState() => state.copy() as T;

  // ── Loading 生命周期手动控制 ──

  void startLoading(String slot) => emit(nextState()..setLoadingSlot(slot, true));
  void stopLoading(String slot) => emit(nextState()..setLoadingSlot(slot, false));
  void startLoadingAll(List<String> slots) {
    final s = nextState();
    for (final slot in slots) {
      s.setLoadingSlot(slot, true);
    }
    emit(s);
  }
  void stopLoadingAll(List<String> slots) {
    final s = nextState();
    for (final slot in slots) {
      s.setLoadingSlot(slot, false);
    }
    emit(s);
  }

  // ── 请求执行（不自动切换 loading）──

  Future<Result<dynamic>> run(Future<Result<dynamic>> action) async {
    final result = await action;
    if (result is Failure) {
      emit(nextState()..effect = EffectErrorToast(result.reason));
    }
    return result;
  }

  // ── 流程级便利方法 ──

  Future<void> loadPageFlow({required Future<void> action}) async {
    emit(nextState()..isLoading = true);
    await action;
    emit(nextState()..isLoading = false);
  }

  Future<void> loadSlotsFlow({
    required List<String> slots,
    required Future<void> action,
  }) async {
    startLoadingAll(slots);
    await action;
    stopLoadingAll(slots);
  }

  // ── Overlay + 最少500ms防闪烁 ──

  Future<void> executeWithOverlay({
    required Future<Result<dynamic>> action,
    void Function(dynamic data)? onSuccess,
    String? onSuccessMsg,
  }) async {
    emit(nextState()..effect = EffectOverlayLoading());
    final startTime = DateTime.now();
    final result = await action;
    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    if (elapsed < 500) {
      await Future.delayed(Duration(milliseconds: 500 - elapsed));
    }
    if (result is Success) {
      final newState = nextState()..clearEffect();
      if (onSuccess != null) onSuccess(result.data);
      if (onSuccessMsg != null) {
        newState.effect = EffectSuccessToast(onSuccessMsg);
      }
      emit(newState);
    } else if (result is Failure) {
      emit(nextState()..effect = EffectErrorToast(result.reason));
    }
  }

  // ── Toast + 最少500ms防闪烁 ──

  Future<void> executeWithToast({
    required Future<Result<dynamic>> action,
    void Function(dynamic data)? onSuccess,
    String? onSuccessMsg,
  }) async {
    emit(nextState()..effect = EffectToastLoading());
    final startTime = DateTime.now();
    final result = await action;
    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    if (elapsed < 500) {
      await Future.delayed(Duration(milliseconds: 500 - elapsed));
    }
    if (result is Success) {
      final newState = nextState()..clearEffect();
      if (onSuccess != null) onSuccess(result.data);
      if (onSuccessMsg != null) {
        newState.effect = EffectSuccessToast(onSuccessMsg);
      }
      emit(newState);
    } else if (result is Failure) {
      emit(nextState()..effect = EffectErrorToast(result.reason));
    }
  }
}