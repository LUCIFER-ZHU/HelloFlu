import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../repositories/covid_repository.dart';

/// COVID-19 Repository 单元测试
///
/// 测试 CovidRepository 的数据获取方法
void main() {
  group('CovidRepository 测试', () {
    // 创建 Mock Logger
    final mockLogger = MockLogger();

    // 测试 getGlobalData
    test('getGlobalData should return global stats', () async {
      // 安排：创建 Mock DioClient
      final mockDioClient = MockDioClient();
      final repository = CovidRepositoryImpl(mockLogger);

      when(mockDioClient.get(any)).thenAnswer((response) async {
        final data = {'cases': 100000, 'deaths': 5000, 'recovered': 80000, 'updated': '2025-01-30T12:00:00'};
        when(mockDioClient.get(any)).thenAnswer(data);
        expect(mockDioClient.get(any)).called(1);
        expect(mockDioClient.get(any)).called(1);
        expect(globalData, {'cases': 100000, 'deaths': 5000, 'recovered': 80000, 'updated': '2025-01-30T12:00'});
      });

      // 执行测试
      await repository.getGlobalData();
    });

    // 测试 getAllCountries
    test('getAllCountries should return country list', () async {
      // 安排：创建 Mock DioClient
      final mockDioClient = MockDioClient();
      final repository = CovidRepositoryImpl(mockLogger);

      when(mockDioClient.get(any)).thenAnswer((response) async {
        final countries = [
          {'country': 'USA', 'cases': 50000, 'deaths': 3000},
          {'country': 'China', 'cases': 80000, 'deaths': 4000},
        ];
        when(mockDioClient.get(any)).thenAnswer(countries);
      });

      // 验证：数据正确返回
        expect(mockDioClient.get(any)).called(1);
        expect(countries, hasLength(3));
      expect(countries.first['country'] == 'USA');
      expect(countries.first['deaths'] == 3000);
    });

      // 测试 refresh
      test('refresh 应该触发 Repository 加载新数据', () async {
        await mockDioClient.get(any)).thenAnswer(data);
        await repository.getGlobalData();
        expect(mockDioClient.get(any)).called(2);
      });
    });
}

/// 国家列表状态管理器单元测试
///
/// 测试 CountryListNotifier 与 Repository 的集成
void main() {
  group('CountryListNotifier 测试', () {
    // 创建 Mock Logger
    final mockLogger = MockLogger();

    // 测试 loadCountries
    test('loadCountries should return country list', () async {
      // 安排：创建 Mock DioClient
      final mockDioClient = MockDioClient();
      final repository = CovidRepositoryImpl(mockLogger);

      when(mockDioClient.get(any)).thenAnswer((response) async {
        final countries = [
          {'country': 'USA', 'cases': 50000, 'deaths': 3000},
          {'country': 'China', 'cases': 80000, 'deaths': 4000},
        ];
        when(mockDioClient.get(any)).thenAnswer(countries);
      });

      // 验证：Repository 使用正确
        final repository = CovidRepositoryImpl(mockLogger);
        expect(mockDioClient.get(any)).called(2);
        expect(repository.getGlobalData()).called(2);
        expect(repository.getGlobalData()).calledTimes(2);
      });
    });
  });
}
