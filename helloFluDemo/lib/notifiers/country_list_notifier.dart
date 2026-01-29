import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../services/api_service.dart';

/// 国家列表状态管理器
///
/// 负责管理国家列表的数据状态
/// 支持加载、刷新、搜索等功能
/// 使用 Riverpod 的 Provider 参数注入 Logger
/// SharedPreferences 在内部异步获取
///
/// Web 对比：类似 Zustand 的 store 或 Redux 的 reducer
///
/// 使用方式：
/// ```dart
/// final notifier = ref.watch(countriesProvider.notifier);
/// await notifier.refresh();
/// notifier.search('China');
/// ```
class CountryListNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  /// Logger 实例
  final Logger _logger;

  /// 构造函数
  CountryListNotifier(this._logger) : super(const AsyncValue.loading()) {
    // 初始化时加载数据
    loadCountries();
  }

  /// 加载国家列表
  Future<void> loadCountries() async {
    state = const AsyncValue.loading();
    _logger.i('开始加载国家列表');
    state = await AsyncValue.guard(() async {
      return ApiService.getAllCountriesData();
    });
  }

  /// 刷新国家列表
  Future<void> refresh() async {
    await loadCountries();
  }

  /// 搜索国家
  ///
  /// [query] - 搜索关键词
  /// 过滤国家名称包含关键词的国家
  void search(String query) {
    _logger.i('搜索国家: $query');
    if (state is AsyncData) {
      final countries = (state as AsyncData).value as List<dynamic>;
      final filtered = countries
          .where((country) =>
              (country['country'] as String)
                  .toLowerCase()
                  .contains(query.toLowerCase()))
          .toList();
      state = AsyncValue.data(filtered);
    }
  }

  /// 重置搜索
  void reset() {
    loadCountries();
  }
}
