import '../../core/base/base_state.dart';

class HomeState extends BaseState {
  String title = '';

  @override
  HomeState copy() => HomeState()
    ..title = title
    ..isLoading = isLoading
    ..effect = effect;
}