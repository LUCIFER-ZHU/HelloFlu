// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'core_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$loggerHash() => r'273e920c42fd607a9de5eaed585fe729e795a9bf';

/// Logger Provider（Generated）
///
/// 全局日志服务，所有模块共享同一个 Logger 实例
/// 根据 AppConfig.enableLogging 动态启用/禁用日志
///
/// Copied from [logger].
@ProviderFor(logger)
final loggerProvider = AutoDisposeProvider<Logger>.internal(
  logger,
  name: r'loggerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$loggerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LoggerRef = AutoDisposeProviderRef<Logger>;
String _$covidRepositoryHash() => r'3267b0de98e25d582ac8262b71b8b82ab92e3c83';

/// CovidRepository Provider（Generated）
///
/// 数据仓库 Provider，提供统一的数据访问接口
/// 依赖 loggerProvider，自动注入 Logger 实例
///
/// Copied from [covidRepository].
@ProviderFor(covidRepository)
final covidRepositoryProvider = AutoDisposeProvider<CovidRepository>.internal(
  covidRepository,
  name: r'covidRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$covidRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CovidRepositoryRef = AutoDisposeProviderRef<CovidRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
