# COVID-19 追踪器 🦠

一个使用Flutter开发的COVID-19疫情追踪应用，采用企业级架构和现代化技术栈。本项目不仅适合初学者学习Flutter开发，更是一份完整的企业级Flutter应用最佳实践参考。

**项目状态**: ✅ 生产就绪 | 🏗️ 架构已优化 | 📱 跨平台支持

---

## 📚 完整开发指南：从网络数据到界面绘制

本文档提供**详细的端到端示例**，带你完整体验从网络请求 → 数据处理 → 状态管理 → UI展示的完整开发流程。

---

## 完整示例：显示全球疫情统计数据

### 示例目标

实现一个页面，显示全球COVID-19统计数据：
- 从网络API获取数据
- 处理各种错误情况
- 显示加载状态
- 展示数据卡片

### 完整流程图（2026 Riverpod Generator 架构）

```
用户打开页面
    │
    ▼
┌─────────────────────────────────────────────────────────┐
│ 第1步：定义数据层（Repository）                          │
│ 网络请求 + 错误处理                                       │
│ lib/repositories/covid_repository.dart                   │
└─────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────┐
│ 第2步：定义状态管理（@riverpod 注解）                     │
│ 管理异步状态 + 自动生成 Provider                          │
│ lib/notifiers/global_stats_notifier.dart                 │
│ lib/router.dart                                          │
└─────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────┐
│ 第3步：创建UI页面（Screen）                              │
│ 使用生成的 Provider                                       │
│ lib/screens/global_stats_screen.dart                     │
└─────────────────────────────────────────────────────────┘
```

### 架构优势

**传统 Riverpod vs Riverpod Generator：**

| 特性 | 传统方式 | Generator 方式 |
|------|---------|---------------|
| 代码量 | 70+ 行手动声明 | 3 行注解 |
| 类型安全 | 运行时检查 | 编译时检查 |
| 依赖注入 | 手动构造函数 | 自动 `ref.read()` |
| 维护成本 | 高（容易出错） | 低（自动生成） |

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

### 1.2 实现数据层（含错误处理）

**文件**: `lib/repositories/covid_repository.dart`（接口和实现在同一文件）

```dart
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';
import '../core/errors/app_error.dart';
import '../core/network/dio_client.dart';
import '../config/app_config.dart';

/// 仓库实现类 - 包含错误处理
class CovidRepositoryImpl implements CovidRepository {
  final Logger _logger;

  CovidRepositoryImpl(this._logger);

  @override
  Future<Map<String, dynamic>> getGlobalData() async {
    _logger.i('🌐 开始获取全球数据');
    try {
      final response = await DioClient.dio.get(
        AppConfig.endpointGlobal,
      );
      final data = response.data as Map<String, dynamic>;

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
    _logger.i('开始获取国家列表');
    try {
      final response = await DioClient.dio.get(
        AppConfig.endpointCountries(),
      );
      final data = response.data as List<dynamic>;
      _logger.i('国家列表获取成功，数量: ${data.length}');
      return data;
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getHistoricalData(String country) async {
    _logger.i('开始获取 $country 的历史数据');
    try {
      final response = await DioClient.dio.get(
        AppConfig.endpointHistorical(country),
      );
      final data = response.data as Map<String, dynamic>;
      _logger.i('$country 历史数据获取成功');
      return data;
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }
}
```

**关键要点**:
- ✅ 使用 `DioException` 捕获网络错误
- ✅ 使用 `ErrorHandler` 转换为用户友好的错误
- ✅ 日志记录完整的数据流向

---

## 第2步：定义状态管理（Riverpod Generator）

### 2.1 核心依赖 Provider（router.dart）

**文件**: `lib/router.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:logger/logger.dart';
import 'repositories/covid_repository.dart';
import 'config/app_config.dart';

part 'router.g.dart';

/// Logger Provider - 自动生成
@riverpod
Logger logger(Ref ref) {
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
}

/// Repository Provider - 自动生成
@riverpod
CovidRepository covidRepository(Ref ref) {
  return CovidRepositoryImpl(ref.read(loggerProvider));
}
```

### 2.2 创建 AsyncNotifier（注解方式）

**文件**: `lib/notifiers/global_stats_notifier.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../router.dart';

part 'global_stats_notifier.g.dart';

/// 全球统计数据状态管理器（Riverpod Generator 版本）
///
/// 使用 @riverpod 注解，代码生成器自动生成 Provider
/// 比传统方式减少 70% 样板代码
@riverpod
class GlobalStats extends _$GlobalStats {
  @override
  Future<Map<String, dynamic>> build() async {
    // 自动生成 ref，直接使用
    ref.read(loggerProvider).i('开始加载全球数据');
    
    final globalData = await ref.read(covidRepositoryProvider).getGlobalData();
    return {
      'global': globalData,
      'historical': null,
    };
  }

  /// 加载全球和历史数据
  Future<void> loadAll(String country) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final results = await Future.wait<Map<String, dynamic>>([
        ref.read(covidRepositoryProvider).getGlobalData(),
        ref.read(covidRepositoryProvider).getHistoricalData(country),
      ]);
      return {
        'global': results[0],
        'historical': results[1],
      };
    });
  }

  /// 刷新数据
  Future<void> refresh() async {
    final currentData = state.valueOrNull;
    final hasHistorical = currentData?['historical'] != null;

    if (hasHistorical) {
      await loadAll('China');
    } else {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        final globalData = await ref.read(covidRepositoryProvider).getGlobalData();
        return {
          'global': globalData,
          'historical': null,
        };
      });
    }
  }
}
```

**关键要点**:
- ✅ 使用 `@riverpod` 注解，自动生成 Provider
- ✅ `ref` 自动生成，无需声明
- ✅ 使用 `AsyncValue.guard()` 简化错误处理
- ✅ 生成的 Provider 名称：`globalStatsProvider`

