import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// 国家列表页面（Country List Screen）
/// 显示所有受影响国家的COVID-19数据
class CountryListScreen extends StatelessWidget {
  const CountryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('受影响的国家'),
        centerTitle: true,
      ),
      
      // 侧边栏导航
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'COVID-19 追踪器',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('首页'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/');
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('国家列表'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),

      body: FutureBuilder<List<dynamic>>(
        future: ApiService.getAllCountriesData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('正在加载国家数据...'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
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
                    Text(snapshot.error.toString()),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // 重新加载页面
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const CountryListScreen()),
                        );
                      },
                      child: const Text('重新加载'),
                    ),
                  ],
                ),
              ),
            );
          }

          final countriesData = snapshot.data;
          if (countriesData == null || countriesData.isEmpty) {
            return const Center(
              child: Text('暂无国家数据'),
            );
          }

          // 构建国家列表
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
                  leading: flag != null ? Image.network(
                    flag,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ) : const SizedBox(width: 40, height: 40),
                  title: Text(countryName),
                  subtitle: Text('确诊: $cases, 死亡: $deaths'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
