import 'package:flutter/material.dart';

/// 应用主题颜色配置
class AppColors {
  AppColors._(); // 私有构造函数，防止实例化

  // 主要颜色
  static const Color primary = Colors.blue;
  static const Color accent = Color(0xfff4796b);
  
  // 卡片和背景色
  static const Color cardBackground = Color(0xfff44e3f);
  static const Color foldingCellFront = Color(0xff000000);
  static const Color listContainer = Color(0xFF2e282a);
  
  // 状态颜色
  static const Color errorText = Colors.red;
  
  // 图表颜色
  static const Color casesGraph = Colors.orange;
  static const Color deathsGraph = Colors.red;
  static const Color recoveredGraph = Colors.green;
  
  // 基础颜色
  static const Color white = Colors.white;
  static const Color black = Colors.black;
}
