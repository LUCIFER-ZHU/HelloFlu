import 'dart:convert';
import 'package:http/http.dart' as http;

/// API服务类
class ApiService {
  ApiService._(); // 私有构造函数，防止实例化
  
  // API基础URL
  static const String _baseUrl = 'https://disease.sh/v3/covid-19';

  /// 获取全球COVID-19统计数据
  ///
  /// 返回解析后的全球数据Map
  static Future<Map<String, dynamic>> getGlobalData() async {
    try {
      final url = Uri.parse('$_baseUrl/all');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('获取全球数据失败: HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('获取全球数据失败: $e');
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
      final countryParam = country.replaceAll(' ', '%20');
      final url = Uri.parse('$_baseUrl/historical/$countryParam');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('获取$country历史数据失败: HTTP ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('获取$country历史数据失败: $e');
    }
  }
}
