import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import 'package:dio/dio.dart';
import '../core/network/dio_client.dart';

import '../config/app_config.dart';
import 'covid_repository.dart';

/// COVID-19 数据仓库实现类
///
/// 负责调用 API 并返回数据
/// 使用 DioClient 单例进行网络请求
/// 使用 Logger 记录操作日志
class CovidRepositoryImpl implements CovidRepository {
  /// Logger 实例
  final Logger _logger;

  /// 构造函数（私有）
  CovidRepositoryImpl(this._logger);

  /// 获取全球COVID-19统计数据
  ///
  /// 调用 API 并返回全球数据
  /// [endpoint] - API 端点
  @override
  Future<Map<String, dynamic>> getGlobalData() async {
    _logger.i('开始获取全球数据');
    try {
      final response = await DioClient.dio.get(AppConfig.endpointGlobal);
      _logger.i('全球数据获取成功，数据量: ${response.data.length}');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _logger.e('获取全球数据失败: $e');
      rethrow;
    }
  }

  /// 获取所有国家列表数据
  ///
  /// 调用 API 并返回国家列表
  @override
  Future<List<dynamic>> getAllCountries() async {
    _logger.i('开始获取国家列表');
    try {
      final response = await DioClient.dio.get(AppConfig.endpointAllCountries);
      _logger.i('国家列表获取成功');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      _logger.e('获取国家列表失败: $e');
      rethrow;
    }
  }

  /// 获取指定国家的历史数据
  ///
  /// 调用 API 并返回历史趋势数据
  /// [country] - 国家名称
  @override
  Future<Map<String, dynamic>> getHistoricalData(String country) async {
    _logger.i('开始获取 $country 的历史数据');
    try {
      final response =
          await DioClient.dio.get('${AppConfig.endpointHistorical}/$country');
      _logger.i('历史数据获取成功');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _logger.e('获取历史数据失败: $e');
      rethrow;
    }
  }

  /// 获取指定国家的详细数据
  ///
  /// 调用 API 并返回国家详情
  /// [country] - 国家名称
  @override
  Future<Map<String, dynamic>> getCountryData(String country) async {
    _logger.i('开始获取 $country 的详细数据');
    try {
      final response =
          await DioClient.dio.get('${AppConfig.endpointCountries}/$country');
      _logger.i('详细数据获取成功');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _logger.e('获取详细数据失败: $e');
      rethrow;
    }
  }
}
  }

  /// 获取所有国家列表数据
  ///
  /// 调用 API 并返回国家列表
  @override
  Future<List<dynamic>> getAllCountries() async {
    _logger.i('开始获取国家列表');
    try {
      final response = await DioClient.dio.get(AppConfig.endpointAllCountries);
      _logger.i('国家列表获取成功');
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      _logger.e('获取国家列表失败: $e');
      rethrow;
    }
  }

  /// 获取指定国家的历史数据
  ///
  /// 调用 API 并返回历史趋势数据
  /// [country] - 国家名称
  @override
  Future<Map<String, dynamic>> getHistoricalData(String country) async {
    _logger.i('开始获取 $country 的历史数据');
    try {
      final response =
          await DioClient.dio.get('${AppConfig.endpointHistorical}/$country');
      _logger.i('历史数据获取成功');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _logger.e('获取历史数据失败: $e');
      rethrow;
    }
  }

  /// 获取指定国家的详细数据
  ///
  /// 调用 API 并返回国家详情
  /// [country] - 国家名称
  @override
  Future<Map<String, dynamic>> getCountryData(String country) async {
    _logger.i('开始获取 $country 的详细数据');
    try {
      final response =
          await DioClient.dio.get('${AppConfig.endpointCountries}/$country');
      _logger.i('详细数据获取成功');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _logger.e('获取详细数据失败: $e');
      rethrow;
    }
  }
}
