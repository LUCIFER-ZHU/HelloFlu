import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/info_card.dart';
import '../widgets/graph.dart';
import '../widgets/drawer.dart';
import '../config/colors.dart';
import '../config/constants.dart';
import '../models/covid_models.dart';

/// 主页面（Home Screen）
///
/// 显示全球COVID-19统计数据和特定国家的趋势图表
/// 用户可以通过下拉刷新获取最新数据
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 侧边栏（Drawer）
      drawer: const AppDrawer(),

      // 应用栏
      appBar: AppBar(
        title: Text(
          AppConstants.titleHome,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 4,
      ),

      // 主体内容
      body: RefreshIndicator(
        // 下拉刷新功能
        onRefresh: () async {
          // 通过重新导航到当前页面来实现刷新
          await Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) =>
                  const HomeScreen(),
              transitionDuration: Duration(milliseconds: 300),
            ),
          );
        },
        color: AppColors.primary,
        child: FutureBuilder<Map<String, dynamic>>(
          // 异步获取数据
          future: ApiService.getAllData(
            country: AppConstants.defaultCountry,
          ),
          builder: (context, snapshot) {
            // 状态1：数据加载中 - 显示加载指示器
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 4,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '正在加载数据...',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            // 状态2：发生错误 - 显示错误信息
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.errorText,
                      ),
                      SizedBox(height: 16),
                      Text(
                        AppConstants.errorNetworkConnection,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.errorText,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          // 点击按钮重新加载页面
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, a1, a2) =>
                                  const HomeScreen(),
                            ),
                          );
                        },
                        child: Text('重试'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // 状态3：数据加载成功 - 显示内容
            final data = snapshot.data;

            // 如果数据为空
            if (data == null || data.isEmpty) {
              return Center(
                child: Text(
                  '没有可用数据',
                  style: TextStyle(color: AppColors.white),
                ),
              );
            }

            // 解析全球统计数据
            final globalStats =
                GlobalStats.fromJson(jsonDecode(data['all'] as String));

            // 解析特定国家的历史数据
            final dailyCases = data['country'] as List<Map<String, dynamic>>;
            final dailyDeaths = data['deaths'] as List<Map<String, dynamic>>;
            final dailyRecoveries =
                data['recovered'] as List<Map<String, dynamic>>;

            return _buildContent(
              context,
              globalStats,
              dailyCases,
              dailyDeaths,
              dailyRecoveries,
            );
          },
        ),
      ),
    );
  }

  /// 构建页面主要内容
  Widget _buildContent(
    BuildContext context,
    GlobalStats globalStats,
    List<Map<String, dynamic>> dailyCases,
    List<Map<String, dynamic>> dailyDeaths,
    List<Map<String, dynamic>> dailyRecoveries,
  ) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: Column(
        children: [
          SizedBox(height: 10.0),

          // 第一部分：全球统计卡片（网格布局）
          Text(
            "全球统计数据",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height * 0.025,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: 15.0),

          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2, // 两列布局
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              // 6个信息卡片
              InfoCard(
                title: "总确诊",
                number: globalStats.cases.toString(),
              ),
              InfoCard(
                title: "死亡",
                number: globalStats.deaths.toString(),
                backgroundColor: AppColors.deathsGraph,
              ),
              InfoCard(
                title: "康复",
                number: globalStats.recovered.toString(),
                backgroundColor: AppColors.recoveredGraph,
              ),
              InfoCard(
                title: "活跃",
                number: globalStats.active.toString(),
              ),
              InfoCard(
                title: "更新时间",
                number: _formatTimestamp(globalStats.updated),
                backgroundColor: AppColors.accent,
              ),
              InfoCard(
                title: "受影响国家",
                number: globalStats.affectedCountries.toString(),
                backgroundColor: AppColors.primary,
              ),
            ],
          ),
          SizedBox(height: 30.0),

          // 第二部分：特定国家的趋势图表
          Divider(
            color: AppColors.white.withOpacity(0.2),
            thickness: 1,
          ),
          SizedBox(height: 20.0),

          Text(
            "${AppConstants.defaultCountry} 每日趋势",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height * 0.03,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: 20.0),

          // 每日确诊病例图表
          CovidGraph(
            timelineData: dailyCases,
            title: "每日确诊病例",
            graphColor: AppColors.casesGraph,
          ),
          SizedBox(height: 25.0),

          // 每日死亡病例图表
          CovidGraph(
            timelineData: dailyDeaths,
            title: "每日死亡病例",
            graphColor: AppColors.deathsGraph,
          ),
          SizedBox(height: 25.0),

          // 每日康复病例图表
          CovidGraph(
            timelineData: dailyRecoveries,
            title: "每日康复病例",
            graphColor: AppColors.recoveredGraph,
          ),
          SizedBox(height: 30.0),
        ],
      ),
    );
  }

  /// 格式化时间戳
  ///
  /// 将Unix时间戳转换为易读的格式
  String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}
