import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/country_list.dart';
import '../screens/global_stats.dart';
import '../notifiers/country_list_notifier.dart';
import '../notifiers/global_stats_notifier.dart';
import '../repositories/covid_repository.dart';
import '../config/app_config.dart';

// ===== 配置 Providers =====

/// 主题 Provider
final themeProvider = Provider<ThemeData>((ref) {
  return AppConfig.darkTheme;
});

// ===== 仓库 Providers =====
/// CovidRepository Provider
/// 提供 COVID-19 数据仓库接口的 Provider
/// 所有数据访问都通过此 Provider 进行
final covidRepositoryProvider = Provider<CovidRepository>((ref) {
  final logger = ref.watch(loggerProvider);
  return CovidRepositoryImpl(logger);
});

/// 默认国家名称 Provider
final defaultCountryProvider = Provider<String>((ref) {
  return 'China';
});

/// 当前语言 Provider
final localeProvider = Provider<Locale>((ref) {
  return const Locale('zh', 'CN');
});

/// ===== 服务 Providers（Riverpod 依赖注入） =====

/// Logger Provider
/// 根据环境变量 ENABLE_LOGGING 配置决定是否启用日志
final loggerProvider = Provider<Logger>((ref) {
  final isLoggingEnabled = AppConfig.enableLogging;

    return Logger(
    // 根据配置设置日志级别，生产环境可禁用日志
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
});

/// SharedPreferences Provider（用于其他地方需要访问 SharedPreferences 的场景）
final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

/// ===== 状态管理 Providers =====

/// 全球统计数据 Provider
final globalStatsProvider =
    StateNotifierProvider<GlobalStatsNotifier, AsyncValue<Map<String, dynamic>>>(
  (ref) {
    final repository = ref.watch(covidRepositoryProvider);
    final logger = ref.watch(loggerProvider);
    return GlobalStatsNotifier(repository, logger);
  },
);

/// 国家列表数据 Provider
final countriesProvider =
    StateNotifierProvider<CountryListNotifier, AsyncValue<List<dynamic>>>(
  (ref) {
    final repository = ref.watch(covidRepositoryProvider);
    final logger = ref.watch(loggerProvider);
    return CountryListNotifier(repository, logger);
  },
);

/// 国家历史数据 Provider
/// 使用 Repository 层获取数据，不再直接调用 ApiService
final historicalDataProvider =
    FutureProvider.family<Map<String, dynamic>, String>(
  (ref, country) async {
    final repository = ref.watch(covidRepositoryProvider);
    final logger = ref.watch(loggerProvider);
    logger.i('加载历史数据: $country');
    return repository.getHistoricalData(country);
  },
);

/// 国家详细数据 Provider
/// 使用 Repository 层获取数据，不再直接调用 ApiService
final countryDataProvider =
    FutureProvider.family<Map<String, dynamic>, String>(
  (ref, country) async {
    final repository = ref.watch(covidRepositoryProvider);
    final logger = ref.watch(loggerProvider);
    logger.i('加载国家详情: $country');
    return repository.getCountryData(country);
  },
);

/// 路由配置 Provider
///
/// 提供路由配置
/// Web 对比：类似 React Router 配置
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      // 主页
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const GlobalStatsScreen(),
      ),

      // 全球统计页面
      GoRoute(
        path: '/global-stats',
        name: 'globalStats',
        builder: (context, state) => const GlobalStatsScreen(),
      ),

      // 国家列表页面
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
});
