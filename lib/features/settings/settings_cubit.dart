import 'package:flutter/material.dart';
import 'package:f_demo/core/base/base_cubit.dart';
import 'package:f_demo/core/localization/localization.dart';
import 'package:f_demo/core/localization/string_extension.dart';
import 'package:f_demo/core/storage/app_cache.dart';
import 'package:f_demo/core/di/injection.dart';
import 'settings_repo.dart';
import 'settings_state.dart';

class SettingsCubit extends BaseCubit<SettingsState> {
  final SettingsRepo _repo;

  SettingsCubit(this._repo) : super(SettingsState());

  void initFromCache() {
    final appCache = getIt<AppCache>();
    emit(nextState()
      ..currentLanguage = appCache.languageCode
      ..isDarkMode = appCache.isDarkMode);
  }

  Future<void> toggleDarkMode() async {
    final newValue = !state.isDarkMode;
    await executeWithOverlay(
      action: _repo.toggleDarkMode(newValue),
      onSuccess: (_) async {
        await getIt<AppCache>().setDarkMode(newValue);
        emit(nextState()..isDarkMode = newValue);
      },
      onSuccessMsg: newValue ? '深色模式'.t : '浅色模式'.t,
    );
  }

  Future<void> changeLanguage(String code) async {
    await executeWithOverlay(
      action: _repo.changeLanguage(code),
      onSuccess: (_) async {
        final locale = code == 'zh' ? const Locale('zh', 'Hans') : const Locale('en');
        await Localization.instance.changeLocale(locale);
        await getIt<AppCache>().setLanguageCode(code);
        emit(nextState()..currentLanguage = code);
      },
      onSuccessMsg: '语言'.t,
    );
  }
}