import 'dart:convert';
import 'package:http/http.dart' as http;

/// API服务类
class ApiService {
  ApiService._(); // 私有构造函数，防止实例化

  // API基础URL
  static const String _baseUrl = 'https://disease.sh/v3/covid-19';

  /// 获取全球COVID-19统计数据
  static Future<Map<String, dynamic>> getGlobalData() async {
    try {
      print('开始获取全球数据...');
      final url = Uri.parse('$_baseUrl/all');
      print('请求URL: $url');
      final response = await http.get(url);
      print('响应状态码: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        print('全球数据获取成功，数据量: ${data.length}');
        return data;
      } else {
        final errorMsg = '获取全球数据失败: HTTP ${response.statusCode}';
        print(errorMsg);
        throw Exception(errorMsg);
      }
    } on http.ClientException catch (e) {
      final errorMsg = '网络连接错误: ${e.message}';
      print(errorMsg);
      throw Exception(errorMsg);
    } catch (e) {
      final errorMsg = '获取全球数据失败: $e';
      print(errorMsg);
      throw Exception(errorMsg);
    }
  }

  /// 获取所有国家的COVID-19统计数据
  ///
  /// 返回解析后的国家数据列表
  static Future<List<dynamic>> getAllCountriesData() async {
    try {
      final url = Uri.parse('$_baseUrl/countries?sort=country');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('获取国家列表失败: HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('获取国家列表失败: $e');
    }
  }

  /// 获取特定国家的历史数据
  ///
  /// [country] - 国家名称
  /// 返回解析后的历史数据Map
  static Future<Map<String, dynamic>> getCountryHistoricalData(String country) async {
    try {
      print('开始获取$country的历史数据...');
      final countryParam = country.replaceAll(' ', '%20');
      final url = Uri.parse('$_baseUrl/historical/$countryParam');
      print('请求URL: $url');
      final response = await http.get(url);
      print('响应状态码: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        print('$country历史数据获取成功');
        return data;
      } else {
        final errorMsg = '获取$country历史数据失败: HTTP ${response.statusCode}';
        print(errorMsg);
        throw Exception(errorMsg);
      }
    } on http.ClientException catch (e) {
      final errorMsg = '网络连接错误: ${e.message}';
      print(errorMsg);
      throw Exception(errorMsg);
    } catch (e) {
      final errorMsg = '获取$country历史数据失败: $e';
      print(errorMsg);
      throw Exception(errorMsg);
    }
  }
}