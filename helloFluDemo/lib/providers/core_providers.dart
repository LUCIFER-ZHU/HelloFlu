import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';
import '../config/app_config.dart';
import '../repositories/covid_repository.dart';

part 'core_providers.g.dart';

/// Logger Provider（Generated）
/// 
/// 全局日志服务，所有模块共享同一个 Logger 实例
/// 根据 AppConfig.enableLogging 动态启用/禁用日志
@riverpod
Logger logger(Ref ref) {
  final isLoggingEnabled = AppConfig.enableLogging;

  return Logger(
    level: isLoggingEnabled ? Level.trace : Level.off,
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );
}

/// CovidRepository Provider（Generated）
/// 
/// 数据仓库 Provider，提供统一的数据访问接口
/// 依赖 loggerProvider，自动注入 Logger 实例
@riverpod
CovidRepository covidRepository(Ref ref) {
  return CovidRepositoryImpl(ref.read(loggerProvider));
}
