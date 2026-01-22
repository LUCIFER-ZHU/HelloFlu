import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../config/constants.dart';
import '../config/colors.dart';
import '../widgets/graph.dart';

/// 主页面（Home Screen）
/// 显示全球COVID-19统计数据
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, dynamic>> _globalDataFuture;

  // 缓存转换后的时间线数据，避免在build中重复计算
  List<Map<String, dynamic>> _cachedCasesData = [];
  List<Map<String, dynamic>> _cachedDeathsData = [];
  List<Map<String, dynamic>> _cachedRecoveredData = [];

  @override
  void initState() {
    super.initState();
    _globalDataFuture = ApiService.getGlobalData();
  }

  /// 异步加载历史数据
  Future<Map<String, dynamic>> _loadHistoricalData() async {
    try {
      print('开始加载历史数据...');
      final data = await ApiService.getCountryHistoricalData(
          AppConstants.defaultCountry);
      print('历史数据加载成功');

      // 检查数据格式
      if (data.containsKey('timeline') && data['timeline'] is Map) {
        final timeline = data['timeline'] as Map<String, dynamic>;
        // 对于有省份数据的国家（如中国），提取第一个省份的数据
        if (timeline.containsKey('cases') &&
            timeline['cases'] is Map &&
            (timeline['cases'] as Map).isNotEmpty) {
          print('找到timeline数据，直接使用');

          // 在数据加载时立即转换并缓存，避免在build中重复计算
          print('开始转换时间线数据...');
          _cachedCasesData = _transformTimelineData(timeline['cases']);
          _cachedDeathsData = _transformTimelineData(timeline['deaths']);
          _cachedRecoveredData = _transformTimelineData(timeline['recovered']);
          print('数据转换完成，cases: ${_cachedCasesData?.length}, '
              'deaths: ${_cachedDeathsData?.length}, '
              'recovered: ${_cachedRecoveredData?.length}');

          return data;
        }
      }

      return data;
    } catch (e) {
      print('加载历史数据失败: $e');
      rethrow; // 重新抛出异常，让FutureBuilder捕获并显示错误
    }
  }

  /// 加载全球数据
  Future<void> _loadData() async {
    try {
      setState(() {
        _globalDataFuture = ApiService.getGlobalData();
      });
      await _globalDataFuture;
    } catch (e) {
      print('加载数据失败: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('全球疫情数据'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadData(),
            tooltip: '刷新数据',
          ),
        ],
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
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('国家列表'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/countries');
              },
            ),
          ],
        ),
      ),

      body: RefreshIndicator(
        onRefresh: () => _loadData(),
        child: FutureBuilder<Map<String, dynamic>>(
          future: Future.wait([
            _globalDataFuture,
            _loadHistoricalData(),
          ]).then((values) {
            return {
              'global': values[0],
              'historical': values[1],
            };
          }),
          builder: (context, snapshot) {
            print('FutureBuilder 状态: ${snapshot.connectionState}');
            if (snapshot.hasError) {
              print('FutureBuilder 错误: ${snapshot.error}');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('正在加载COVID-19数据...'),
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
                      Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => _loadData(),
                        child: const Text('重新加载'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final data = snapshot.data;
            if (data == null) {
              return const Center(
                child: Text('没有可用数据'),
              );
            }

            final globalData = data['global'] as Map<String, dynamic>;
            final historicalData = data['historical'] as Map<String, dynamic>;

            print('全球数据加载成功，构建主页内容');
            print('globalData 长度: ${globalData.length}');
            print('historicalData 是否为空: ${historicalData.isEmpty}');
            // 全局数据和历史数据都已加载成功
            return _buildHomeContent(context, globalData, historicalData);
          },
        ),
      ),
    );
  }

  /// 构建首页内容（全球统计 + 图表）
  Widget _buildHomeContent(
    BuildContext context,
    Map<String, dynamic> globalData,
    Map<String, dynamic> historicalData,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            '全球COVID-19统计',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // 统计卡片网格
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildStatCard(
                  '总确诊', globalData['cases'].toString(), Colors.blue),
              _buildStatCard('死亡', globalData['deaths'].toString(), Colors.red),
              _buildStatCard(
                  '康复', globalData['recovered'].toString(), Colors.green),
              _buildStatCard(
                  '活跃', globalData['active'].toString(), Colors.orange),
              _buildStatCard('受影响国家',
                  globalData['affectedCountries'].toString(), Colors.purple),
              _buildStatCard(
                  '检测次数', _formatNumber(globalData['tests']), Colors.teal),
            ],
          ),
          const SizedBox(height: 30),

          // 中国疫情趋势图表
          _buildChartsSection(historicalData),

          const SizedBox(height: 20),

          // 更新时间
          Text(
            '最后更新: ${_formatUpdateTime(globalData['updated'])}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建统计卡片
  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 格式化大数字
  String _formatNumber(dynamic number) {
    if (number == null) return '0';
    final numValue =
        number is num ? number : num.tryParse(number.toString()) ?? 0;

    if (numValue >= 1000000) {
      return '${(numValue / 1000000).toStringAsFixed(1)}M';
    } else if (numValue >= 1000) {
      return '${(numValue / 1000).toStringAsFixed(1)}K';
    }
    return numValue.toString();
  }

  /// 格式化更新时间
  String _formatUpdateTime(dynamic timestamp) {
    if (timestamp == null) return '';
    final intValue =
        timestamp is int ? timestamp : int.tryParse(timestamp.toString()) ?? 0;
    final date = DateTime.fromMillisecondsSinceEpoch(intValue);
    return date.toString().substring(0, 19);
  }

  /// 构建图表区域
  Widget _buildChartsSection(Map<String, dynamic> historicalData) {
    print('_buildChartsSection 被调用');
    print('historicalData 是否为空: ${historicalData.isEmpty}');

    // 如果没有历史数据，显示提示信息
    if (historicalData.isEmpty || historicalData['timeline'] == null) {
      print('历史数据为空，显示加载提示');
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                '正在加载历史数据...',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                '（如果长时间未加载，请检查网络连接）',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // 使用缓存的数据，避免重复计算
    final casesData = _cachedCasesData;
    final deathsData = _cachedDeathsData;
    final recoveredData = _cachedRecoveredData;
    print('使用缓存数据: cases: ${casesData?.length}, '
        'deaths: ${deathsData?.length}, '
        'recovered: ${recoveredData?.length}');

    // 如果转换后数据为空，提示用户
    if (casesData.isEmpty && deathsData.isEmpty && recoveredData.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            '暂无历史数据',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: [
        const Text(
          '中国疫情趋势',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),

        // 确诊病例图表
        if (casesData.isNotEmpty)
          CovidGraph(
            timelineData: casesData,
            title: '每日新增确诊病例',
            graphColor: AppColors.casesGraph,
          ),
        // if (casesData.isNotEmpty) const SizedBox(height: 30),

        // // 死亡病例图表
        // if (deathsData.isNotEmpty)
        //   CovidGraph(
        //     timelineData: deathsData,
        //     title: '每日新增死亡病例',
        //     graphColor: AppColors.deathsGraph,
        //   ),
        // if (deathsData.isNotEmpty) const SizedBox(height: 30),

        // // 康复病例图表
        // if (recoveredData.isNotEmpty)
        //   CovidGraph(
          //   timelineData: recoveredData,
          //   title: '每日新增康复病例',
          //   graphColor: AppColors.recoveredGraph,
          // ),
      ],
    );
  }

  /// 转换时间线数据格式
  List<Map<String, dynamic>> _transformTimelineData(dynamic timelineData) {
    print('_transformTimelineData 被调用，参数类型: ${timelineData.runtimeType}');
    if (timelineData == null) {
      print('timelineData 为 null');
      return [];
    }
    if (timelineData is! Map) {
      print('timelineData 不是 Map，实际类型: ${timelineData.runtimeType}');
      return [];
    }

    print('开始遍历 timelineData，条目数: ${(timelineData as Map).length}');
    final result = <Map<String, dynamic>>[];
    timelineData.forEach((key, value) {
      try {
        // 解析日期 (MM/DD/YY 格式)
        final dateParts = key.split('/');
        if (dateParts.length == 3) {
          final month = int.parse(dateParts[0]);
          final day = int.parse(dateParts[1]);
          final year = 2000 + int.parse(dateParts[2]); // 转换为4位年份

          result.add({
            'date': DateTime(year, month, day),
            'value': (value as num).toInt(),
          });
        }
      } catch (e) {
        // 跳过无效数据
        print('解析数据失败: $e, key: $key, value: $value');
      }
    });

    print('转换完成，有效数据条目数: ${result.length}');

    // 按日期排序
    result.sort(
        (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    // 数据采样：如果数据点超过100个，进行下采样
    const maxDataPoints = 100;
    if (result.length > maxDataPoints) {
      print('数据点过多 (${result.length})，进行下采样到 $maxDataPoints 个点');
      final step = result.length / maxDataPoints;
      final sampled = <Map<String, dynamic>>[];
      for (int i = 0; i < maxDataPoints; i++) {
        final index = (i * step).floor();
        if (index < result.length) {
          sampled.add(result[index]);
        }
      }
      // 确保最后一个数据点总是包含在内
      sampled.add(result.last);
      print('采样后数据点数: ${sampled.length}');
      return sampled;
    }

    return result;
  }
}
