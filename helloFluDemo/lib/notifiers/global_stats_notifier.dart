import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../repositories/covid_repository.dart';

/// 全球统计数据状态管理器
///
/// 负责管理全球疫情统计数据和历史数据
/// 支持加载、刷新数据
/// 使用 Riverpod 的 Provider 参数注入 Logger 和 CovidRepository
/// SharedPreferences 在内部异步获取
///
/// Web 对比：类似 Zustand 的 store 或 Redux 的 reducer
///
/// 使用方式：
/// ```dart
/// final repository = ref.watch(covidRepositoryProvider);
/// final notifier = ref.watch(globalStatsProvider.notifier);
/// await notifier.refresh();
/// await notifier.loadHistoricalData('China');
/// ```
class GlobalStatsNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  /// Logger 实例
  final Logger _logger;

  /// Repository 实例（注入而非硬编码）
  final CovidRepository _repository;

  /// 缓存的历史数据
  Map<String, dynamic>? _historicalData;

  /// 构造函数
  GlobalStatsNotifier(this._repository, this._logger)
      : super(const AsyncValue.loading()) {
    loadGlobalData();
  }

  /// 加载全球统计数据
  Future<void> loadGlobalData() async {
    state = const AsyncValue.loading();
    _logger.i('开始加载全球数据');
    state = await AsyncValue.guard(() async {
      return _repository.getGlobalData();
    });
  }

  /// 加载国家历史数据
  ///
  /// [country] - 国家名称
  Future<void> loadHistoricalData(String country) async {
    state = const AsyncValue.loading();
    _logger.i('开始加载 $country 的历史数据');
    state = await AsyncValue.guard(() async {
      _historicalData = await _repository.getHistoricalData(country);
      return {
        'global': state.valueOrNull,
        'historical': _historicalData,
      };
    });
  }

  /// 刷新所有数据
  Future<void> refresh() async {
    await loadGlobalData();
    if (_historicalData != null) {
      await loadHistoricalData('China');
    }
  }

  /// 获取缓存的历史数据
  Map<String, dynamic>? get historicalData => _historicalData;
}
