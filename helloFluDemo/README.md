# COVID-19 追踪器 🦠

一个使用Flutter开发的COVID-19疫情追踪应用，采用企业级架构和现代化技术栈。本项目不仅适合初学者学习Flutter开发，更是一份完整的企业级Flutter应用最佳实践参考。

**项目状态**: ✅ 生产就绪 | 🏗️ 架构已优化 | 📱 跨平台支持

**当前版本**: v2.0.0（已集成缓存、错误分类、统一日志）

---

## 📚 完整开发指南：从网络数据到界面绘制

本文档提供**详细的端到端示例**，带你完整体验从网络请求 → 数据处理 → 状态管理 → UI展示的完整开发流程。

---

## 完整示例：显示全球疫情统计数据

### 示例目标

实现一个页面，显示全球COVID-19统计数据：
- 从网络API获取数据
- 使用缓存优化性能
- 处理各种错误情况
- 显示加载状态
- 展示数据卡片

### 完整流程图

```
用户打开页面
    │
    ▼
┌─────────────────────────────────────────────────────────┐
│ 第1步：定义数据层（Repository）                          │
│ 网络请求 + 缓存 + 错误处理                                │
│ lib/repositories/covid_repository.dart                   │
└─────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────┐
│ 第2步：定义状态管理（StateNotifier）                      │
│ 管理异步状态（loading/data/error）                       │
│ lib/notifiers/global_stats_notifier.dart                 │
└─────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────┐
│ 第3步：注册Provider（依赖注入）                          │
│ lib/providers/providers.dart                             │
└─────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────┐
│ 第4步：创建UI页面（Screen）                              │
│ 显示数据卡片                                             │
│ lib/screens/global_stats_demo.dart                       │
└─────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────┐
│ 第5步：添加到路由                                        │
│ lib/providers/providers.dart (routerProvider)            │
└─────────────────────────────────────────────────────────┘
```

---

## 第1步：定义数据层（Repository）

### 1.1 定义接口（抽象）

**文件**: `lib/repositories/covid_repository.dart`

```dart
/// COVID-19 数据仓库接口
///
/// 定义数据访问的抽象层，便于测试和Mock
abstract class CovidRepository {
  /// 获取全球统计数据
  Future<Map<String, dynamic>> getGlobalData();
  
  /// 获取所有国家数据
  Future<List<dynamic>> getAllCountries();
  
  /// 获取指定国家历史数据
  Future<Map<String, dynamic>> getHistoricalData(String country);
}
```

### 1.2 实现数据层（含缓存和错误处理）

**文件**: `lib/repositories/covid_repository.dart`（接口和实现在同一文件）

```dart
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';
import '../core/cache/cache_manager.dart';
import '../core/errors/app_error.dart';
import '../core/network/dio_client.dart';
import '../config/app_config.dart';
import 'covid_repository.dart';

/// 仓库实现类 - 包含缓存和错误处理
class CovidRepositoryImpl implements CovidRepository {
  final Logger _logger;
  final CacheManager _cacheManager;

  CovidRepositoryImpl(this._logger) : _cacheManager = CacheManager() {
    _cacheManager.initialize();
  }

  @override
  Future<Map<String, dynamic>> getGlobalData() async {
    const cacheKey = 'global_data';

    // 1️⃣ 先检查缓存
    final cached = _cacheManager.get<Map<String, dynamic>>(cacheKey);
    if (cached != null) {
      _logger.i('✅ 全球数据从缓存获取');
      return cached;
    }

    // 2️⃣ 缓存未命中，请求API
    _logger.i('🌐 开始获取全球数据');
    try {
      final response = await DioClient.dio.get(
        AppConfig.endpointGlobal,
      );
      final data = response.data as Map<String, dynamic>;

      // 3️⃣ 保存到缓存（30分钟后过期）
      await _cacheManager.set(cacheKey, data);

      _logger.i('✅ 全球数据获取成功，病例数: ${data['cases']}');
      return data;
    } on DioException catch (e) {
      _logger.e('❌ 网络请求失败: $e');
      // 转换为具体错误类型
      throw ErrorHandler.handleDioError(e);
    } catch (e) {
      _logger.e('❌ 未知错误: $e');
      throw ErrorHandler.handleError(e);
    }
  }

  // 其他方法实现...
  @override
  Future<List<dynamic>> getAllCountries() async {
    const cacheKey = 'all_countries';
    
    final cached = _cacheManager.get<List<dynamic>>(cacheKey);
    if (cached != null) return cached;

    try {
      final response = await DioClient.dio.get(
        AppConfig.endpointCountries(),
      );
      final data = response.data as List<dynamic>;
      await _cacheManager.set(cacheKey, data);
      return data;
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getHistoricalData(String country) async {
    final cacheKey = 'historical_$country';
    
    final cached = _cacheManager.get<Map<String, dynamic>>(cacheKey);
    if (cached != null) return cached;

    try {
      final response = await DioClient.dio.get(
        AppConfig.endpointHistorical(country),
      );
      final data = response.data as Map<String, dynamic>;
      await _cacheManager.set(cacheKey, data);
      return data;
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }
}
```

