import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';
import '../config/app_config.dart';
import '../repositories/covid_repository.dart';
import '../screens/global_stats.dart';
import '../screens/country_list.dart';

part 'router.g.dart';

/// Logger Provider（Generated）
@riverpod
Logger logger(Ref ref) {
  final isLoggingEnabled = AppConfig.enableLogging;

  return Logger(
    level: isLoggingEnabled ? Level.trace : Level.off,
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );
}

/// CovidRepository Provider（Generated）
@riverpod
CovidRepository covidRepository(Ref ref) {
  return CovidRepositoryImpl(ref.read(loggerProvider));
}

/// 主题 Provider（Generated）
@riverpod
ThemeData theme(Ref ref) {
  return AppConfig.darkTheme;
}

/// 默认国家 Provider（Generated）
@riverpod
String defaultCountry(Ref ref) {
  return 'China';
}

/// 路由配置 Provider（Generated）
@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const GlobalStatsScreen(),
      ),
      GoRoute(
        path: '/global-stats',
        name: 'globalStats',
        builder: (context, state) => const GlobalStatsScreen(),
      ),
      GoRoute(
        path: '/countries',
        name: 'countries',
        builder: (context, state) => const CountryListScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              '页面不存在: ${state.uri}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    ),
  );
}
