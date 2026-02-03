import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../screens/global_stats.dart';
import '../screens/country_list.dart';

part 'router.g.dart';

/// 路由配置 Provider（Generated）
/// 
/// 提供应用路由配置
/// 包含所有页面路由定义和错误页面处理
@riverpod
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const GlobalStatsScreen(),
      ),
      GoRoute(
        path: '/global-stats',
        name: 'globalStats',
        builder: (context, state) => const GlobalStatsScreen(),
      ),
      GoRoute(
        path: '/countries',
        name: 'countries',
        builder: (context, state) => const CountryListScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              '页面不存在: ${state.uri}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    ),
  );
}
