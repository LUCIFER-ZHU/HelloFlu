import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../config/app_config.dart';
import '../core/network/dio_client.dart';

/// API 服务类
///
/// 封装所有与后端 API 的交互
/// 使用 Dio 进行 HTTP 请求
/// 统一错误处理和日志记录
class ApiService {
  ApiService._();

  /// Logger 实例
  static final Logger _logger = Logger();

  /// 获取全球 COVID-19 统计数据
  ///
  /// 返回全球疫情数据的 Map
  /// 包含确诊、死亡、康复、活跃病例等信息
  ///
  /// 抛出 [DioException] 当网络请求失败时
  static Future<Map<String, dynamic>> getGlobalData() async {
    try {
      _logger.i('开始获取全球数据...');

      final response = await DioClient.dio.get(AppConfig.endpointGlobal);

      _logger.i('全球数据获取成功，数据量: ${response.data.length}');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      _logger.e('获取全球数据失败: $e');
      rethrow;
    }
  }

  /// 获取所有国家的 COVID-19 统计数据
  ///
  /// [sort] - 排序方式（默认按国家名称排序）
  /// 返回解析后的国家数据列表
  ///
  /// 抛出 [DioException] 当网络请求失败时
  static Future<List<dynamic>> getAllCountriesData({
    String sort = 'country',
  }) async {
    try {
      _logger.i('开始获取国家列表...');

      final response = await DioClient.dio.get(
        AppConfig.endpointCountries(sort: sort),
      );

      final countries = response.data as List<dynamic>;
      _logger.i('国家列表获取成功，数量: ${countries.length}');
      return countries;
    } catch (e) {
      _logger.e('获取国家列表失败: $e');
      rethrow;
    }
  }

  /// 获取特定国家的历史数据
  ///
  /// [country] - 国家名称（如 'China', 'USA'）
  /// 返回解析后的历史数据 Map，包含每日的确诊、死亡、康复数据
  ///
  /// 抛出 [DioException] 当网络请求失败时
  static Future<Map<String, dynamic>> getCountryHistoricalData(
    String country,
  ) async {
    try {
      _logger.i('开始获取 $country 的历史数据...');

      // URL 编码国家名称
      final encodedCountry = Uri.encodeComponent(country);
      final response = await DioClient.dio.get(
        AppConfig.endpointHistorical(encodedCountry),
      );

      _logger.i('$country 历史数据获取成功');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      _logger.e('获取 $country 历史数据失败: $e');
      rethrow;
    }
  }

  /// 获取单个国家的详细统计数据
  ///
  /// [country] - 国家名称
  /// 返回单个国家的详细数据 Map
  ///
  /// 抛出 [DioException] 当网络请求失败时
  static Future<Map<String, dynamic>> getCountryData(String country) async {
    try {
      _logger.i('开始获取 $country 的详细数据...');

      final response = await DioClient.dio.get(
        '/countries/$country',
      );

      _logger.i('$country 详细数据获取成功');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      _logger.e('获取 $country 详细数据失败: $e');
      rethrow;
    }
  }
}
