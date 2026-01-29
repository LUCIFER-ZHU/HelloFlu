import 'package:dio/dio.dart';
import '../../config/app_config.dart';

/// Dio 网络客户端配置
///
/// 提供 Dio 实例的统一配置和管理
/// 包含拦截器、超时配置等
///
/// Web 对比：类似 axios.create() 配置
class DioClient {
  /// Dio 实例
  static Dio? _dio;

  /// 私有构造函数，防止实例化
  DioClient._();

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

    // 添加拦截器
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // 请求前处理
        print('请求: ${options.method} ${options.uri}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // 响应处理
        print('响应: ${response.statusCode} ${response.requestOptions.uri}');
        return handler.next(response);
      },
      onError: (DioException error, handler) {
        // 错误处理
        print('错误: ${error.message}');
        return handler.next(error);
      },
    ));

    return dio;
  }

  /// 初始化 Dio 客户端（预加载）
  static void init() {
    // 访问 dio getter 会自动初始化
    dio;
  }

  /// 关闭 Dio 客户端
  static void close() {
    _dio?.close(force: true);
    _dio = null;
  }
}
