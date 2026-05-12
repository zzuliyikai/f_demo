import 'package:nexoptim/business_modules/base_logic.dart';
import '../base_cubit.dart';
import '___feature_name___repo.dart';
import '___feature_name___state.dart';

class ___FeatureName___Cubit extends BaseCubit<___FeatureName___State> {
  final ___FeatureName___Repo _repo;

  ___FeatureName___Cubit(this._repo) : super(___FeatureName___State());

  /// 初始化
  Future<void> initialize(String id) async {
    emit(nextState()..isLoading = true);
    await loadData(id);
    emit(nextState()..isLoading = false);
  }

  /// 加载数据
  Future<void> loadData(String id) async {
    final result = await _repo.getData(id);
    if (result case Success(:final data)) {
      emit(nextState()..name = data['name'] ?? '');
    } else if (result case Failure(:final reason)) {
      emit(nextState()..effect = EffectErrorToast(reason));
    }
  }

  /// 刷新数据
  Future<void> refreshData() async {
    await loadData(state.id);
  }
}