**关键要点**:
- ✅ 先查缓存，再请求API
- ✅ 使用 `DioException` 捕获网络错误
- ✅ 使用 `ErrorHandler` 转换为用户友好的错误
- ✅ 日志记录完整的数据流向

---

## 第2步：定义状态管理（StateNotifier）

### 2.1 创建 StateNotifier

**文件**: `lib/notifiers/global_stats_notifier.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../core/errors/app_error.dart';
import '../repositories/covid_repository.dart';

/// 全球统计数据状态管理器
///
/// 管理三种状态：
/// - loading: 加载中
/// - data: 数据已加载
/// - error: 加载失败
class GlobalStatsNotifier 
    extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  
  final CovidRepository _repository;
  final Logger _logger;

  GlobalStatsNotifier(this._repository, this._logger) 
      : super(const AsyncValue.loading()) {
    // 初始化时自动加载数据
    loadGlobalData();
  }

  /// 加载全球数据
  Future<void> loadGlobalData() async {
    _logger.i('🔄 开始加载全球数据');
    
    // 设置加载状态
    state = const AsyncValue.loading();

    try {
      // 调用Repository获取数据
      final data = await _repository.getGlobalData();
      
      // 设置数据状态（成功）
      state = AsyncValue.data(data);
      _logger.i('✅ 全球数据加载完成');
    } on AppError catch (e, stackTrace) {
      // 捕获具体的AppError
      _logger.e('❌ 加载失败: ${e.message}');
      state = AsyncValue.error(e, stackTrace);
    } catch (e, stackTrace) {
      // 捕获其他未知错误
      _logger.e('❌ 未知错误: $e');
      state = AsyncValue.error(
        UnknownError(originalError: e), 
        stackTrace,
      );
    }
  }

  /// 刷新数据（强制重新请求，忽略缓存）
  Future<void> refresh() async {
    _logger.i('🔄 刷新全球数据');
    // 清除缓存
    await (_repository as dynamic).clearCache?.call();
    await loadGlobalData();
  }

  /// 获取特定数据字段的便捷方法
  int get cases => state.value?['cases'] ?? 0;
  int get deaths => state.value?['deaths'] ?? 0;
  int get recovered => state.value?['recovered'] ?? 0;
  int get active => state.value?['active'] ?? 0;
}
```

**关键要点**:
- ✅ 使用 `AsyncValue` 管理三种状态
- ✅ 构造函数中自动加载数据
- ✅ 区分 `AppError` 和未知错误
- ✅ 提供便捷方法访问数据字段

---

## 第3步：注册Provider（依赖注入）

### 3.1 在 providers.dart 中注册

