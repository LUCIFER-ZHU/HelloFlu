// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_stats_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$globalStatsHash() => r'f4dcfcffda6666cfeb44067731ee5f7573d2ce88';

/// 全球统计数据状态管理器（Riverpod Generator 版本）
///
/// 使用 @riverpod 注解，代码生成器自动生成 Provider
/// 比传统方式减少 70% 样板代码
///
/// Copied from [GlobalStats].
@ProviderFor(GlobalStats)
final globalStatsProvider =
    AutoDisposeAsyncNotifierProvider<
      GlobalStats,
      Map<String, dynamic>
    >.internal(
      GlobalStats.new,
      name: r'globalStatsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$globalStatsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GlobalStats = AutoDisposeAsyncNotifier<Map<String, dynamic>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
