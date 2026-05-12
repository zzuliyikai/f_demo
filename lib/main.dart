import 'package:flutter/material.dart';
import 'app.dart';
import 'core/di/injection.dart';
import 'core/storage/app_cache.dart';
import 'core/localization/localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  await getIt<AppCache>().init();
  Localization.instance.load(Locale(getIt<AppCache>().languageCode, 'Hans'));
  runApp(const FDemoApp());
}