**文件**: `lib/providers/providers.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import '../config/app_config.dart';
import '../core/network/dio_client.dart';
import '../notifiers/global_stats_notifier.dart';
import '../repositories/covid_repository.dart';  // 包含接口和实现
import '../screens/global_stats_demo.dart';  // 新增页面

// ===== 第1层：基础服务 Provider =====

/// Logger Provider - 全局日志服务
final loggerProvider = Provider<Logger>((ref) {
  return Logger(
    level: AppConfig.enableLogging ? Level.trace : Level.off,
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
    ),
  );
});

/// 主题 Provider
final themeProvider = Provider<ThemeData>((ref) {
  return AppConfig.darkTheme;
});

// ===== 第2层：数据层 Provider =====

/// Repository Provider - 数据仓库
/// 依赖 loggerProvider
final covidRepositoryProvider = Provider<CovidRepository>((ref) {
  final logger = ref.watch(loggerProvider);
  return CovidRepositoryImpl(logger);
});

// ===== 第3层：状态管理 Provider =====

/// 全球统计数据 Provider
/// 依赖 covidRepositoryProvider 和 loggerProvider
final globalStatsProvider = StateNotifierProvider<
    GlobalStatsNotifier, 
    AsyncValue<Map<String, dynamic>>
>((ref) {
  final repository = ref.watch(covidRepositoryProvider);
  final logger = ref.watch(loggerProvider);
  return GlobalStatsNotifier(repository, logger);
});

// ===== 第4层：路由配置 =====

/// 路由 Provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const GlobalStatsDemoScreen(),
      ),
      // 其他路由...
    ],
  );
});
```

**依赖注入流程**:
```
loggerProvider
    ↓
covidRepositoryProvider (注入logger)
    ↓
globalStatsProvider (注入repository + logger)
    ↓
UI Screen (使用globalStatsProvider)
```

---

## 第4步：创建UI页面（Screen）

### 4.1 实现完整的UI页面

**文件**: `lib/screens/global_stats_demo.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/errors/app_error.dart';
import '../providers/providers.dart';

/// 全球疫情统计演示页面
///
/// 展示完整的从网络到UI的流程：
/// 1. 加载状态显示
/// 2. 数据展示（卡片形式）
/// 3. 错误处理（不同类型错误不同提示）
/// 4. 下拉刷新
class GlobalStatsDemoScreen extends ConsumerWidget {
  const GlobalStatsDemoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听状态
    final statsAsync = ref.watch(globalStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('全球疫情数据'),
        centerTitle: true,
        actions: [
          // 刷新按钮
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(globalStatsProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        // 下拉刷新回调
        onRefresh: () async {
          await ref.read(globalStatsProvider.notifier).refresh();
        },
        // 根据状态显示不同UI
        child: statsAsync.when(
          // 数据加载成功
          data: (data) => _buildDataView(context, data),
          // 加载中
          loading: () => _buildLoadingView(),
          // 加载失败
          error: (error, stackTrace) => _buildErrorView(
            context, 
            error as AppError,
            ref,
          ),
        ),
      ),
    );
  }

  /// 构建数据展示视图
  Widget _buildDataView(BuildContext context, Map<String, dynamic> data) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 标题
          const Text(
            '🌍 全球 COVID-19 统计',
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
            childAspectRatio: 1.2,
            children: [
              _buildStatCard(
                '总确诊',
                data['cases']?.toString() ?? '0',
                Colors.blue,
                Icons.coronavirus,
              ),
              _buildStatCard(
                '死亡',
                data['deaths']?.toString() ?? '0',
                Colors.red,
                Icons.heart_broken,
              ),
              _buildStatCard(
                '康复',
                data['recovered']?.toString() ?? '0',
                Colors.green,
                Icons.healing,
              ),
              _buildStatCard(
                '活跃',
                data['active']?.toString() ?? '0',
                Colors.orange,
                Icons.local_hospital,
              ),
            ],
          ),
          
          const SizedBox(height: 30),
          
          // 更多详情
          _buildDetailCard(data),
        ],
      ),
    );
  }

  /// 构建统计卡片
  Widget _buildStatCard(
    String title, 
    String value, 
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.8),
              color.withOpacity(0.4),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建详情卡片
  Widget _buildDetailCard(Map<String, dynamic> data) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 详细统计',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('今日新增', data['todayCases']?.toString() ?? '0'),
            _buildDetailRow('今日死亡', data['todayDeaths']?.toString() ?? '0'),
            _buildDetailRow('受影响国家', data['affectedCountries']?.toString() ?? '0'),
            _buildDetailRow('检测次数', data['tests']?.toString() ?? '0'),
          ],
        ),
      ),
    );
  }

  /// 构建详情行
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400])),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// 构建加载视图
  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('正在加载全球疫情数据...'),
        ],
      ),
    );
  }

  /// 构建错误视图（支持不同类型错误不同提示）
  Widget _buildErrorView(
    BuildContext context, 
    AppError error, 
    WidgetRef ref,
  ) {
    // 根据错误类型显示不同图标和提示
    IconData icon;
    String subtitle;
    
    switch (error.runtimeType) {
      case NetworkError:
        icon = Icons.wifi_off;
        subtitle = '请检查您的网络连接';
        break;
      case ServerError:
        icon = Icons.cloud_off;
        subtitle = '服务器暂时不可用';
        break;
      case TimeoutError:
        icon = Icons.timer_off;
        subtitle = '请求超时，请稍后重试';
        break;
      default:
        icon = Icons.error_outline;
        subtitle = '发生未知错误';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              error.message,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(globalStatsProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('重新加载'),
            ),
          ],
        ),
      ),
    );
  }
}
```

