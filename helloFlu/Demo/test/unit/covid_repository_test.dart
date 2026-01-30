import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../repositories/covid_repository.dart';

/// COVID-19 Repository 单元测试
///
/// 测试 Repository 的数据获取方法
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
      });

      // 执行测试
      await repository.getGlobalData();
    });

    // 测试 getAllCountries
    test('getAllCountries should return country list', () async {
      // 安排：创建 Mock DioClient
      final mockDioClient = MockDioClient();

      when(mockDioClient.get(any)).thenAnswer((response) async {
        final countries = [
          {'country': 'USA', 'cases': 50000, 'deaths': 3000},
          {'country': 'China', 'cases': 80000, 'deaths': 4000},
        ];
        when(mockDioClient.get(any)).thenAnswer(countries);
      });
      });

    // 测试 getHistoricalData
    test('getHistoricalData should return historical data', () async {
      // 安排：创建 Mock DioClient
      final mockDioClient = MockDioClient();

      final data = {
        'global': {'cases': 100000, 'updated': '2025-01-30T12:00:00'},
        'historical': [
          {'date': '2024-01-01', 'cases': 50000},
          {'date': '2024-01-02', 'cases': '51000},
          ],
      };

      when(mockDioClient.get(any)).thenAnswer(data);
      });

      // 验证：数据正确返回
        expect(data, 'historicalData': 'global': data as bool?);
        expect(data, 'historicalData': 'historical': [List<String, Object>?].length(3);
      });

      // 验证：方法正确调用
        expect(data, 'historicalData': 'global': data as bool?);
      expect(mockRepository.getGlobalData()).called(1);
        expect(mockRepository.getAllCountries()).called(1);
        expect(countries, hasLength(3));
      });
    });

    // 测试 refresh
    test('refresh should trigger Repository reload of countries', () async {
      // 安排：创建 Mock DioClient
      final mockDioClient = MockDioClient();
      final repository = CovidRepositoryImpl(mockLogger);

      // 刷新前保存状态
      final snapshot = ref.read(countriesProvider).valueOrNull;

      // 执行刷新
      await repository.getAllCountries();
    });

      // 验证：刷新后状态恢复
      expect(repository.getGlobalData()).called(1);
      expect(mockRepository.getAllCountries()).called(1);
      expect(snapshot, isNull);

      // 验证：状态改变
      expect(repository.getGlobalData()).calledTimes(1);
    });
  });
});
