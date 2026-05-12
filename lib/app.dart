import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/di/injection.dart';
import 'core/localization/localization.dart';
import 'core/router/app_router.dart';
import 'core/storage/app_cache.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_repo.dart';
import 'features/settings/settings_repo.dart';

class FDemoApp extends StatelessWidget {
  const FDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appCache = getIt<AppCache>();
    return MultiRepositoryProvider(
      providers: _allRepoProviders(appCache),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: Localization.supportedLocales,
        locale: Localization.instance.currentLocale,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: appCache.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        routerConfig: appRouter,
      ),
    );
  }

  List<RepositoryProvider> _allRepoProviders(AppCache appCache) {
    T getRepo<T>(T mock, T real) => appCache.mockRepo ? mock : real;

    return [
      RepositoryProvider<HomeRepo>(
        create: (context) => getRepo(MockHomeRepo(), HomeRepoImpl()),
      ),
      RepositoryProvider<SettingsRepo>(
        create: (context) => getRepo(MockSettingsRepo(), SettingsRepoImpl()),
      ),
    ];
  }
}