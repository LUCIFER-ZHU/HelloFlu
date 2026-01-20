import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';

/// API服务类
///
/// 负责从COVID-19数据API获取所有数据
/// 使用免费的public API: disease.sh
class ApiService {
  ApiService._(); // 私有构造函数，防止实例化

  /// 获取全球数据和特定国家的历史数据
  ///
  /// 返回一个Map包含：
  /// - 'all': 全球总数据（JSON字符串）
  /// - 'country': 特定国家的每日病例数据（List<DataPoint>）
  /// - 'deaths': 特定国家的每日死亡数据（List<DataPoint>）
  /// - 'recovered': 特定国家的每日康复数据（List<DataPoint>）
  ///
  /// 使用示例：
  /// ```dart
  /// var data = await ApiService.getAllData();
  /// var global = json.decode(data['all']);
  /// ```
  static Future<Map<String, dynamic>> getAllData({
    String country = AppConstants.defaultCountry,
  }) async {
    try {
      // 第一步：获取全球统计数据
      final allCountriesUrl = Uri.parse(AppConstants.apiAllCountries);
      final allCountriesResponse = await http.get(allCountriesUrl);

      // 检查HTTP响应状态码
      if (allCountriesResponse.statusCode != 200) {
        throw Exception(
          '获取全球数据失败: HTTP ${allCountriesResponse.statusCode}',
        );
      }

      // 第二步：获取特定国家的历史数据
      // 注意：我们将国家名称插入到URL中
      final countryUrl = Uri.parse(
        AppConstants.apiCountryHistory.replaceAll('India', country),
      );
      final countryResponse = await http.get(countryUrl);

      if (countryResponse.statusCode != 200) {
        throw Exception(
          '获取$country数据失败: HTTP ${countryResponse.statusCode}',
        );
      }

      // 第三步：解析历史数据并转换为数据点
      // API返回的数据格式是: {"1/22/20": 0, "1/23/20": 0, ...}
      // 我们需要将其转换为: [{"date": DateTime(2020, 1, 22), "value": 0}, ...]
      final countryData = jsonDecode(countryResponse.body);

      // 提取每日病例数据
      final casesData = countryData['timeline']['cases'] as Map<String, dynamic>;
      final dataPointsCases = _parseTimelineData(casesData);

      // 提取每日死亡数据
      final deathsData = countryData['timeline']['deaths'] as Map<String, dynamic>;
      final dataPointsDeaths = _parseTimelineData(deathsData);

      // 提取每日康复数据
      final recoveredData = countryData['timeline']['recovered'] as Map<String, dynamic>;
      final dataPointsRecovered = _parseTimelineData(recoveredData);

      // 第四步：返回所有数据
      return {
        'all': allCountriesResponse.body,
        'country': dataPointsCases,
        'deaths': dataPointsDeaths,
        'recovered': dataPointsRecovered,
      };
    } on http.ClientException catch (e) {
      // 网络连接错误
      throw Exception('网络连接错误: ${e.message}');
    } on FormatException catch (e) {
      // JSON解析错误
      throw Exception('数据格式错误: ${e.message}');
    } catch (e) {
      // 其他未知错误
      throw Exception('未知错误: $e');
    }
  }

  /// 获取所有国家的列表数据
  ///
  /// 返回所有国家的COVID-19统计数据（按国家名称排序）
  ///
  /// 使用示例：
  /// ```dart
  /// var countriesData = await ApiService.getAllCountriesData();
  /// var countries = jsonDecode(countriesData);
  /// for (var country in countries) {
  ///   print('${country['country']}: ${country['cases']} cases');
  /// }
  /// ```
  static Future<String> getAllCountriesData() async {
    try {
      final url = Uri.parse(AppConstants.apiAllCountriesList);
      final response = await http.get(url);

      // 检查HTTP响应状态码
      if (response.statusCode != 200) {
        throw Exception(
          '获取国家列表失败: HTTP ${response.statusCode}',
        );
      }

      return response.body;
    } on http.ClientException catch (e) {
      // 网络连接错误
      throw Exception('网络连接错误: ${e.message}');
    } catch (e) {
      // 其他错误
      throw Exception('未知错误: $e');
    }
  }

  /// 将时间线数据解析为数据点列表
  ///
  /// 输入格式: {"1/22/20": 0, "1/23/20": 1, ...}
  /// 输出格式: [{"date": DateTime(2020, 1, 22), "value": 0}, ...]
  ///
  /// [timelineData] - 从API获取的时间线数据Map
  ///
  /// 返回排序后的数据点列表
  static List<Map<String, dynamic>> _parseTimelineData(
    Map<String, dynamic> timelineData,
  ) {
    final List<Map<String, dynamic>> dataPoints = [];

    // 遍历时间线数据
    timelineData.forEach((key, value) {
      // 解析日期字符串，格式为 "M/D/Y"
      // 例如: "1/22/20" -> 2020年1月22日
      final dateParts = key.split('/');
      if (dateParts.length != 3) {
        // 如果日期格式不对，跳过这个数据点
        return;
      }

      try {
        final month = int.parse(dateParts[0]);
        final day = int.parse(dateParts[1]);
        final year = int.parse('20${dateParts[2]}'); // 假设年份是20xx

        // 创建DateTime对象
        final date = DateTime(year, month, day);

        // 添加到数据点列表
        dataPoints.add({
          'date': date,
          'value': value,
        });
      } catch (e) {
        // 如果日期解析失败，跳过这个数据点
        print('日期解析失败: $key');
      }
    });

    // 按日期排序数据点
    dataPoints.sort((a, b) => a['date'].compareTo(b['date']));

    return dataPoints;
  }
}
