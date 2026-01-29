import 'package:flutter/material.dart';
import '../widgets/drawer.dart';

/// 测试 Demo 页面（Test Demo Screen）
/// 用于测试和学习 Flutter 功能
class TestDemoScreen extends StatefulWidget {
  const TestDemoScreen({super.key});

  @override
  State<TestDemoScreen> createState() => _TestDemoScreenState();
}

class _TestDemoScreenState extends State<TestDemoScreen> {
  int _counter = 0;

  final List<String> tabs = const ['风画庭', '雨韵舍', '雷鸣殿', '电疾堂', '霜寒阁', '雪月楼'];

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('测试 Demo'),
        centerTitle: true,
      ),

      // 侧边栏导航
      drawer: const AppDrawer(),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              '这是一个测试 Demo 页面',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '可以在这里进行各种测试和学习',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 40),
            Text(
              '按钮点击次数:',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$_counter',
              style: const TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _incrementCounter,
                  icon: const Icon(Icons.add),
                  label: const Text('增加'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                OutlinedButton.icon(
                  onPressed: _resetCounter,
                  icon: const Icon(Icons.refresh),
                  label: const Text('重置'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Card(
              margin: EdgeInsets.symmetric(horizontal: 32),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '提示：',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('• 点击侧边栏菜单可导航到其他页面'),
                    Text('• 可以在这里测试各种 Flutter 组件'),
                    Text('• 修改此页面来学习 Flutter 开发'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: '增加',
        child: const Icon(Icons.add),
      ),
    );
  }
}
