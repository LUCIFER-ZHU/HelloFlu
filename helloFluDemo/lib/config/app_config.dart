import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 应用配置类
///
/// 存储应用级别的配置信息
/// 包括 API 地址、超时时间、默认国家等
/// 从环境变量读取配置，支持开发/生产环境切换
///
/// Web 对比：类似前端项目的环境变量配置（.env 文件）
class AppConfig {
  /// 私有构造函数，防止实例化
  AppConfig._();

  // ===== API 配置 =====

  /// API 基础 URL（从环境变量读取）
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://disease.sh/v3/covid-19';

  /// 全球数据端点
  static String get endpointGlobal => '$apiBaseUrl$globalDataEndpoint';

  /// 国家列表端点
  static String endpointCountries({String sort = 'country'}) =>
      '$apiBaseUrl$countriesEndpoint?sort=$sort';

  /// 国家历史数据端点
  static String endpointHistorical(String country) =>
      '$apiBaseUrl/countries/$country';

  /// 国家数据端点
  static const String globalDataEndpoint = '/all';

  /// 国家列表端点
  static const String countriesEndpoint = '/countries';

  /// 国家历史数据端点模板
  static String countryHistoricalEndpoint(String country) => '/historical/$country';

  /// 国家详情端点模板
  static String countryDetailEndpoint(String country) => '/countries/$country';

  // ===== 网络配置 =====

  /// 连接超时时间（毫秒）
  static const int connectTimeout = 15000;

  /// 接收超时时间（毫秒）
  static const int receiveTimeout = 15000;

  /// 发送超时时间（毫秒）
  static const int sendTimeout = 15000;

  // ===== 应用配置 =====

  /// 默认国家
  static const String defaultCountry = 'China';

  /// 应用名称
  static const String appName = 'COVID-19 追踪器';

  /// 应用版本
  static const String appVersion = '1.0.0';

  // ===== UI 配置 =====

  /// 主题配置
  static ThemeData get darkTheme => ThemeData(
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
          secondary: Color(0xfff4796b),
        ),
      );

  // ===== 调试配置 =====

  /// 当前环境（从环境变量读取）
  static String get environment =>
      dotenv.env['ENVIRONMENT'] ?? 'development';

  /// 是否为开发环境
  static bool get isDevelopment => environment == 'development';

  /// 是否为生产环境
  static bool get isProduction => environment == 'production';

  /// 是否显示调试信息（从环境变量读取）
  static bool get debugMode {
    final enableDebug = dotenv.env['ENABLE_DEBUG'];
    if (enableDebug != null) return isDevelopment;
    return enableDebug!.toLowerCase() == 'true';
  }

  /// 是否启用日志（从环境变量读取）
  static bool get enableLogging {
    final enableLog = dotenv.env['ENABLE_LOGGING'];
    if (enableLog != null) return isDevelopment;
    return enableLog!.toLowerCase() == 'true';
  }

  // ===== 数据缓存配置 =====

  /// 缓存过期时间（分钟，从环境变量读取）
  static int get cacheExpirationMinutes {
    final duration = dotenv.env['CACHE_DURATION_MINUTES'];
    if (duration == null) return 30;
    return int.tryParse(duration) ?? 30;
  }

  /// 是否启用缓存
  static const bool enableCache = true;
}
