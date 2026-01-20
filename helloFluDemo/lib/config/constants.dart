/// 应用常量配置文件
/// 所有的常量值都在这里集中管理，方便统一修改
class AppConstants {
  AppConstants._(); // 私有构造函数，防止实例化

  // ============= API 配置 =============
  /// 全局COVID-19数据API地址
  static const String apiAllCountries = 'https://disease.sh/v3/covid-19/all';

  /// 特定国家历史数据API地址模板（需要在运行时替换国家名）
  /// 例如：将 "India" 替换为你想要查询的国家名称
  static const String apiCountryHistory = 'https://disease.sh/v3/covid-19/historical/India';

  /// 所有国家列表API地址
  static const String apiAllCountriesList = 'https://disease.sh/v3/covid-19/countries?sort=country';

  // ============= 默认配置 =============
  /// 默认查询的国家名称
  /// 你可以修改这个值来显示其他国家的数据
  static const String defaultCountry = 'China';

  /// 数字显示配置
  /// 当数字很长时，显示的字符数限制
  /// 例如：2500000 会显示为 2.5M（4个字符）
  static const int numberDisplayLength = 4;

  // ============= 布局和尺寸 =============
  /// 卡片圆角半径
  static const double cardBorderRadius = 40.0;

  /// 列表项间距
  static const double listItemSpacing = 15.0;

  /// 折叠单元格动画持续时间（毫秒）
  static const int foldingAnimationDuration = 300;

  /// 折叠单元格高度
  static const double foldingCellHeight = 125.0;

  // ============= 字体大小系数 =============
  /// 标题文字大小系数（基于屏幕高度）
  static const double titleFontSizeFactor = 0.03;

  // ============= 错误提示信息 =============
  /// 网络连接失败提示
  static const String errorNetworkConnection = '无法加载数据，请检查网络连接！';

  /// 一般错误提示
  static const String errorGeneral = '发生错误，请稍后重试！';

  // ============= 导航标题 =============
  /// 主页标题
  static const String titleHome = '全球疫情数据';

  /// 国家列表标题
  static const String titleCountryList = '受影响的国家';

  /// 搜索提示
  static const String searchHint = '搜索国家';

  // ============= 应用信息 =============
  /// 应用名称
  static const String appName = 'COVID-19 追踪器';
}
