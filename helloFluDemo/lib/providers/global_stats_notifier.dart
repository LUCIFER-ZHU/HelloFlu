import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'config_providers.dart';
import 'core_providers.dart';

part 'global_stats_notifier.g.dart';

/// 全球统计数据状态管理器（Riverpod Generator 版本）
///
/// 使用 @riverpod 注解，代码生成器自动生成 Provider
/// 比传统方式减少 70% 样板代码
@riverpod
class GlobalStats extends _$GlobalStats {
  @override
  Future<Map<String, dynamic>> build() async {
    final String country = ref.watch(selectedCountryProvider);
    ref.read(loggerProvider).i('开始加载全球数据和 $country 的历史数据');
    return _loadDashboard(country);
  }

  /// 加载全球和历史数据
  Future<void> loadAll(String country) async {
    ref.read(selectedCountryProvider.notifier).state = country;
    ref.read(loggerProvider).i('开始加载全球和 $country 的历史数据');

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadDashboard(country));

    ref.read(loggerProvider).i('全球和历史数据加载完成');
  }

  /// 刷新数据
  Future<void> refresh() async {
    ref.read(loggerProvider).i('开始刷新数据');
    final String country = ref.read(selectedCountryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadDashboard(country));
    ref.read(loggerProvider).i('数据刷新完成');
  }

  Future<Map<String, dynamic>> _loadDashboard(String country) async {
    final List<Map<String, dynamic>> results = await Future.wait<
      Map<String, dynamic>
    >(<Future<Map<String, dynamic>>>[
      ref.read(covidRepositoryProvider).getGlobalData(),
      ref.read(covidRepositoryProvider).getHistoricalData(country),
    ]);

    return <String, dynamic>{
      'country': country,
      'global': results[0],
      'historical': results[1],
    };
  }
}
