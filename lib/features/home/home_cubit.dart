import 'package:f_demo/core/base/base_cubit.dart';
import 'package:f_demo/core/network/api_result.dart';
import 'home_repo.dart';
import 'home_state.dart';

class HomeCubit extends BaseCubit<HomeState> {
  final HomeRepo _repo;

  HomeCubit(this._repo) : super(HomeState());

  Future<void> initialize() async {
    await loadPageFlow(action: _loadData());
  }

  Future<void> _loadData() async {
    final result = await run(_repo.getHomeData());
    if (result is Success) {
      final data = result.data;
      if (data is Map<String, dynamic>) {
        emit(nextState()..title = data['title'] ?? '首页');
      }
    }
  }

  Future<void> refreshData() async {
    await executeWithToast(
      action: _repo.getHomeData(),
      onSuccessMsg: '数据已刷新',
    );
  }
}