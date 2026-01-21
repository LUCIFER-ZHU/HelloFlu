/// 简化的COVID-19数据模型
///
/// 由于应用已经简化，不再需要复杂的模型类
/// 直接使用Map<String, dynamic>处理API返回的数据
/// 此文件保留作为参考，实际不再使用复杂的模型转换

// 注：重构后的应用直接使用API返回的原始Map数据，不再需要这些模型类
// 保留此文件是为了兼容可能的未来扩展

/*
/// 全球COVID-19统计数据模型
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
}

/// 国家COVID-19统计数据模型
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

  factory CountryStats.fromJson(Map<String, dynamic> json) {
    return CountryStats(
      country: json['country'] as String? ?? '',
      cases: json['cases'] as int? ?? 0,
      deaths: json['deaths'] as int? ?? 0,
      flag: json['countryInfo']?['flag'] as String?,
    );
  }
}
*/
