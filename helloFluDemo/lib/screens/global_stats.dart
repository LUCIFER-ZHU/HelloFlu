import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/colors.dart';
import '../presenters/global_stats_presenter.dart';
import '../widgets/graph.dart';
import '../widgets/drawer.dart';
import '../providers/global_stats_notifier.dart';

/// 全球统计页面（Global Stats Screen）
/// 显示全球COVID-19统计数据和图表
///
/// 使用 Riverpod 进行状态管理
/// Web 对比：类似 React + Context API + useQuery
class GlobalStatsScreen extends ConsumerWidget {
  const GlobalStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          final String historicalCountry =
              data['country'] as String? ??
              historicalData?['country'] as String? ??
              'China';

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
                      _buildStatCard(
                        '检测次数',
                        GlobalStatsPresenter.formatNumber(globalData['tests']),
                        Colors.teal,
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // 中国疫情趋势图表
                  if (historicalData != null)
                    _buildChartsSection(historicalData, historicalCountry),

                  const SizedBox(height: 20),

                  // 更新时间
                  Text(
                    '最后更新: ${GlobalStatsPresenter.formatUpdateTime(globalData['updated'])}',
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
  Widget _buildChartsSection(
    Map<String, dynamic> historicalData,
    String country,
  ) {
    final Map<String, dynamic>? timelineMap =
        GlobalStatsPresenter.getTimeline(historicalData);
    if (timelineMap == null || timelineMap.isEmpty) {
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

    final List<Map<String, dynamic>> casesData =
        GlobalStatsPresenter.transformTimelineData(timelineMap['cases']);
    final List<Map<String, dynamic>> deathsData =
        GlobalStatsPresenter.transformTimelineData(timelineMap['deaths']);
    final List<Map<String, dynamic>> recoveredData =
        GlobalStatsPresenter.transformTimelineData(timelineMap['recovered']);

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
        Text(
          '$country 疫情趋势',
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
}
