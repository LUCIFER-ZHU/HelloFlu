/// 应用常量配置文件
/// 所有的常量值都在这里集中管理，方便统一修改
class AppConstants {
  AppConstants._(); // 私有构造函数，防止实例化

  // ============= API 配置 =============
  /// 全局COVID-19数据API地址
  static const String apiAllCountries = 'https://disease.sh/v3/covid-19/all';

  /// 特定国家历史数据API地址模板
  static const String apiCountryHistory = 'https://disease.sh/v3/covid-19/historical/India';

  /// 所有国家列表API地址
  static const String apiAllCountriesList = 'https://disease.sh/v3/covid-19/countries?sort=country';

  // ============= 默认配置 =============
  /// 默认查询的国家名称
  static const String defaultCountry = 'China';

  // ============= 应用信息 =============
  /// 应用名称
  static const String appName = 'COVID-19 追踪器';
  
  // ============= 导航标题 =============
  /// 主页标题
  static const String titleHome = '全球疫情数据';

  /// 国家列表标题
  static const String titleCountryList = '受影响的国家';
  
   // ============= 错误提示信息 =============
   /// 网络连接失败提示
   static const String errorNetworkConnection = '无法加载数据，请检查网络连接！';

   /// 一般错误提示
   static const String errorGeneral = '发生错误，请稍后重试！';

   // ============= UI 常量 =============
   /// 搜索提示文本
   static const String searchHint = '搜索国家...';

   /// 卡片圆角半径
   static const double cardBorderRadius = 12.0;

   /// 标题字体大小因子
   static const double titleFontSizeFactor = 0.03;
}
