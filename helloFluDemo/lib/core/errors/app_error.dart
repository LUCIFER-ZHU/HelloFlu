import 'package:dio/dio.dart';

/// 应用错误基类
///
/// 所有自定义错误类型都继承此类
/// 提供统一的错误消息和错误类型标识
sealed class AppError implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  AppError(this.message, {this.code, this.originalError});

  @override
  String toString() => '[$runtimeType] $message';
}

/// 网络连接错误
///
/// 当设备无网络连接或无法连接到服务器时抛出
class NetworkError extends AppError {
  NetworkError({String? message, dynamic originalError})
      : super(
          message ?? '网络连接失败，请检查网络设置',
          code: 'NETWORK_ERROR',
          originalError: originalError,
        );
}

/// 服务器错误
///
/// 当服务器返回 5xx 状态码时抛出
class ServerError extends AppError {
  final int statusCode;

  ServerError(this.statusCode, {String? message, dynamic originalError})
      : super(
          message ?? '服务器错误 (代码: $statusCode)',
          code: 'SERVER_ERROR_$statusCode',
          originalError: originalError,
        );
}

/// 客户端错误
///
/// 当服务器返回 4xx 状态码时抛出（如 404, 401, 403 等）
class ClientError extends AppError {
  final int statusCode;

  ClientError(this.statusCode, {String? message, dynamic originalError})
      : super(
          message ?? _getDefaultMessage(statusCode),
          code: 'CLIENT_ERROR_$statusCode',
          originalError: originalError,
        );

  static String _getDefaultMessage(int code) {
    switch (code) {
      case 400:
        return '请求参数错误';
      case 401:
        return '未授权，请重新登录';
      case 403:
        return '访问被拒绝';
      case 404:
        return '请求的资源不存在';
      case 429:
        return '请求过于频繁，请稍后再试';
      default:
        return '请求错误 (代码: $code)';
    }
  }
}

/// 超时错误
///
/// 当请求超时（连接超时或接收超时）时抛出
class TimeoutError extends AppError {
  final Duration? duration;

  TimeoutError({this.duration, String? message, dynamic originalError})
      : super(
          message ?? '请求超时，请稍后重试',
          code: 'TIMEOUT_ERROR',
          originalError: originalError,
        );
}

/// 缓存错误
///
/// 当缓存读取或写入失败时抛出
class CacheError extends AppError {
  CacheError({String? message, dynamic originalError})
      : super(
          message ?? '缓存操作失败',
          code: 'CACHE_ERROR',
          originalError: originalError,
        );
}

/// 数据解析错误
///
/// 当 API 返回的数据格式不符合预期时抛出
class DataParseError extends AppError {
  DataParseError({String? message, dynamic originalError})
      : super(
          message ?? '数据解析失败',
          code: 'PARSE_ERROR',
          originalError: originalError,
        );
}

/// 未知错误
///
/// 当发生未预期的错误时抛出
class UnknownError extends AppError {
  UnknownError({String? message, dynamic originalError})
      : super(
          message ?? '发生未知错误，请稍后重试',
          code: 'UNKNOWN_ERROR',
          originalError: originalError,
        );
}

/// 错误处理工具类
///
/// 提供统一的错误转换和处理方法
class ErrorHandler {
  ErrorHandler._();

  /// 将 DioException 转换为 AppError
  static AppError handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutError(
          originalError: error,
        );

      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') == true) {
          return NetworkError(originalError: error);
        }
        return UnknownError(originalError: error);

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode != null) {
          if (statusCode >= 500) {
            return ServerError(statusCode, originalError: error);
          } else if (statusCode >= 400) {
            return ClientError(statusCode, originalError: error);
          }
        }
        return UnknownError(originalError: error);

      case DioExceptionType.cancel:
        return UnknownError(
          message: '请求已取消',
          originalError: error,
        );

      case DioExceptionType.badCertificate:
        return NetworkError(
          message: '证书验证失败',
          originalError: error,
        );
    }
  }

  /// 将任意异常转换为 AppError
  static AppError handleError(dynamic error) {
    if (error is AppError) {
      return error;
    }

    if (error is DioException) {
      return handleDioError(error);
    }

    if (error is FormatException) {
      return DataParseError(originalError: error);
    }

    return UnknownError(originalError: error);
  }

  /// 获取用户友好的错误消息
  static String getUserFriendlyMessage(AppError error) {
    return error.message;
  }

  /// 判断错误是否可以重试
  static bool isRetryable(AppError error) {
    return error is NetworkError ||
        error is TimeoutError ||
        (error is ServerError && error.statusCode >= 500);
  }
}
