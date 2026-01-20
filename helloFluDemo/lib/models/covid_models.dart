/// 全球COVID-19统计数据模型
///
/// 表示全球范围内的COVID-19疫情数据汇总
class GlobalStats {
  /// 累计确诊人数
  final int cases;

  /// 累计死亡人数
  final int deaths;

  /// 累计康复人数
  final int recovered;

  /// 当前活跃病例数
  final int active;

  /// 数据最后更新时间戳
  final int updated;

  /// 受影响的国家数量
  final int affectedCountries;

  GlobalStats({
    required this.cases,
    required this.deaths,
    required this.recovered,
    required this.active,
    required this.updated,
    required this.affectedCountries,
  });

  /// 从JSON数据创建GlobalStats对象
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

  /// 将对象转换为JSON
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
/// 表示单个国家的COVID-19疫情数据
class CountryStats {
  /// 国家名称
  final String country;

  /// 国家代码（ISO 3166-1 alpha-2）
  final String? countryInfo;

  /// 累计确诊人数
  final int cases;

  /// 今日新增病例
  final int todayCases;

  /// 累计死亡人数
  final int deaths;

  /// 今日新增死亡
  final int todayDeaths;

  /// 累计康复人数
  final int recovered;

  /// 危重病例数
  final int critical;

  /// 每百万人口的病例数
  final double casesPerOneMillion;

  /// 国旗图片URL
  final String? flag;

  CountryStats({
    required this.country,
    this.countryInfo,
    required this.cases,
    required this.todayCases,
    required this.deaths,
    required this.todayDeaths,
    required this.recovered,
    required this.critical,
    required this.casesPerOneMillion,
    this.flag,
  });

  /// 从JSON数据创建CountryStats对象
  factory CountryStats.fromJson(Map<String, dynamic> json) {
    return CountryStats(
      country: json['country'] as String? ?? '',
      countryInfo: json['countryInfo'] != null
          ? json['countryInfo']['iso2'] as String?
          : null,
      cases: json['cases'] as int? ?? 0,
      todayCases: json['todayCases'] as int? ?? 0,
      deaths: json['deaths'] as int? ?? 0,
      todayDeaths: json['todayDeaths'] as int? ?? 0,
      recovered: json['recovered'] as int? ?? 0,
      critical: json['critical'] as int? ?? 0,
      casesPerOneMillion:
          (json['casesPerOneMillion'] as num?)?.toDouble() ?? 0.0,
      flag: json['countryInfo'] != null
          ? json['countryInfo']['flag'] as String?
          : null,
    );
  }

  /// 将对象转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'cases': cases,
      'todayCases': todayCases,
      'deaths': deaths,
      'todayDeaths': todayDeaths,
      'recovered': recovered,
      'critical': critical,
      'casesPerOneMillion': casesPerOneMillion,
      'flag': flag,
    };
  }
}

/// 时间线数据点模型
///
/// 表示特定日期的数据点，用于绘制图表
class TimelineDataPoint {
  /// 日期
  final DateTime date;

  /// 数值
  final int value;

  TimelineDataPoint({
    required this.date,
    required this.value,
  });

  /// 从Map创建TimelineDataPoint对象
  factory TimelineDataPoint.fromMap(Map<String, dynamic> map) {
    return TimelineDataPoint(
      date: map['date'] as DateTime,
      value: map['value'] as int? ?? 0,
    );
  }

  /// 将对象转换为Map
  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'value': value,
    };
  }
}
