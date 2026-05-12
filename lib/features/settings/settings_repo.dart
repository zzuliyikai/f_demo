import 'package:f_demo/core/network/api_result.dart';

abstract class SettingsRepo {
  Future<Result<dynamic>> toggleDarkMode(bool isDark);
  Future<Result<dynamic>> changeLanguage(String code);
}

class SettingsRepoImpl implements SettingsRepo {
  @override
  Future<Result<dynamic>> toggleDarkMode(bool isDark) async => Success(isDark);

  @override
  Future<Result<dynamic>> changeLanguage(String code) async => Success(true);
}

class MockSettingsRepo implements SettingsRepo {
  @override
  Future<Result<dynamic>> toggleDarkMode(bool isDark) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return Success(isDark);
  }

  @override
  Future<Result<dynamic>> changeLanguage(String code) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return Success(true);
  }
}