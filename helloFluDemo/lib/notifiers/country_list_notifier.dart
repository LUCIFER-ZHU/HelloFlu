import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../router.dart';

part 'country_list_notifier.g.dart';

/// 国家列表状态管理器（Riverpod Generator 版本）
@riverpod
class Countries extends _$Countries {
  @override
  Future<List<dynamic>> build() async {
    ref.read(loggerProvider).i('开始加载国家列表');
    return ref.read(covidRepositoryProvider).getAllCountries();
  }

  /// 刷新国家列表
  Future<void> refresh() async {
    ref.read(loggerProvider).i('刷新国家列表');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return ref.read(covidRepositoryProvider).getAllCountries();
    });
  }

  /// 搜索国家
  void search(String query) {
    ref.read(loggerProvider).i('搜索国家: $query');
    if (state case AsyncData(value: final countries)) {
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
  Future<void> reset() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return ref.read(covidRepositoryProvider).getAllCountries();
    });
  }
}
