import 'package:flutter/material.dart';
import 'package:f_demo/localization/zh_hans_strings.dart';
import 'package:f_demo/localization/en_strings.dart';

class Localization {
  static final Localization instance = Localization._();
  Localization._();

  Locale _currentLocale = const Locale('zh', 'Hans');
  final Map<Locale, Map<String, String>> _translations = {};

  Locale get currentLocale => _currentLocale;

  static const List<Locale> supportedLocales = [
    Locale('zh', 'Hans'),
    Locale('en'),
  ];

  void load(Locale locale) {
    _currentLocale = locale;
    _translations[const Locale('zh', 'Hans')] = zhHansStrings;
    _translations[const Locale('en')] = enStrings;
  }

  String translate(String key) {
    final translations = _translations[_currentLocale];
    if (translations == null) return key;
    return translations[key] ?? key;
  }

  Future<void> changeLocale(Locale locale) async {
    _currentLocale = locale;
  }
}