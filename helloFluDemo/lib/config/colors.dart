import 'package:flutter/material.dart';

/// 应用主题颜色配置
/// 所有的颜色都在这里集中管理，方便统一修改和维护
class AppColors {
  AppColors._(); // 私有构造函数，防止实例化

  // ============= 主要颜色 =============
  /// 主色调 - 蓝色
  static const Color primary = Colors.blue;

  /// 强调色 - 红色系（用于重要信息）
  static const Color accent = Color(0xfff4796b);

  // ============= 卡片和信息颜色 =============
  /// 信息卡片背景色 - 红色
  static const Color cardBackground = Color(0xfff44e3f);

  /// 折叠单元格背景色 - 黑色
  static const Color foldingCellFront = Color(0xff000000);

  /// 列表容器背景色 - 深灰色
  static const Color listContainer = Color(0xFF2e282a);

  // ============= 状态颜色 =============
  /// 错误提示文字颜色
  static const Color errorText = Colors.red;

  // ============= 图表颜色 =============
  /// 确诊病例图表颜色
  static const Color casesGraph = Colors.orange;

  /// 死亡病例图表颜色
  static const Color deathsGraph = Colors.red;

  /// 康复病例图表颜色
  static const Color recoveredGraph = Colors.green;

  // ============= 其他颜色 =============
  /// 白色
  static const Color white = Colors.white;

  /// 黑色
  static const Color black = Colors.black;
}
