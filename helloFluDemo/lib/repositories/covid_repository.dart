import 'package:logger/logger.dart';
import 'package:dio/dio.dart';
import '../core/errors/app_error.dart';
import '../core/network/dio_client.dart';
import '../config/app_config.dart';

/// COVID-19 数据仓库接口
///
/// 定义数据访问的抽象层
/// 注：在当前项目中只有一个实现，接口和实现合并在一个文件中
/// 如果未来需要多个实现（如 MockRepository, LocalRepository），
/// 可以再将接口提取到单独文件
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

/// COVID-19 数据仓库实现类
///
/// 负责调用 API 并返回数据
/// 使用 DioClient 单例进行网络请求
/// 使用 Logger 记录操作日志
/// 使用 AppError 进行统一的错误分类和处理
class CovidRepositoryImpl implements CovidRepository {
  /// Logger 实例
  final Logger _logger;

  /// 构造函数
  CovidRepositoryImpl(this._logger);

  /// 获取全球COVID-19统计数据
  @override
  Future<Map<String, dynamic>> getGlobalData() async {
    _logger.i('开始获取全球数据');
    try {
      final response = await DioClient.dio.get(AppConfig.endpointGlobal);
      final data = _normalizeGlobalData(response.data);

      _logger.i('全球数据获取成功，数据量: ${data.length}');
      return data;
    } on DioException catch (e) {
      _logger.e('获取全球数据失败: $e');
      throw ErrorHandler.handleDioError(e);
    } catch (e) {
      _logger.e('获取全球数据时发生未知错误: $e');
      throw ErrorHandler.handleError(e);
    }
  }

  /// 获取所有国家列表数据
  @override
  Future<List<dynamic>> getAllCountries() async {
    _logger.i('开始获取国家列表');
    try {
      final response = await DioClient.dio.get(AppConfig.endpointCountries());
      final data = _normalizeCountryList(response.data);

      _logger.i('国家列表获取成功，数量: ${data.length}');
      return data;
    } on DioException catch (e) {
      _logger.e('获取国家列表失败: $e');
      throw ErrorHandler.handleDioError(e);
    } catch (e) {
      _logger.e('获取国家列表时发生未知错误: $e');
      throw ErrorHandler.handleError(e);
    }
  }

  /// 获取指定国家的历史数据
  @override
  Future<Map<String, dynamic>> getHistoricalData(String country) async {
    _logger.i('开始获取 $country 的历史数据');
    try {
      final response =
          await DioClient.dio.get(AppConfig.endpointHistorical(country));
      final data = _normalizeHistoricalData(response.data, country);

      _logger.i('$country 历史数据获取成功');
      return data;
    } on DioException catch (e) {
      _logger.e('获取 $country 历史数据失败: $e');
      throw ErrorHandler.handleDioError(e);
    } catch (e) {
      _logger.e('获取 $country 历史数据时发生未知错误: $e');
      throw ErrorHandler.handleError(e);
    }
  }

  /// 获取指定国家的详细数据
  @override
  Future<Map<String, dynamic>> getCountryData(String country) async {
    _logger.i('开始获取 $country 的详细数据');
    try {
      final response =
          await DioClient.dio.get('${AppConfig.endpointCountries()}/$country');
      final data = _normalizeCountryData(response.data);

      _logger.i('$country 详细数据获取成功');
      return data;
    } on DioException catch (e) {
      _logger.e('获取 $country 详细数据失败: $e');
      throw ErrorHandler.handleDioError(e);
    } catch (e) {
      _logger.e('获取 $country 详细数据时发生未知错误: $e');
      throw ErrorHandler.handleError(e);
    }
  }

  Map<String, dynamic> _normalizeGlobalData(dynamic data) {
    final source = _requireMap(data);
    return <String, dynamic>{
      'updated': _asInt(source['updated']),
      'cases': _asInt(source['cases']),
      'todayCases': _asInt(source['todayCases']),
      'deaths': _asInt(source['deaths']),
      'todayDeaths': _asInt(source['todayDeaths']),
      'recovered': _asInt(source['recovered']),
      'active': _asInt(source['active']),
      'tests': _asInt(source['tests']),
      'affectedCountries': _asInt(source['affectedCountries']),
    };
  }

  List<dynamic> _normalizeCountryList(dynamic data) {
    if (data is! List) {
      throw DataParseError(message: '国家列表数据格式错误', originalError: data);
    }

    return data
        .whereType<Map<dynamic, dynamic>>()
        .map((Map<dynamic, dynamic> country) {
          return _normalizeCountryData(country);
        })
        .toList();
  }

  Map<String, dynamic> _normalizeHistoricalData(dynamic data, String country) {
    final source = _requireMap(data);
    final timeline = source['timeline'];
    final Map<String, dynamic> timelineMap =
        timeline is Map ? Map<String, dynamic>.from(timeline) : <String, dynamic>{};

    return <String, dynamic>{
      'country': source['country']?.toString() ?? country,
      'province': source['province'] is List ? source['province'] : <dynamic>[],
      'timeline': <String, dynamic>{
        'cases': _normalizeTimelineSeries(timelineMap['cases']),
        'deaths': _normalizeTimelineSeries(timelineMap['deaths']),
        'recovered': _normalizeTimelineSeries(timelineMap['recovered']),
      },
    };
  }

  Map<String, dynamic> _normalizeCountryData(dynamic data) {
    final source = _requireMap(data);
    final dynamic countryInfo = source['countryInfo'];
    final Map<String, dynamic> countryInfoMap = countryInfo is Map
        ? Map<String, dynamic>.from(countryInfo)
        : <String, dynamic>{};

    return <String, dynamic>{
      'country': source['country']?.toString() ?? 'Unknown',
      'cases': _asInt(source['cases']),
      'todayCases': _asInt(source['todayCases']),
      'deaths': _asInt(source['deaths']),
      'todayDeaths': _asInt(source['todayDeaths']),
      'recovered': _asInt(source['recovered']),
      'active': _asInt(source['active']),
      'critical': _asInt(source['critical']),
      'tests': _asInt(source['tests']),
      'casesPerOneMillion': _asDouble(source['casesPerOneMillion']),
      'countryInfo': <String, dynamic>{
        'flag': countryInfoMap['flag']?.toString() ?? '',
      },
    };
  }

  Map<String, dynamic> _normalizeTimelineSeries(dynamic data) {
    if (data is! Map) {
      return <String, dynamic>{};
    }

    final Map<String, dynamic> result = <String, dynamic>{};
    data.forEach((dynamic key, dynamic value) {
      final String normalizedKey = key?.toString() ?? '';
      if (normalizedKey.isEmpty) {
        return;
      }

      result[normalizedKey] = _asInt(value);
    });
    return result;
  }

  Map<String, dynamic> _requireMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    throw DataParseError(message: '接口返回的数据结构不符合预期', originalError: data);
  }

  int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _asDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
