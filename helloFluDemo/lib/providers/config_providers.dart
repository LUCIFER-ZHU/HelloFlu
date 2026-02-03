import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../config/app_config.dart';

part 'config_providers.g.dart';

/// 主题 Provider（Generated）
/// 
/// 提供应用主题配置
/// 所有需要访问主题的 UI 组件可以通过此 Provider 获取
@riverpod
ThemeData theme(Ref ref) {
  return AppConfig.darkTheme;
}

/// 默认国家 Provider（Generated）
/// 
/// 提供默认国家设置
/// 用于初始化时加载默认国家的历史数据
@riverpod
String defaultCountry(Ref ref) {
  return AppConfig.defaultCountry;
}