### 2.3 代码生成

运行以下命令生成代码：

```bash
# 生成代码（首次或修改后运行）
flutter pub run build_runner build --delete-conflicting-outputs

# 监听模式（开发时自动重新生成）
flutter pub run build_runner watch --delete-conflicting-outputs
```

生成的文件：
- `router.g.dart` - 包含 `loggerProvider`, `covidRepositoryProvider`, `routerProvider`
- `global_stats_notifier.g.dart` - 包含 `globalStatsProvider`
- `country_list_notifier.g.dart` - 包含 `countriesProvider`

---

## 第3步：创建UI页面（Screen）

### 3.1 实现完整的UI页面

**文件**: `lib/screens/global_stats_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/errors/app_error.dart';
import '../notifiers/global_stats_notifier.dart';
import '../router.dart';

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

## 第4步：应用入口配置

### 4.1 更新 main.dart

**文件**: `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/app_config.dart';
import 'core/network/dio_client.dart';
import 'router.dart';

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
    // 2️⃣ 配置 Logger（从生成的 Provider 获取）
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
    // 使用生成的 Provider
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

### 场景：正常加载数据

```
1. 用户打开页面
   └─> GlobalStatsNotifier 构造函数调用 loadGlobalData()

2. 发起网络请求
   └─> DioClient 请求 https://disease.sh/v3/covid-19/all
   └─> Logger 输出: "🌐 开始获取全球数据"

3. 请求成功
   └─> Logger 输出: "✅ 全球数据获取成功"
   └─> Notifier 更新 state = AsyncValue.data(data)

4. UI 自动重建
   └─> 显示数据卡片
   └─> 显示病例数、死亡数、康复数、活跃数
```

### 场景：网络错误

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

# 过滤查看特定日志
flutter run | grep "全球数据"
```

**日志示例**:
```
[GlobalStatsNotifier] 🔄 开始加载全球数据
[CovidRepositoryImpl] ✅ 全球数据获取成功
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
                                                   ▼
                                          ┌─────────────┐
                                          │  API (Dio)  │
                                          └─────────────┘
```

### 核心原则

1. **单一职责**: 每层只做一件事
2. **依赖注入**: 通过 Riverpod 管理依赖
3. **错误分类**: 不同错误不同处理
4. **响应式UI**: 状态驱动界面更新

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
| **代码生成** | riverpod_generator | ^2.6.5 | - | 自动生成Provider，减少70%样板代码 |
| **网络请求** | dio | ^5.9.1 | Axios/Fetch | 拦截器、请求取消、FormData |
| **路由管理** | go_router | ^17.0.1 | React Router v6 | 声明式路由、深链接 |
| **依赖注入** | Riverpod Generator | ^2.6.5 | Provider/Inversify | 零开销、编译时检查、自动注入 |
| **日志系统** | logger | ^2.6.2 | Winston/Pino | 彩色输出、分级 |
| **图表** | fl_chart | ^1.1.0 | Recharts | 高性能、触摸交互 |
| **环境配置** | flutter_dotenv | ^6.0.0 | dotenv | 多环境支持 |

---

## 项目结构 📁（2026 Riverpod Generator 架构）

```
lib/
├── config/                      # 配置层
│   ├── app_config.dart          # 应用配置（API、超时、主题）
│   ├── colors.dart             # 颜色常量
│   └── constants.dart          # 业务常量
│
├── core/                       # 核心功能层
│   ├── errors/                # 错误处理
│   │   └── app_error.dart        # 错误分类
│   └── network/               # 网络基础设施
│       └── dio_client.dart    # Dio 单例配置、拦截器
│
├── notifiers/                  # 状态管理器（@riverpod 注解）
│   ├── country_list_notifier.dart    # 国家列表状态
│   ├── country_list_notifier.g.dart  # 生成的Provider
│   ├── global_stats_notifier.dart   # 全球统计状态
│   └── global_stats_notifier.g.dart # 生成的Provider
│
├── repositories/               # 数据仓库层
│   └── covid_repository.dart   # 仓库（接口+实现）
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
├── router.dart                 # 核心Provider定义（Logger + Repository + Router）
├── router.g.dart               # 生成的Provider代码
└── main.dart                   # 应用入口
```

### 架构说明

**2026 Riverpod Generator 新架构特点：**

1. **移除 providers/ 目录** - 不再需要手动声明 Provider
2. **新增 router.dart** - 集中定义核心依赖（Logger、Repository、Router）
3. **notifiers/ 包含 .g.dart 文件** - 代码生成器自动创建 Provider
4. **零样板代码** - 通过 `@riverpod` 注解自动生成所有Provider

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

---

## 优化亮点 🎯

### ✅ 1. 日志系统统一化
- 移除 `print()`，统一使用 `Logger`
- 根据 `AppConfig.enableLogging` 动态启用/禁用
- DioClient 网络日志集成

### ✅ 2. 环境变量生效化
- `.env` 配置真正生效
- 支持生产环境禁用日志

### ✅ 3. API层与Repository层合并
- 删除重复的 ApiService
- 统一使用 Repository 层
- 架构更清晰

### ✅ 4. 错误分类处理
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
        ▼
┌───────────────┐
│  API (Dio)    │
└───────────────┘
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

---

## 常见问题 ❓

### Q: 如何切换主题？

A: 修改 `AppConfig.darkTheme` 或通过 `themeProvider` 切换。

### Q: 如何添加新的API端点？

A: 三步走：
1. 在 `CovidRepository` 接口添加方法
2. 在 `CovidRepositoryImpl` 实现逻辑
3. 在 Notifier 中调用

---

**Happy Coding! 🎉 愿代码无Bug，应用无Crash！**
