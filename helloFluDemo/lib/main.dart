import 'package:flutter/material.dart';
import 'screens/home.dart';
import 'screens/country_list.dart';
import 'config/colors.dart';
import 'config/constants.dart';

/// 应用程序入口
void main() => runApp(const MyApp());

/// 主应用组件
///
/// 配置整个应用的主题、路由和初始页面
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 应用标题
      title: AppConstants.appName,

      // 调试横幅（显示在开发模式下）
      debugShowCheckedModeBanner: false,

      // 应用主题配置
      theme: ThemeData(
        // 主色调
        primarySwatch: AppColors.primary,

        // 强调色
        colorScheme: ColorScheme.fromSwatch(
          AppColors.primary,
          brightness: Brightness.dark,
          accentColor: AppColors.accent,
        ),

        // 深色模式
        brightness: Brightness.dark,

        // 文本主题
        textTheme: TextTheme(
          headline6: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          bodyText2: TextStyle(
            fontSize: 16,
          ),
        ),

        // 使用Material Design
        useMaterial3: false,

        // 应用栏主题
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 4,
        ),

        // 卡片主题
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),

      // 初始路由
      initialRoute: '/',

      // 路由配置
      routes: {
        '/': (context) => const HomeScreen(),
        '/home': (context) => const HomeScreen(),
        '/countries': (context) => const CountryListScreen(),
      },

      // 未找到路由时的处理
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text('页面未找到')),
            body: Center(
              child: Text('404 - 页面不存在'),
            ),
          ),
        );
      },
    );
  }
}