**关键要点**:
- ✅ 使用 `ConsumerWidget` 监听状态变化
- ✅ `AsyncValue.when()` 处理三种状态
- ✅ 根据错误类型显示不同提示
- ✅ 下拉刷新集成
- ✅ 响应式网格布局

---

## 第5步：应用入口配置

### 5.1 更新 main.dart

**文件**: `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/app_config.dart';
import 'core/network/dio_client.dart';
import 'providers/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1️⃣ 加载环境变量
  await dotenv.load(fileName: '.env');
  
  runApp(
    const ProviderScope(
      child: AppInitializer(),
    ),
  );
}

/// 应用初始化器
/// 配置全局服务
class AppInitializer extends ConsumerWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 2️⃣ 配置 Logger
    final logger = ref.watch(loggerProvider);
    
    // 3️⃣ 配置 DioClient（仅在启用日志时）
    if (AppConfig.enableLogging) {
      DioClient.configure(logger);
    }
    
    return const MyApp();
  }
}

/// 主应用
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'COVID-19 追踪器',
      debugShowCheckedModeBanner: false,
      theme: theme,
      routerConfig: router,
    );
  }
}
```

---

## 完整运行流程演示

### 场景1：首次打开应用（无缓存）

```
1. 用户打开页面
   └─> GlobalStatsNotifier 构造函数调用 loadGlobalData()

2. 检查缓存（未命中）
   └─> Repository 发现缓存为空

3. 发起网络请求
   └─> DioClient 请求 https://disease.sh/v3/covid-19/all
   └─> Logger 输出: "🌐 开始获取全球数据"

4. 请求成功
   └─> Repository 保存数据到缓存
   └─> Logger 输出: "✅ 全球数据获取成功"
   └─> Notifier 更新 state = AsyncValue.data(data)

5. UI 自动重建
   └─> 显示数据卡片
   └─> 显示病例数、死亡数、康复数、活跃数
```

### 场景2：再次打开应用（有缓存）

```
1. 用户打开页面
   └─> 检查缓存（命中！）

2. 立即显示数据
   └─> Logger 输出: "✅ 全球数据从缓存获取"
   └─> UI 瞬间显示，无需等待

3. （可选）后台静默刷新
   └─> 如果缓存过期，自动重新请求API
```

### 场景3：网络错误

```
1. 发起网络请求
   └─> DioException: connectionTimeout

2. Repository 捕获错误
   └─> ErrorHandler 转换为 TimeoutError

3. Notifier 更新状态
   └─> state = AsyncValue.error(TimeoutError(), stackTrace)

4. UI 显示错误页面
   └─> 显示超时图标
   └─> 显示"请求超时，请稍后重试"
   └─> 提供"重新加载"按钮
```

---

## 开发调试技巧

### 查看日志输出

```bash
# 运行应用（显示详细日志）
flutter run

# 过滤查看特定日志lutter run | grep "全球数据"
```

**日志示例**:
```
[GlobalStatsNotifier] 🔄 开始加载全球数据
[CovidRepositoryImpl] ✅ 全球数据从缓存获取
[GlobalStatsNotifier] ✅ 全球数据加载完成
```

