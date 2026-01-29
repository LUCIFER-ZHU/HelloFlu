import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/country_list.dart';
import '../screens/global_stats.dart';
import '../services/api_service.dart';
import '../notifiers/country_list_notifier.dart';
import '../notifiers/global_stats_notifier.dart';

/// ===== 应用配置 Providers =====

/// 应用主题 Provider
final themeProvider = Provider<ThemeData>((ref) {
  return ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E1E1E),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFFFFFFF)),
      bodyMedium: TextStyle(color: Color(0xFFFFFFFF)),
      bodySmall: TextStyle(color: Color(0xFFFFFFFF)),
      titleLarge: TextStyle(color: Color(0xFFFFFFFF), fontSize: 24),
      titleMedium: TextStyle(color: Color(0xFFFFFFFF)),
      titleSmall: TextStyle(color: Color(0xFFFFFFFF)),
    ),
    colorScheme: ColorScheme.dark(
      primary: Colors.blue,
      secondary: const Color(0xfff4796b),
    ),
  );
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
final loggerProvider = Provider<Logger>((ref) {
  return Logger(
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

/// ===== API 相关 Providers =====

/// API 服务 Provider（仅引用）
final apiServiceProvider = Provider<void>((ref) {
  return;
});

/// ===== 状态管理 Providers =====

/// 全球统计数据 Provider
final globalStatsProvider =
    StateNotifierProvider<GlobalStatsNotifier, AsyncValue<Map<String, dynamic>>>(
  (ref) {
    final logger = ref.watch(loggerProvider);
    return GlobalStatsNotifier(logger);
  },
);

/// 国家列表数据 Provider
final countriesProvider =
    StateNotifierProvider<CountryListNotifier, AsyncValue<List<dynamic>>>(
  (ref) {
    final logger = ref.watch(loggerProvider);
    return CountryListNotifier(logger);
  },
);

/// 国家历史数据 Provider
final historicalDataProvider =
    FutureProvider.family<Map<String, dynamic>, String>(
  (ref, country) {
    final logger = ref.watch(loggerProvider);
    logger.i('加载历史数据: $country');
    return ApiService.getCountryHistoricalData(country);
  },
);

/// 国家详细数据 Provider
final countryDataProvider =
    FutureProvider.family<Map<String, dynamic>, String>(
  (ref, country) {
    final logger = ref.watch(loggerProvider);
    logger.i('加载国家详情: $country');
    return ApiService.getCountryData(country);
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
