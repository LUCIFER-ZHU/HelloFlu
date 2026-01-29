import 'package:flutter/material.dart';
import 'screens/test_demo.dart';
import 'screens/global_stats.dart';
import 'screens/country_list.dart';

/// 应用程序入口
void main() => runApp(const MyApp());

/// 主应用组件
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 应用标题
      title: 'COVID-19 追踪器',
      
      // 隐藏调试横幅
      debugShowCheckedModeBanner: false,
      
      // 简化的主题配置
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
      ),
      
      // 简化的路由配置
      initialRoute: '/',
      routes: {
        '/': (context) => const TestDemoScreen(),
        '/test-demo': (context) => const TestDemoScreen(),
        '/global-stats': (context) => const GlobalStatsScreen(),
        '/countries': (context) => const CountryListScreen(),
      },
    );
  }
}