### 测试不同场景

```dart
// 在 Repository 中模拟错误来测试错误处理
try {
  // 模拟网络错误
  // throw DioException(requestOptions: RequestOptions(), type: DioExceptionType.connectionTimeout);
  
  // 模拟服务器错误
  // throw DioException(requestOptions: RequestOptions(), response: Response(statusCode: 500));
  
  final response = await DioClient.dio.get(AppConfig.endpointGlobal);
  // ...
}
```

### 验证缓存

```dart
// 在 Repository 中添加调试方法
void printCacheStats() {
  final stats = _cacheManager.getStats();
  _logger.i('缓存统计 - 内存: ${stats['memory']}, 磁盘: ${stats['disk']}');
}
```

---

## 进阶：添加图表展示

### 使用 fl_chart 绘制趋势图

```dart
import 'package:fl_chart/fl_chart.dart';

class TrendChart extends StatelessWidget {
  final List<Map<String, dynamic>> timelineData;
  
  const TrendChart({super.key, required this.timelineData});
  
  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: timelineData.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value['cases'] as double);
            }).toList(),
            isCurved: true,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}
```

---

## 总结

### 完整数据流

```
┌─────────────┐     ┌──────────────┐     ┌──────────────┐
│   UI层      │────▶│  Provider    │────▶│  Notifier    │
│  (Screen)   │◀────│  (Riverpod)  │◀────│  (Business)  │
└─────────────┘     └──────────────┘     └──────────────┘
                                                  │
                                                  ▼
                                        ┌──────────────┐
                                        │  Repository  │
                                        │  (Data层)    │
                                        └──────────────┘
                                                  │
                                       ┌──────────┴──────────┐
                                       ▼                     ▼
                                ┌──────────────┐     ┌──────────────┐
                                │  API (Dio)   │     │  Cache (内存+磁盘)  │
                                └──────────────┘     └──────────────┘
```

### 核心原则

1. **单一职责**: 每层只做一件事
2. **依赖注入**: 通过 Riverpod 管理依赖
3. **缓存优先**: 先查缓存，再请求API
4. **错误分类**: 不同错误不同处理
5. **响应式UI**: 状态驱动界面更新

---

**🎉 恭喜！你已经掌握了企业级Flutter开发的完整流程！**

---

## 主要功能 ✨

| 功能 | 描述 | 技术亮点 |
|------|------|----------|
| **全球疫情概览** | 显示全球累计确诊、死亡、康复、活跃病例等统计数据 | Riverpod StateNotifier + AsyncValue |
| **国家趋势图表** | 使用折线图展示特定国家的每日病例、死亡、康复趋势 | fl_chart + 响应式数据流 |
| **国家列表** | 以折叠列表的形式展示所有受影响国家的详细数据 | ListView.builder + 折叠动画 |
| **搜索功能** | 支持按国家名称实时搜索，快速查看特定国家数据 | SearchDelegate + Riverpod |
| **下拉刷新** | 支持下拉获取最新疫情数据 | RefreshIndicator + AsyncValue |
| **深色主题** | 采用Material Design深色主题，视觉体验良好 | ThemeData + Provider |

---

## 企业级架构 🏗️

### 架构分层图

```
┌─────────────────────────────────────────────┐
│                 Presentation Layer           │
│  ┌─────────────┐ ┌─────────────┐            │
│  │   Screens   │ │   Widgets   │            │
│  │  (UI层)      │ │  (组件层)    │            │
│  └──────┬──────┘ └──────┬──────┘            │
└─────────┼───────────────┼───────────────────┘
          │               │
          ▼               ▼
┌─────────────────────────────────────────────┐
│                 State Layer                  │
│  ┌─────────────────────────────────────┐    │
│  │      Riverpod Providers              │    │
│  │  ┌──────────────┐  ┌──────────────┐  │    │
│  │  │  StateNotifier│  │   FutureProvider  │    │
│  │  └──────────────┘  └──────────────┘  │    │
│  └─────────────────────────────────────┘    │
└─────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────┐
│                 Domain Layer                 │
│  ┌──────────────┐  ┌──────────────┐        │
│  │ Repositories │  │   Services   │        │
│  │  (数据仓库)   │  │   (服务层)    │        │
│  └──────┬───────┘  └──────┬───────┘        │
└─────────┼────────────────┼──────────────────┘
          │                │
          ▼                ▼
┌─────────────────────────────────────────────┐
│                 Data Layer                   │
│  ┌──────────────┐  ┌──────────────┐        │
│  │  DioClient   │  │ SharedPrefs  │        │
│  │  (网络层)     │  │   (本地存储)  │        │
│  └──────────────┘  └──────────────┘        │
└─────────────────────────────────────────────┘
```

