// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$themeHash() => r'd0c3aab4f7420d82ce5bea1a2ea5342b5a843479';

/// 主题 Provider（Generated）
///
/// 提供应用主题配置
/// 所有需要访问主题的 UI 组件可以通过此 Provider 获取
///
/// Copied from [theme].
@ProviderFor(theme)
final themeProvider = AutoDisposeProvider<ThemeData>.internal(
  theme,
  name: r'themeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$themeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ThemeRef = AutoDisposeProviderRef<ThemeData>;
String _$defaultCountryHash() => r'def89dca7551fe55ee6173cf957c6edd49adf3a2';

/// 默认国家 Provider（Generated）
///
/// 提供默认国家设置
/// 用于初始化时加载默认国家的历史数据
///
/// Copied from [defaultCountry].
@ProviderFor(defaultCountry)
final defaultCountryProvider = AutoDisposeProvider<String>.internal(
  defaultCountry,
  name: r'defaultCountryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$defaultCountryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DefaultCountryRef = AutoDisposeProviderRef<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
