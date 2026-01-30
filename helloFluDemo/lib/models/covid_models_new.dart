/// COVID-19 类型安全的数据模型
///
/// 使用 json_serializable 实现编译期类型检查
/// 替代原有的 Map<String, dynamic> 使用
import 'package:json_annotation/json_annotation.dart';
import 'package:json_serializable/json_serializable.dart';

/// 全球COVID-19统计数据模型
///
/// 包含病例、死亡、康复、活跃病例等统计数据
@JsonSerializable()
class GlobalStats {
  final int cases;
  final int deaths;
  final int recovered;
  final int active;
  final int updated;
  final int affectedCountries;

  GlobalStats({
    required this.cases,
    required this.deaths,
    required this.recovered,
    required this.active,
    required this.updated,
    required this.affectedCountries,
  });

  /// 从 JSON 创建 GlobalStats 对象
  factory GlobalStats.fromJson(Map<String, dynamic> json) {
    return GlobalStats(
      cases: json['cases'] as int? ?? 0,
      deaths: json['deaths'] as int? ?? 0,
      recovered: json['recovered'] as int? ?? 0,
      active: json['active'] as int? ?? 0,
      updated: json['updated'] as int? ?? 0,
      affectedCountries: json['affectedCountries'] as int? ?? 0,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'cases': cases,
      'deaths': deaths,
      'recovered': recovered,
      'active': active,
      'updated': updated,
      'affectedCountries': affectedCountries,
    };
  }
}

/// 国家COVID-19统计数据模型
///
/// 包含国家名称、病例数、死亡数、国旗等
@JsonSerializable()
class CountryStats {
  final String country;
  final int cases;
  final int deaths;
  final String? flag;

  CountryStats({
    required this.country,
    required this.cases,
    required this.deaths,
    this.flag,
  });

  /// 从 JSON 创建 CountryStats 对象
  factory CountryStats.fromJson(Map<String, dynamic> json) {
    return CountryStats(
      country: json['country'] as String? ?? '',
      cases: json['cases'] as int? ?? 0,
      deaths: json['deaths'] as int? ?? 0,
      flag: json['countryInfo']?['flag'] as String?,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'cases': cases,
      'deaths': deaths,
      'flag': flag,
    };
  }
}
