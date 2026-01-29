import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/colors.dart';
import '../widgets/graph.dart';
import '../widgets/drawer.dart';
import '../providers/providers.dart';

/// 全球统计页面（Global Stats Screen）
/// 显示全球COVID-19统计数据和图表
///
/// 使用 Riverpod 进行状态管理
/// Web 对比：类似 React + Context API + useQuery
class GlobalStatsScreen extends ConsumerStatefulWidget {
  const GlobalStatsScreen({super.key});

  @override
  ConsumerState<GlobalStatsScreen> createState() => _GlobalStatsScreenState();
}

class _GlobalStatsScreenState extends ConsumerState<GlobalStatsScreen> {
  late final String defaultCountry;

  @override
  void initState() {
    super.initState();
    defaultCountry = ref.read(defaultCountryProvider);

    // 延迟加载历史数据，避免阻塞 UI
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(globalStatsProvider.notifier).loadHistoricalData(defaultCountry);
    });
  }

  /// 格式化大数字
  String _formatNumber(dynamic number) {
    if (number == null) return '0';
    final numValue = number is num ? number : num.tryParse(number.toString()) ?? 0;

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
    final intValue = timestamp is int ? timestamp : int.tryParse(timestamp.toString()) ?? 0;
    final date = DateTime.fromMillisecondsSinceEpoch(intValue);
    return date.toString().substring(0, 19);
  }

  @override
  Widget build(BuildContext context) {
    final globalStatsAsync = ref.watch(globalStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('全球疫情数据'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(globalStatsProvider.notifier).refresh();
            },
            tooltip: '刷新数据',
          ),
        ],
      ),

      // 侧边栏导航
      drawer: const AppDrawer(),

      body: globalStatsAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('正在加载COVID-19数据...'),
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
                    ref.read(globalStatsProvider.notifier).refresh();
                  },
                  child: const Text('重新加载'),
                ),
              ],
            ),
          ),
        ),
        data: (data) {
          final globalData = data['global'] as Map<String, dynamic>?;
          final historicalData = data['historical'] as Map<String, dynamic>?;

          if (globalData == null) {
            return const Center(
              child: Text('没有可用数据'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(globalStatsProvider.notifier).refresh();
            },
            child: SingleChildScrollView(
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
                      _buildStatCard('总确诊', globalData['cases'].toString(), Colors.blue),
                      _buildStatCard('死亡', globalData['deaths'].toString(), Colors.red),
                      _buildStatCard('康复', globalData['recovered'].toString(), Colors.green),
                      _buildStatCard('活跃', globalData['active'].toString(), Colors.orange),
                      _buildStatCard('受影响国家', globalData['affectedCountries'].toString(), Colors.purple),
                      _buildStatCard('检测次数', _formatNumber(globalData['tests']), Colors.teal),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // 中国疫情趋势图表
                  if (historicalData != null) _buildChartsSection(historicalData),

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
            ),
          );
        },
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
            colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.1)],
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

  /// 构建图表区域
  Widget _buildChartsSection(Map<String, dynamic> historicalData) {
    if (!historicalData.containsKey('timeline')) {
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

    final timeline = historicalData['timeline'] as Map<String, dynamic>?;
    if (timeline == null || timeline.isEmpty) {
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

    final casesData = _transformTimelineData(timeline['cases'] as Map<String, dynamic>?);
    final deathsData = _transformTimelineData(timeline['deaths'] as Map<String, dynamic>?);
    final recoveredData = _transformTimelineData(timeline['recovered'] as Map<String, dynamic>?);

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
        if (casesData.isNotEmpty) const SizedBox(height: 30),

        // 死亡病例图表
        if (deathsData.isNotEmpty)
          CovidGraph(
            timelineData: deathsData,
            title: '每日新增死亡病例',
            graphColor: AppColors.deathsGraph,
          ),
        if (deathsData.isNotEmpty) const SizedBox(height: 30),

        // 康复病例图表
        if (recoveredData.isNotEmpty)
          CovidGraph(
            timelineData: recoveredData,
            title: '每日新增康复病例',
            graphColor: AppColors.recoveredGraph,
          ),
      ],
    );
  }

  /// 转换时间线数据格式
  List<Map<String, dynamic>> _transformTimelineData(Map<String, dynamic>? timelineData) {
    if (timelineData == null || timelineData.isEmpty) return [];

    final result = <Map<String, dynamic>>[];
    timelineData.forEach((key, value) {
      try {
        final dateParts = key.split('/');
        if (dateParts.length == 3) {
          final month = int.parse(dateParts[0]);
          final day = int.parse(dateParts[1]);
          final year = 2000 + int.parse(dateParts[2]);

          result.add({
            'date': DateTime(year, month, day),
            'value': (value as num).toInt(),
          });
        }
      } catch (e) {
        // 跳过无效数据
      }
    });

    // 按日期排序
    result.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

    // 数据采样：如果数据点超过100个，进行下采样
    const maxDataPoints = 100;
    if (result.length > maxDataPoints) {
      final step = result.length / maxDataPoints;
      final sampled = <Map<String, dynamic>>[];
      for (int i = 0; i < maxDataPoints; i++) {
        final index = (i * step).floor();
        if (index < result.length) {
          sampled.add(result[index]);
        }
      }
      sampled.add(result.last);
      return sampled;
    }

    return result;
  }
}
