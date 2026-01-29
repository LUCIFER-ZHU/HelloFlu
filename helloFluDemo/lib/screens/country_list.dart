import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../widgets/drawer.dart';
import 'country_search.dart';

/// 国家列表页面（Country List Screen）
/// 显示所有受影响国家的COVID-19数据
///
/// 使用 Riverpod 进行状态管理
/// Web 对比：类似 React + Context API + useQuery
class CountryListScreen extends ConsumerStatefulWidget {
  const CountryListScreen({super.key});

  @override
  ConsumerState<CountryListScreen> createState() => _CountryListScreenState();
}

class _CountryListScreenState extends ConsumerState<CountryListScreen> {
  @override
  Widget build(BuildContext context) {
    final countriesAsync = ref.watch(countriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('受影响的国家'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(countriesProvider.notifier).refresh();
            },
            tooltip: '刷新数据',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              final countries = countriesAsync.maybeWhen(
                data: (data) => data,
                orElse: () => [],
              );
              showSearch(
                context: context,
                delegate: CountrySearchDelegate(countries),
              );
            },
            tooltip: '搜索国家',
          ),
        ],
      ),

      // 侧边栏导航
      drawer: const AppDrawer(),

      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(countriesProvider.notifier).refresh();
        },
        child: countriesAsync.when(
          loading: () => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('正在加载国家数据...'),
              ],
            ),
          ),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '数据加载失败',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(countriesProvider.notifier).refresh();
                    },
                    child: const Text('重新加载'),
                  ),
                ],
              ),
            ),
          ),
          data: (countriesData) {
            if (countriesData.isEmpty) {
              return const Center(
                child: Text('暂无国家数据'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: countriesData.length,
              itemBuilder: (context, index) {
                final countryData = countriesData[index] as Map<String, dynamic>;
                final countryName = countryData['country'] as String;
                final cases = countryData['cases'] as int;
                final deaths = countryData['deaths'] as int;
                final flag = countryData['countryInfo']?['flag'] as String?;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                    leading: flag != null
                        ? Image.network(
                            flag,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          )
                        : const SizedBox(width: 40, height: 40),
                    title: Text(countryName),
                    subtitle: Text('确诊: $cases, 死亡: $deaths'),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
