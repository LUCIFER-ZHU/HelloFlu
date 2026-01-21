import 'package:flutter/material.dart';
import '../config/colors.dart';

/// 数字格式化工具类
///
/// 用于将大数字格式化为更易读的形式
/// 例如：2,000,000 转换为 2M
class NumberFormatter {
  NumberFormatter._(); // 私有构造函数，防止实例化

  /// 格式化数字为易读字符串
  ///
  /// [number] - 要格式化的数字（可以是int或double）
  /// 返回格式化后的字符串
  static String formatNumber(num number) {
    final intValue = number.toInt();
    if (intValue >= 1000000) {
      return '${(intValue / 1000000).toStringAsFixed(1)}M';
    } else if (intValue >= 1000) {
      return '${(intValue / 1000).toStringAsFixed(1)}K';
    }
    return intValue.toString();
  }

  /// 格式化数字字符串
  ///
  /// [numberString] - 要格式化的数字字符串
  /// 返回格式化后的字符串
  static String formatNumberString(String numberString) {
    try {
      final number = int.parse(numberString);
      return formatNumber(number);
    } catch (e) {
      // 如果解析失败，返回原始字符串
      return numberString;
    }
  }
}

/// 折叠单元格组件
///
/// 用于在国家列表中展示国家详情
/// 点击可以展开查看更多统计数据
class CountryFoldingCell extends StatelessWidget {
  /// 国家名称
  final String countryName;

  /// 国旗图片URL
  final String flagUrl;

  /// 累计确诊病例
  final String totalCases;

  /// 今日新增病例
  final String todayCases;

  /// 累计死亡人数
  final String totalDeaths;

  /// 今日新增死亡
  final String todayDeaths;

  /// 累计康复人数
  final String recovered;

  /// 危重病例数
  final String critical;

  /// 每百万人口的病例数
  final String casesPerOneMillion;

  const CountryFoldingCell({
    super.key,
    required this.countryName,
    required this.flagUrl,
    required this.totalCases,
    required this.todayCases,
    required this.totalDeaths,
    required this.todayDeaths,
    required this.recovered,
    required this.critical,
    required this.casesPerOneMillion,
  });

  /// 格式化数字显示
  String _formatNumber(String number) {
    return NumberFormatter.formatNumberString(number);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.listContainer,
      margin: EdgeInsets.only(bottom: 10),
      child: Card(
        color: AppColors.foldingCellFront,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            expansionTileTheme: ExpansionTileThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          child: ExpansionTile(
            tilePadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            childrenPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            // 折叠状态时显示的内容
            title: Row(
              children: [
                // 国旗图片
                ClipOval(
                  child: Image.network(
                    flagUrl,
                    width: MediaQuery.of(context).size.width * 0.12,
                    height: MediaQuery.of(context).size.width * 0.12,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // 图片加载失败时显示占位图标
                      return Container(
                        width: MediaQuery.of(context).size.width * 0.12,
                        height: MediaQuery.of(context).size.width * 0.12,
                        color: AppColors.white.withOpacity(0.3),
                        child: Icon(
                          Icons.flag,
                          color: AppColors.white,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(width: 16.0),

                // 国家名称和确诊病例数
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        countryName,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "总病例: ${_formatNumber(totalCases)}",
                        style: TextStyle(
                          color: AppColors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            iconColor: AppColors.white,
            collapsedIconColor: AppColors.white,
            // 展开时的内容
            children: [
              Container(
                color: AppColors.cardBackground,
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 国家名称标题
                    Text(
                      countryName,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.0),

                    // 总病例（突出显示）
                    Center(
                      child: Column(
                        children: [
                          Text(
                            "总病例",
                            style: TextStyle(
                              color: AppColors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _formatNumber(totalCases),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 28.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.0),

                    // 详细统计数据（两列布局）
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // 左列
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStatText("今日病例", todayCases),
                              SizedBox(height: 12),
                              _buildStatText("死亡", totalDeaths),
                              SizedBox(height: 12),
                              _buildStatText("每百万人口", casesPerOneMillion),
                            ],
                          ),
                        ),

                        SizedBox(width: 20.0),

                        // 右列
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStatText("康复", recovered),
                              SizedBox(height: 12),
                              _buildStatText("今日死亡", todayDeaths),
                              SizedBox(height: 12),
                              _buildStatText("危重", critical),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建统计文本
  Widget _buildStatText(String label, String value) {
    return Text(
      "$label: ${_formatNumber(value)}",
      style: TextStyle(
        color: AppColors.white,
        fontSize: 14.0,
      ),
    );
  }
}
