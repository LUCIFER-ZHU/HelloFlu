import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../services/api_service.dart';

/// COVID-19 数据仓库接口
///
/// 定义数据访问的抽象层
/// 提供统一的数据获取方法，支持未来扩展（如本地缓存）
abstract class CovidRepository {
  /// 获取全球COVID-19统计数据
  Future<Map<String, dynamic>> getGlobalData();

  /// 获取所有国家数据
  Future<List<dynamic>> getAllCountries();

  /// 获取指定国家的历史数据
  Future<Map<String, dynamic>> getHistoricalData(String country);

  /// 获取指定国家的详细数据
  Future<Map<String, dynamic>> getCountryData(String country);
}
