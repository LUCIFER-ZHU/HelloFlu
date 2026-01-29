import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'providers/providers.dart';

/// 应用程序入口
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 加载环境变量（默认读取 .env 文件）
  await dotenv.load(fileName: '.env');

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

/// 主应用组件
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return MaterialApp.router(
      // 应用标题
      title: 'COVID-19 追踪器',

      // 隐藏调试横幅
      debugShowCheckedModeBanner: false,

      // 路由配置
      routerConfig: ref.watch(routerProvider),

      // 主题配置（从 Provider 获取）
      theme: theme,
    );
  }
}