### 核心技术栈

| 功能 | 技术选型 | 版本 | Web 对比 | 选型理由 |
|------|----------|------|----------|----------|
| **状态管理** | flutter_riverpod | ^2.6.1 | Zustand/Pinia | 编译时安全、自动依赖追踪、内置DI |
| **网络请求** | dio | ^5.9.1 | Axios/Fetch | 拦截器、请求取消、FormData |
| **路由管理** | go_router | ^17.0.1 | React Router v6 | 声明式路由、深链接 |
| **依赖注入** | Riverpod Providers | ^2.6.1 | Provider/Inversify | 零开销、编译时检查 |
| **日志系统** | logger | ^2.6.2 | Winston/Pino | 彩色输出、分级 |
| **持久化** | shared_preferences | ^2.5.4 | localStorage | 异步API、跨平台 |
| **图表** | fl_chart | ^1.1.0 | Recharts | 高性能、触摸交互 |
| **环境配置** | flutter_dotenv | ^6.0.0 | dotenv | 多环境支持 |
| **国际化** | intl | ^0.20.2 | i18next | ICU消息格式 |

---

## 项目结构 📁

```
lib/
├── config/                      # 配置层
│   ├── app_config.dart          # 应用配置（API、超时、主题）
│   ├── colors.dart             # 颜色常量
│   └── constants.dart          # 业务常量
│
├── core/                       # 核心功能层
│   ├── cache/                 # 缓存管理
│   │   └── cache_manager.dart    # 内存+磁盘缓存 ✅新增
│   ├── errors/                # 错误处理
│   │   └── app_error.dart        # 错误分类 ✅新增
│   └── network/               # 网络基础设施
│       └── dio_client.dart    # Dio 单例配置、拦截器
│
├── notifiers/                  # 状态管理器
│   ├── country_list_notifier.dart    # 国家列表状态
│   └── global_stats_notifier.dart   # 全球统计状态
│
├── providers/                  # 依赖注入容器
│   └── providers.dart          # 统一Provider定义
│
├── repositories/               # 数据仓库层
│   └── covid_repository.dart   # 仓库（接口+实现，含缓存）
│
├── screens/                    # 页面层
│   ├── global_stats.dart       # 全球统计页面
│   ├── country_list.dart       # 国家列表页面
│   ├── country_search.dart    # 搜索页面
│   └── test_demo.dart         # 测试演示页面
│
├── widgets/                    # 可复用组件
│   ├── drawer.dart            # 侧边栏
│   ├── folding_cell.dart      # 折叠单元格
│   ├── graph.dart            # 折线图表
│   └── info_card.dart        # 信息卡片
│
└── main.dart                   # 应用入口
```

---

## 快速开始 🚀

### 环境要求

| 工具 | 最低版本 | 推荐版本 |
|------|----------|----------|
| Flutter SDK | 3.8.0 | 最新稳定版 |
| Dart SDK | 3.0.0 | 随Flutter一起 |
| Android Studio / VS Code | 最新 | 最新 |

### 安装步骤

```bash
# 1. 进入项目目录
cd helloFluDemo

# 2. 安装依赖
flutter pub get

# 3. 运行应用（开发环境）
flutter run

# 4. 或者运行特定平台
flutter run -d android
flutter run -d ios
flutter run -d chrome --web-port=30000  # 固定端口避免多实例
```

### Android 配置

在 `android/app/src/main/AndroidManifest.xml` 中添加网络权限：

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### 环境配置

