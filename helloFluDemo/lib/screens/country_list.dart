import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/country_list_notifier.dart';
import '../providers/country_search_providers.dart';
import '../widgets/drawer.dart';

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
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(countrySearchQueryProvider),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<dynamic>> countriesAsync = ref.watch(
      filteredCountriesProvider,
    );
    final String searchQuery = ref.watch(countrySearchQueryProvider);

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
        ],
      ),

      // 侧边栏导航
      drawer: const AppDrawer(),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (String value) {
                ref.read(countrySearchQueryProvider.notifier).state = value;
              },
              decoration: InputDecoration(
                hintText: '搜索国家...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          ref.read(countrySearchQueryProvider.notifier).state =
                              '';
                        },
                        icon: const Icon(Icons.clear),
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
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
                data: (List<dynamic> countriesData) {
                  if (countriesData.isEmpty) {
                    return Center(
                      child: Text(
                        searchQuery.isEmpty ? '暂无国家数据' : '未找到匹配的国家',
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: countriesData.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Map<String, dynamic> countryData =
                          countriesData[index] as Map<String, dynamic>;
                      final String countryName =
                          countryData['country'] as String? ?? 'Unknown';
                      final int cases = countryData['cases'] as int? ?? 0;
                      final int deaths = countryData['deaths'] as int? ?? 0;
                      final String? flag =
                          countryData['countryInfo']?['flag'] as String?;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ListTile(
                          leading: flag != null && flag.isNotEmpty
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
          ),
        ],
      ),
    );
  }
}
