import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:f_demo/core/network/api_result.dart';
import 'package:f_demo/core/effect/app_effect.dart';
import 'base_state.dart';

/// BaseCubit — 所有业务 Cubit 的基类，提供流程级 loading 控制与 Effect 发射。
///
/// 核心理念：loading 生命周期在「流程」层面控制，不在「请求」层面。
/// 这样可以避免多个请求串行时 loading 闪烁（出现→消失→出现→消失）。
///
/// 与 BaseState 配合使用：
/// - isLoading / _loadingSlots 用于 UI 层判断是否展示加载态
/// - effect 用于 UI 层一次性反馈（Toast/Overlay/Dialog/导航）
abstract class BaseCubit<T extends BaseState> extends Cubit<T> {
  BaseCubit(super.initialState);

  /// 基于当前 state 生成下一个 state（mutable copy 模式）。
  /// 所有 emit 前都必须通过 nextState() 拿到新实例，避免直接修改旧 state。
  T nextState() => state.copy() as T;

  // ═══════════════════════════════════════════════════════════════════
  // ── Loading Slot 手动控制 ──
  //
  // 适用场景：一个页面有多个独立区域同时/分别加载，
  // 例如「用户信息」和「订单列表」两个接口并行请求，
  // 各自用 slot='user' 和 slot='orders' 标记，
  // UI 通过 state.isLoadingSlot('user') / isLoadingSlot('orders')
  // 分别控制两个区域的 loading 状态。
  //
  // 也可以配合 loadSlotsFlow 自动管理生命周期。
  // ═══════════════════════════════════════════════════════════════════

  /// 标记单个 slot 为加载中。
  /// emit 后 UI 可用 state.isLoadingSlot('user') 判断该区域是否展示 loading。
  ///
  /// 示例：
  ///   startLoading('user');    // 用户信息区域开始加载
  ///   await fetchUser();
  ///   stopLoading('user');     // 用户信息区域加载完成
  void startLoading(String slot) => emit(nextState()..setLoadingSlot(slot, true));

  /// 标记单个 slot 加载完成。
  void stopLoading(String slot) => emit(nextState()..setLoadingSlot(slot, false));

  /// 批量标记多个 slot 为加载中。
  /// 适用场景：页面初始化时同时请求多个接口，需要同时锁定多个区域。
  ///
  /// 示例：
  ///   startLoadingAll(['user', 'orders', 'stats']);
  void startLoadingAll(List<String> slots) {
    final s = nextState();
    for (final slot in slots) {
      s.setLoadingSlot(slot, true);
    }
    emit(s);
  }

  /// 批量标记多个 slot 加载完成。
  void stopLoadingAll(List<String> slots) {
    final s = nextState();
    for (final slot in slots) {
      s.setLoadingSlot(slot, false);
    }
    emit(s);
  }

  // ═══════════════════════════════════════════════════════════════════
  // ── run — 执行请求，不切换 loading，仅处理错误 ──
  //
  // 适用场景：请求不需要 UI loading 反馈（后台静默请求），
  // 或 loading 已由外层流程方法（loadPageFlow 等）管理。
  //
  // 行为：如果 Result 是 Failure，自动发射 EffectErrorToast 显示错误提示；
  //       如果 Result 是 Success，不做任何 UI 反馈，返回结果由调用方处理。
  // ═══════════════════════════════════════════════════════════════════

  /// 执行一个返回 Result 的异步请求，失败时自动发射 ErrorToast。
  /// 不会切换任何 loading 状态。
  ///
  /// 示例（静默刷新，不需要 loading）：
  ///   final result = await run(_repo.getHomeData());
  ///   if (result is Success) { ... 处理数据 ... }
  ///
  /// 示例（配合 loadPageFlow，loading 由流程管理）：
  ///   await loadPageFlow(action: _loadData());  // isLoading 由流程控制
  ///   // _loadData 内部：
  ///   Future<void> _loadData() async {
  ///     final result = await run(_repo.getHomeData());  // 不重复管理 loading
  ///     if (result is Success) { emit(nextState()..title = result.data['title']); }
  ///   }
  Future<Result<dynamic>> run(Future<Result<dynamic>> action) async {
    final result = await action;
    if (result is Failure) {
      emit(nextState()..effect = EffectErrorToast(result.reason));
    }
    return result;
  }

  // ═══════════════════════════════════════════════════════════════════
  // ── 流程级便利方法 ──
  //
  // 这些方法在「流程」层面自动管理 loading 的开始和结束，
  // 保证 loading 生命周期与整个流程绑定，而非与单个请求绑定。
  // 这样避免了：请求1开始loading → 请求1结束loading消失 →
  //           请求2开始loading → 请求2结束loading消失 的闪烁问题。
  // ═══════════════════════════════════════════════════════════════════