```bash
# 开发环境（默认使用 .env）
flutter run

# 生产环境
cp .env.production .env
flutter run --release
```

---

## 优化亮点 🎯

### ✅ 1. 日志系统统一化
- 移除 `print()`，统一使用 `Logger`
- 根据 `AppConfig.enableLogging` 动态启用/禁用
- DioClient 网络日志集成

### ✅ 2. 环境变量生效化
- `.env` 配置真正生效
- 支持生产环境禁用日志
- 缓存时间可配置

### ✅ 3. API层与Repository层合并
- 删除重复的 ApiService
- 统一使用 Repository 层
- 架构更清晰

### ✅ 4. 数据缓存机制
- 内存缓存（Map）+ SharedPreferences 磁盘缓存
- 自动过期机制
- Repository 自动检查缓存 → API → 更新缓存

### ✅ 5. 错误分类处理
- 7种错误类型：NetworkError, ServerError, ClientError, TimeoutError, CacheError, DataParseError, UnknownError
- 自动转换 DioException
- 用户友好的错误提示

---

## 数据流架构 📊

```
User Action
    │
    ▼
┌───────────────┐
│     UI        │
│  (Screen)     │
└───────┬───────┘
        │ ref.watch()
        ▼
┌───────────────┐
│   Provider    │
│ (StateNotifier)│
└───────┬───────┘
        │
        ▼
┌───────────────┐
│  Repository   │
└───────┬───────┘
        │
    ┌───┴───┐
    ▼       ▼
┌──────┐ ┌────────┐
│ Remote│ │ Local  │
│ (Dio) │ │(Shared)│
└──┬───┘ └────────┘
   │
   ▼
┌────────┐
│  API   │
│ Server │
└────────┘
```

---

## API 文档 📡

本项目使用 [disease.sh](https://disease.sh/) 免费 COVID-19 API。

### 端点列表

| 端点 | 方法 | 描述 |
|------|------|------|
| `/all` | GET | 全球统计数据 |
| `/countries` | GET | 所有国家列表 |
| `/countries/{name}` | GET | 特定国家详情 |
| `/historical/{name}` | GET | 历史数据 |

### 响应示例

```json
{
  "updated": 1704067200000,
  "cases": 700000000,
  "todayCases": 100000,
  "deaths": 7000000,
  "recovered": 650000000,
  "active": 43000000,
  "affectedCountries": 230
}
```

---

## 开发指南 📚

### 添加新功能流程

```
1. 添加仓库方法 (repositories/)
        ↓
2. 创建 StateNotifier (notifiers/)
        ↓
3. 注册 Provider (providers/providers.dart)
        ↓
4. 实现 UI 页面 (screens/)
        ↓
5. 添加路由 (providers/providers.dart routerProvider)
        ↓
6. 运行分析 (flutter analyze)
```

### Git 提交规范

```
类型: 简短描述

- feat: 新功能
- fix: 修复bug
- docs: 文档更新
- refactor: 重构
- chore: 构建/工具

示例:
feat: 添加国家详情页面
```

---

## 常见问题 ❓

### Q: 如何切换主题？

A: 修改 `AppConfig.darkTheme` 或通过 `themeProvider` 切换。

### Q: 如何添加新的API端点？

A: 三步走：
1. 在 `CovidRepository` 接口添加方法
2. 在 `CovidRepositoryImpl` 实现逻辑
3. 在 Notifier 中调用

### Q: 应用启动慢？

A: 检查项：
- [ ] 使用 `const` 构造函数
- [ ] 延迟加载非关键资源
- [ ] 使用 `flutter_native_splash`

---

## 贡献指南 🤝

欢迎提交 Issue 和 PR！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

---

## 致谢 🙏

- 原项目: [nisrulz/flutter-examples](https://github.com/nisrulz/flutter-examples)
- 数据源: [disease.sh](https://disease.sh/)
- 架构参考: [Riverpod Documentation](https://riverpod.dev/)

---

## 许可证 📄

本项目基于 Apache License 2.0 开源。

---

**Happy Coding! 🎉 愿代码无Bug，应用无Crash！**
