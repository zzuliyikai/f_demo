import '../../core/base/base_state.dart';

class SettingsState extends BaseState {
  String currentLanguage = 'zh';
  bool isDarkMode = false;

  @override
  SettingsState copy() => SettingsState()
    ..currentLanguage = currentLanguage
    ..isDarkMode = isDarkMode
    ..isLoading = isLoading
    ..effect = effect;
}