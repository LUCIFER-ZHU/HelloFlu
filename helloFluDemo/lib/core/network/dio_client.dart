import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../config/app_config.dart';

/// Dio 网络客户端配置
///
/// 提供 Dio 实例的统一配置和管理
/// 包含拦截器、超时配置等
/// 使用 Logger 进行日志记录，支持日志级别控制
///
/// Web 对比：类似 axios.create() 配置
class DioClient {
  /// Dio 实例
  static Dio? _dio;

  /// Logger 实例（可选，如果为null则不记录日志）
  static Logger? _logger;

  /// 私有构造函数，防止实例化
  DioClient._();

  /// 配置 Logger（应在应用启动时调用一次）
  ///
  /// [logger] - Logger 实例，如果为null则不记录网络日志
  static void configure(Logger? logger) {
    _logger = logger;
  }

  /// 获取 Dio 实例（单例模式）
  static Dio get dio {
    _dio ??= _createDioInstance();
    return _dio!;
  }

  /// 创建并配置 Dio 实例
  static Dio _createDioInstance() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: Duration(milliseconds: AppConfig.connectTimeout),
        receiveTimeout: Duration(milliseconds: AppConfig.receiveTimeout),
        sendTimeout: Duration(milliseconds: AppConfig.sendTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // 添加拦截器（仅在配置了logger时添加日志拦截器）
    if (_logger != null) {
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger?.d('➡️ Request: ${options.method} ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger?.i(
            '✅ Response: ${response.statusCode} ${response.requestOptions.uri}',
          );
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          _logger?.e(
            '❌ Error: ${error.message}',
            error: error,
            stackTrace: error.stackTrace,
          );
          return handler.next(error);
        },
      ));
    }

    return dio;
  }

  /// 初始化 Dio 客户端（预加载）
  ///
  /// [logger] - 可选的 Logger 实例
  static void init({Logger? logger}) {
    if (logger != null) {
      _logger = logger;
    }
    // 访问 dio getter 会自动初始化
    dio;
  }

  /// 关闭 Dio 客户端
  static void close() {
    _dio?.close(force: true);
    _dio = null;
    _logger = null;
  }
}
