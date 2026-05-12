import 'package:shared_preferences/shared_preferences.dart';

class AppCache {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 通用 auth token
  String get authToken => _prefs.getString('auth_token') ?? '';
  Future<void> setAuthToken(String token) => _prefs.setString('auth_token', token);
  Future<void> clearAuth() => _prefs.remove('auth_token');

  // 服务专属 token
  String getToken(String service) => _prefs.getString('token_$service') ?? '';
  Future<void> setToken(String service, String token) => _prefs.setString('token_$service', token);
  Future<void> clearToken(String service) => _prefs.remove('token_$service');

  // Mock 模式切换
  bool get mockRepo => _prefs.getBool('mock_repo') ?? false;
  Future<void> setMockRepo(bool value) => _prefs.setBool('mock_repo', value);

  // 主题
  bool get isDarkMode => _prefs.getBool('is_dark_mode') ?? false;
  Future<void> setDarkMode(bool value) => _prefs.setBool('is_dark_mode', value);

  // 语言
  String get languageCode => _prefs.getString('language_code') ?? 'zh';
  Future<void> setLanguageCode(String code) => _prefs.setString('language_code', code);
}