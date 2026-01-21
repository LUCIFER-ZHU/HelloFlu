import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// 主页面（Home Screen）
/// 显示全球COVID-19统计数据
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<Map<String, dynamic>> _globalDataFuture;

  @override
  void initState() {
    super.initState();
    _loadGlobalData();
  }

  /// 加载全球数据
  Future<void> _loadGlobalData() {
    setState(() {
      _globalDataFuture = ApiService.getGlobalData();
    });
    return _globalDataFuture;
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
            onPressed: () => _loadGlobalData(),
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
        onRefresh: () => _loadGlobalData(),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _globalDataFuture,
          builder: (context, snapshot) {
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
                        onPressed: () => _loadGlobalData(),
                        child: const Text('重新加载'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final data = snapshot.data;
            if (data == null || data.isEmpty) {
              return const Center(
                child: Text('没有可用数据'),
              );
            }

            return _buildGlobalStats(context, data);
          },
        ),
      ),
    );
  }

  /// 构建全球统计数据展示
  Widget _buildGlobalStats(BuildContext context, Map<String, dynamic> data) {
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
              _buildStatCard('总确诊', data['cases'].toString(), Colors.blue),
              _buildStatCard('死亡', data['deaths'].toString(), Colors.red),
              _buildStatCard('康复', data['recovered'].toString(), Colors.green),
              _buildStatCard('活跃', data['active'].toString(), Colors.orange),
              _buildStatCard('受影响国家', data['affectedCountries'].toString(), Colors.purple),
              _buildStatCard('检测次数', _formatNumber(data['tests']), Colors.teal),
            ],
          ),
          const SizedBox(height: 20),

          // 更新时间
          Text(
            '最后更新: ${_formatUpdateTime(data['updated'])}',
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
}