  /// 页面级加载流程：isLoading = true → 执行 action → isLoading = false。
  ///
  /// 适用场景：页面首次加载（整个页面显示 loading 挡板，数据回来后替换为内容）。
  /// UI 通过 state.isLoading 判断是否展示全页 LoadingWidget。
  ///
  /// 示例：
  ///   Future<void> initialize() async {
  ///     await loadPageFlow(action: _loadData());
  ///   }
  ///   // 页面从空白 → loading 挡板 → 数据内容，一气呵成
  ///
  /// 注意：action 参数是 Future<void>（无返回值的异步操作），
  /// 数据处理在 action 内部完成，通常配合 run() 使用。
  Future<void> loadPageFlow({required Future<void> action}) async {
    emit(nextState()..isLoading = true);
    await action;
    emit(nextState()..isLoading = false);
  }

  /// 多区域加载流程：标记多个 slot → 执行 action → 清除所有 slot。
  ///
  /// 适用场景：页面有多个独立区域同时加载，但不像 loadPageFlow 那样
  /// 用全页 loading 挡板，而是各区域独立显示各自的 loading 状态。
  ///
  /// 示例（三个区域并行请求）：
  ///   await loadSlotsFlow(
  ///     slots: ['user', 'orders', 'stats'],
  ///     action: _loadAllData(),
  ///   );
  ///   // _loadAllData 内部用 Future.wait 并行请求，run() 不切换 loading
  ///   // 整个流程完成后，三个 slot 同时清零
  ///
  /// 对比手动管理：
  ///   startLoadingAll(slots); await action; stopLoadingAll(slots);
  ///   → loadSlotsFlow 就是这句的封装
  Future<void> loadSlotsFlow({
    required List<String> slots,
    required Future<void> action,
  }) async {
    startLoadingAll(slots);
    await action;
    stopLoadingAll(slots);
  }

  // ═══════════════════════════════════════════════════════════════════
  // ── Overlay 流程 — 全屏遮罩 Loading（关键操作防误触）──
  //
  // 适用场景：提交/确认/支付等关键操作，需要全屏遮罩 + 防重复点击。
  // EffectOverlayLoading 通过 EffectHandler → LoadingOverlay.show()
  // 在页面顶部叠一个半透明遮罩 + 居中转圈。
  //
  // 特性：
  // - 最少显示 500ms（防快速请求闪烁：请求100ms就成功了，
  //   但 overlay 刚出现就消失会让用户怀疑是不是没点到）
  // - 成功时可发射 SuccessToast 提示
  // - 失败时自动发射 ErrorToast
  // - onSuccess 回调在成功后执行，用于处理业务逻辑（如更新 state）
  // ═══════════════════════════════════════════════════════════════════

  /// 全屏 Overlay + 请求执行 + 最少500ms防闪烁。
  ///
  /// 流程：
  ///   1. 发射 EffectOverlayLoading（UI 显示全屏遮罩）
  ///   2. 等待 action 完成
  ///   3. 如果耗时 < 500ms，补足到 500ms（防闪烁）
  ///   4. 成功 → 清除 effect → 执行 onSuccess → 可选发射 SuccessToast
  ///   5. 失败 → 发射 EffectErrorToast
  ///
  /// 示例（提交表单）：
  ///   await executeWithOverlay(
  ///     action: _repo.submitForm(data),
  ///     onSuccess: (_) {
  ///       emit(nextState()..formData = null);  // 清空表单
  ///       context.read<SomeCubit>().refresh();  // 刷新关联数据
  ///     },
  ///     onSuccessMsg: '提交成功',
  ///   );
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

  // ═══════════════════════════════════════════════════════════════════
  // ── Toast 流程 — 顶部滑入提示条 Loading ──
  //
  // 适用场景：下拉刷新、轻量操作等不需要全屏遮罩的场景。
  // EffectToastLoading 通过 EffectHandler → ToastHandler.showWaitMsg()
  // 在页面顶部滑入一条半透明提示条（带转圈图标）。
  //
  // 特性与 executeWithOverlay 完全一致：
  // - 最少显示 500ms 防闪烁
  // - 成功 → SuccessToast / 失败 → ErrorToast
  // - onSuccess 回调
  //
  // 与 Overlay 的区别：Toast 不遮挡页面主要内容，
  // 只在顶部占一小条空间，用户可以继续浏览页面。
  // ═══════════════════════════════════════════════════════════════════

  /// 顶部 Toast Loading + 请求执行 + 最少500ms防闪烁。
  ///
  /// 流程与 executeWithOverlay 完全一致，只是 UI 表现不同：
  ///   - Overlay = 全屏遮罩（防误触）
  ///   - Toast = 顶部滑入条（轻量提示，不遮挡内容）
  ///
  /// 示例（下拉刷新）：
  ///   await executeWithToast(
  ///     action: _repo.getHomeData(),
  ///     onSuccessMsg: '数据已刷新',
  ///   );
  ///
  /// 示例（轻量操作 + 成功回调）：
  ///   await executeWithToast(
  ///     action: _repo.toggleLike(id),
  ///     onSuccess: (data) {
  ///       emit(nextState()..isLiked = data['liked']);
  ///     },
  ///     onSuccessMsg: '操作成功',
  ///   );
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