import 'package:flutter/material.dart';
import '../config/constants.dart';
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

/// 信息卡片组件
///
/// 在主页上显示圆形矩形卡片，展示COVID-19数据
/// 例如：确诊数、死亡数、康复数等
class InfoCard extends StatelessWidget {
  /// 卡片标题
  final String title;

  /// 显示的数字
  final String number;

  /// 卡片背景颜色（可选，默认使用AppColors.cardBackground）
  final Color? backgroundColor;

  const InfoCard({
    super.key,
    required this.title,
    required this.number,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      color: backgroundColor ?? AppColors.cardBackground,
      elevation: 4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // 标题文本
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height * AppConstants.titleFontSizeFactor,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),

          // 数字文本
          Text(
            number,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ), // 添加阴影效果
    );
  }
}
