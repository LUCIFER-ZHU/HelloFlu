# COVID-19 追踪器 🦠

一个使用Flutter开发的COVID-19疫情追踪应用，适合初学者学习Flutter开发。项目已升级为企业级架构，采用现代化技术栈和最佳实践。

## 项目简介 📖

本项目是一个完整的Flutter移动应用，用于追踪全球和各国的COVID-19疫情数据。项目经过改造优化，代码结构清晰，注释详细，特别适合Flutter初学者学习和参考。

## 主要功能 ✨

- **全球疫情概览**：显示全球累计确诊、死亡、康复、活跃病例等统计数据
- **国家趋势图表**：使用折线图展示特定国家的每日病例、死亡、康复趋势
- **国家列表**：以折叠列表的形式展示所有受影响国家的详细数据
- **搜索功能**：支持按国家名称搜索，快速查看特定国家数据
- **下拉刷新**：支持下拉获取最新疫情数据
- **深色主题**：采用Material Design深色主题，视觉体验良好

## 企业级架构升级 🚀

本项目已从学习项目升级为企业级应用，采用现代化架构模式：

### 核心技术栈

| 功能 | 技术选型 | 最新版本 | Web 对比 |
|------|----------|----------|----------|
| **状态管理** | Riverpod | ^2.6.1 | Zustand/Pinia |
| **网络请求** | Dio | ^5.7.0 | Axios/Fetch |
| **路由管理** | GoRouter | ^14.6.0 | React Router |
| **依赖注入** | Riverpod Providers | ^2.6.1 | Context/InversifyJS |
| **日志系统** | Logger | ^2.4.0 | Winston/Pino |
| **持久化存储** | SharedPreferences | ^2.3.2 | localStorage |
| **国际化** | Intl | ^0.20.1 | i18next |

### 架构设计原则

- **单一数据源**：Riverpod 作为唯一的状态管理和依赖注入方案
- **分层架构**：清晰的分层结构（Config → Services → Notifiers → Providers → Screens）
- **类型安全**：全面使用 Dart null safety 和显式类型注解
- **可测试性**：依赖注入便于单元测试和 Mock

## 项目结构 📁

```
lib/
├── config/                      # 配置文件
│   ├── app_config.dart          # 应用配置类（API、超时、主题）
│   ├── colors.dart             # 颜色常量
│   └── constants.dart          # 业务常量
│
├── core/                         # 核心功能层
│   └── network/                # 网络层
│       └── dio_client.dart    # Dio 客户端配置（单例 + 拦截器）
│
├── models/                       # 数据模型
│   └── covid_models.dart      # COVID-19 数据模型
│
├── notifiers/                    # 状态管理器（Riverpod StateNotifier）
│   ├── country_list_notifier.dart    # 国家列表状态
│   └── global_stats_notifier.dart  # 全球统计状态
│
├── providers/                    # Riverpod Providers（依赖注入）
│   └── providers.dart            # 统一 Provider 定义
│       ├── 配置 Providers（主题、locale）
│       ├── 服务 Providers（Logger）
│       ├── 状态 Providers（StateNotifier）
│       └── 路由 Provider（GoRouter）
│
├── screens/                      # 页面组件
│   ├── global_stats.dart       # 全球统计页面（使用 Riverpod）
│   ├── country_list.dart       # 国家列表页面（使用 Riverpod）
│   └── country_search.dart    # 搜索功能
│
├── services/                     # 业务服务层
│   └── api_service.dart       # API 服务（使用 Dio）
│
├── widgets/                      # 可复用组件
│   ├── drawer.dart            # 侧边栏
│   ├── folding_cell.dart      # 折叠单元格
│   ├── graph.dart            # 图表组件
│   └── info_card.dart        # 信息卡片
│
└── main.dart                     # 应用入口
```

## 核心功能详解 🔑

### 0. 环境配置

**配置文件**：`.env`、`.env.development`、`.env.production`

**环境变量说明**：
```env
# API 配置
API_BASE_URL=https://disease.sh/v3/covid-19

# 环境变量
ENVIRONMENT=development

# 功能开关
ENABLE_LOGGING=true
ENABLE_DEBUG=true

# 缓存配置
CACHE_DURATION_MINUTES=30
```

**使用方式**：
```bash
# 开发环境（默认）
flutter run

# 生产环境
flutter run --dart-define=ENVIRONMENT=production

# 或者修改 .env 软链接
# Windows: mklink .env .env.development
# Linux/Mac: ln -s .env.development .env
```

**代码读取**：`lib/config/app_config.dart`
```dart
// 获取 API 地址（从环境变量读取）
final apiUrl = AppConfig.apiBaseUrl;

// 判断当前环境
if (AppConfig.isDevelopment) {
  // 开发环境配置
}

// 判断调试模式
if (AppConfig.debugMode) {
  // 显示调试信息
}
```

**Web 技术对比**：
```dart
// Flutter (flutter_dotenv)
await dotenv.load(fileName: '.env');
final apiUrl = dotenv.env['API_BASE_URL'];

// Web (.env)
const apiUrl = import.meta.env.VITE_API_URL;
// 或从 process.env 读取
const apiUrl = process.env.API_BASE_URL;
```

### 1. 网络请求层（Dio）

**配置文件**：`lib/core/network/dio_client.dart`

**功能特性**：
- ✅ 单例模式（统一 Dio 实例管理）
- ✅ 基础 URL 和超时配置
- ✅ 请求拦截器（添加 headers、token）
- ✅ 响应拦截器（处理响应数据）
- ✅ 错误拦截器（统一错误处理）
- ✅ 日志拦截器（开发环境打印详细日志）

**使用示例**：
```dart
// 在 API 服务中使用
import '../core/network/dio_client.dart';

final response = await DioClient.dio.get(AppConfig.endpointGlobal);
```

**Web 技术对比**：
```dart
// Flutter (Dio)
final response = await DioClient.dio.get('/api/data');

// Web (Axios)
const response = await axios.get('/api/data');

// Web (Fetch)
const response = await fetch('/api/data');
const data = await response.json();
```

**配置说明**：
- API 地址、超时等配置从环境变量读取（`AppConfig.apiBaseUrl`）
- 支持开发/生产环境切换
- 调试模式和日志开关可配置

### 2. 状态管理（Riverpod + StateNotifier）

**设计模式**：
- **Provider 参数注入**：通过 `ref.watch()` 在 Notifier 构造函数中注入依赖
- **StateNotifier 模式**：管理异步状态和业务逻辑
- **FutureProvider.family**：参数化异步数据（如历史数据查询）

**Providers 定义**：`lib/providers/providers.dart`

| Provider | 类型 | 说明 |
|----------|--------|------|
| `themeProvider` | Provider | 应用主题配置 |
| `defaultCountryProvider` | Provider | 默认国家 |
| `localeProvider` | Provider | 当前语言 |
| `loggerProvider` | Provider | Logger 实例 |
| `sharedPreferencesProvider` | FutureProvider | SharedPreferences 实例 |
| `globalStatsProvider` | StateNotifierProvider | 全球统计数据 |
| `countriesProvider` | StateNotifierProvider | 国家列表（支持搜索） |
| `historicalDataProvider` | FutureProvider.family | 国家历史数据 |
| `countryDataProvider` | FutureProvider.family | 国家详细数据 |
| `routerProvider` | Provider | GoRouter 路由配置 |

**使用示例**：
```dart
// ConsumerWidget 中使用
class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countriesAsync = ref.watch(countriesProvider);

    return countriesAsync.when(
      loading: () => CircularProgressIndicator(),
      data: (countries) => ListView.builder(...),
      error: (error, stack) => Text('加载失败: $error'),
    );
  }
}

// 手动刷新
ref.read(countriesProvider.notifier).refresh();
```

**Web 技术对比**：
```dart
// Flutter (Riverpod)
final countries = ref.watch(countriesProvider);

// Web (Zustand)
const countries = useCountryStore(state => state.countries);

// Web (Pinia)
const { countries } = storeToRefs(countryStore);
```

### 3. 依赖注入（Riverpod Providers）

**实现方式**：使用 Riverpod 的 Provider 系统作为依赖注入容器

**优势**：
- 无需额外 DI 库（如 GetIt）
- 类型安全（编译时检查）
- 自动生命周期管理
- 易于测试（可以轻松替换依赖）

**依赖注入流程**：
```dart
// 1. 定义服务 Provider
final loggerProvider = Provider<Logger>((ref) {
  return Logger();
});

// 2. 在 Notifier 中通过参数注入
class GlobalStatsNotifier extends StateNotifier<...> {
  final Logger _logger;

  GlobalStatsNotifier(this._logger) : super(...) {
    // 使用注入的 logger
    _logger.i('初始化完成');
  }
}

// 3. 在 Provider 定义中创建 Notifier
final globalStatsProvider = StateNotifierProvider<...>((ref) {
  final logger = ref.watch(loggerProvider);
  return GlobalStatsNotifier(logger);
});
```

**Web 技术对比**：
```dart
// Flutter (Riverpod Provider)
final logger = ref.watch(loggerProvider);

// Web (React Context)
const logger = useContext(LogContext);

// Web (InversifyJS)
const logger = container.get(LogService);
```

### 4. 日志系统（Logger）

**使用方式**：直接使用 Logger 包，提供彩色日志和分级输出

**日志级别**：
- 🐛 `d` - Debug（调试信息）
- ℹ️ `i` - Info（普通信息）
- ⚠️ `w` - Warning（警告）
- ❌ `e` - Error（错误）
- 🔥 `f` - Fatal（致命错误）

**使用示例**：
```dart
// 在 Notifier 中使用
_logger.i('开始加载国家列表');
_logger.e('加载失败', error, stackTrace);
```

**Web 技术对比**：
```dart
// Flutter (Logger)
logger.i('应用启动');
logger.error('加载失败', error, stackTrace);

// Web (Winston)
logger.info('应用启动');
logger.error('加载失败', { error, stackTrace });
```

### 5. 持久化存储（SharedPreferences）

**功能**：
- 键值对存储（类似 localStorage）
- 支持多种数据类型（String、int、bool）
- 异步 API

**使用方式**：
```dart
// 初始化（在 Notifier 中）
_prefs = await SharedPreferences.getInstance();

// 存储数据
await _prefs.setString('default_country', 'China');

// 读取数据
final country = _prefs.getString('default_country');
```

**Web 技术对比**：
```dart
// Flutter (SharedPreferences)
await prefs.setString('key', 'value');
final value = await prefs.getString('key');

// Web (LocalStorage)
localStorage.setItem('key', 'value');
const value = localStorage.getItem('key');
```

### 6. 应用配置（AppConfig）

**配置文件**：`lib/config/app_config.dart`

**配置项**：
- API 基础 URL 和端点
- 网络超时配置
- 默认国家
- 主题配置
- 调试开关
- 缓存配置

**使用示例**：
```dart
// 获取 API 端点
final url = AppConfig.endpointGlobal;

// 获取超时配置
final timeout = AppConfig.connectTimeout;
```

### 7. 路由管理（GoRouter）

**配置文件**：`lib/providers/providers.dart` (routerProvider)

**功能**：
- ✅ 声明式路由
- ✅ 嵌套路由
- ✅ 错误页面
- ✅ 深链接支持

**路由配置**：
| 路径 | 名称 | 页面 |
|--------|------|------|
| `/` | home | GlobalStatsScreen |
| `/global-stats` | globalStats | GlobalStatsScreen |
| `/countries` | countries | CountryListScreen |

**使用示例**：
```dart
// 导航到指定路由
context.push('/countries');

// 返回上一页
context.pop();

// 替换当前路由
context.pushReplacement('/home');
```

**Web 技术对比**：
```dart
// Flutter (GoRouter)
GoRoute(path: '/countries', builder: (context, state) => CountryListScreen())

// Web (React Router)
<Route path="/countries" element={<CountryListScreen />} />
```

## 数据流图 📊

```
┌─────────────────┐
│   main.dart    │  应用入口
│  (ProviderScope)  │
└────────┬────────┘
         │
         ├─→ routerProvider (GoRouter)
         │
         ├─→ globalStatsProvider
         │  ┌──────────┐
         │  ↓          │
         │  GlobalStatsNotifier
         │  ┌───────┬────┐
         │  │      ↓      ↓
         │  │  ApiService  Logger
         │  │      (Dio HTTP)
         │  ↓      ↓
         │  DioClient  Provider
         │  ┌──┬───┐
         │  ↓  ↓   ↓
         └─ API   Log
           Network  System
```

## 运行项目 🚀

### 前置要求
- Flutter SDK >= 3.0.0
- Dart >= 3.0.0
- 已配置 Android Studio 或 VS Code
- 已配置模拟器或真机设备

### 安装步骤

1. **克隆或下载项目**
   ```bash
   cd your_project_directory
   ```

2. **安装依赖**
   ```bash
   cd helloFluDemo
   flutter pub get
   ```

3. **运行应用**
   ```bash
   # 开发环境（默认）
   flutter run

   # Chrome 固定端口调试
   flutter run -d chrome --web-port=30000
   ```

### Android 配置

在 `android/app/src/main/AndroidManifest.xml` 中添加互联网权限：

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

## 开发指南 📚

### 学习路径

#### 第一阶段：理解架构
1. 阅读 `main.dart` 了解应用启动流程
2. 阅读 `lib/config/` 了解配置管理
3. 阅读 `lib/providers/providers.dart` 理解 Riverpod Provider 系统

#### 第二阶段：实践使用
1. 尝试修改 API 配置（超时、拦截器）
2. 添加新的 Provider
3. 实现数据缓存逻辑

#### 第三阶段：扩展功能
1. 添加新的页面
2. 实现主题切换
3. 添加国际化支持

### 添加新的 API 方法

1. 在 `lib/services/api_service.dart` 中添加方法
2. 使用 `DioClient.dio` 发送请求
3. 在 `lib/providers/providers.dart` 中创建对应的 Provider

### 添加新的页面

1. 创建页面组件（使用 `ConsumerWidget` 或 `ConsumerStatefulWidget`）
2. 使用 `ref.watch()` 订阅状态
3. 在 `routerProvider` 中添加路由

### 代码质量

运行以下命令检查代码质量：

```bash
# 分析代码
flutter analyze

# 运行测试
flutter test

# 格式化代码
dart format .
```

## 数据来源 📊

本项目使用免费的公开 API：[disease.sh](https://disease.sh/)

- **全球数据**：`https://disease.sh/v3/covid-19/all`
- **国家列表**：`https://disease.sh/v3/covid-19/countries?sort=country`
- **国家历史数据**：`https://disease.sh/v3/covid-19/historical/{country}`

## 核心文件说明 📝

### 配置文件

- **`lib/config/app_config.dart`**
  - 应用配置类（API 地址、超时、主题）

- **`lib/config/colors.dart`**
  - 颜色常量定义

- **`lib/config/constants.dart`**
  - 业务常量（如默认国家名称）

### 状态管理

- **`lib/notifiers/global_stats_notifier.dart`**
  - 全球统计数据状态管理器
  - 使用 Logger 记录日志
  - 支持加载、刷新数据

- **`lib/notifiers/country_list_notifier.dart`**
  - 国家列表状态管理器
  - 支持搜索功能

- **`lib/providers/providers.dart`**
  - 统一的 Provider 定义
  - 包含配置、服务、状态、路由 Provider

### 页面组件

- **`lib/screens/global_stats.dart`**
  - 功能：显示全球疫情数据和中国（默认）的趋势图表
  - 知识点：`ConsumerStatefulWidget`、`ref.watch()`、下拉刷新、图表集成

- **`lib/screens/country_list.dart`**
  - 功能：展示所有受影响国家的列表
  - 知识点：`ListView.builder`、折叠单元格

- **`lib/screens/country_search.dart`**
  - 功能：提供国家搜索功能
  - 知识点：`SearchDelegate`、搜索建议

### 服务层

- **`lib/services/api_service.dart`**
  - 封装所有 API 调用
  - 错误处理和数据转换
  - 使用 Dio 发送 HTTP 请求

- **`lib/core/network/dio_client.dart`**
  - Dio 客户端配置
  - 拦截器、超时管理
  - 单例模式

### 可复用组件

- **`lib/widgets/info_card.dart`**
  - 圆角信息卡片组件

- **`lib/widgets/drawer.dart`**
  - 侧边栏导航组件

- **`lib/widgets/graph.dart`**
  - 折线图表组件（使用 fl_chart）

- **`lib/widgets/folding_cell.dart`**
  - 折叠单元格组件

## 常见问题 ❓

### Q: 应用无法加载数据？
A: 请检查：
1. 网络连接是否正常
2. 是否添加了 INTERNET 权限（Android）
3. API 服务是否正常

### Q: 如何修改默认显示的国家？
A: 在 `lib/config/app_config.dart` 中修改 `defaultCountry` 的值。

### Q: 如何添加新的页面？
A:
1. 创建页面组件
2. 在 `lib/providers/providers.dart` 的 `routerProvider` 中添加路由
3. 使用 `context.push()` 或 `context.go()` 导航

### Q: 如何添加新的 API 端点？
A:
1. 在 `lib/services/api_service.dart` 中添加方法
2. 使用 `DioClient.dio` 发送请求
3. 创建对应的 Provider（如果需要）

## 许可证 📄

本项目基于原项目改造，遵循 Apache License 2.0。

原项目地址：https://github.com/nisrulz/flutter-examples/tree/develop/covid19_mobile_app

## 参考资源 🔗

- [Riverpod 官方文档](https://riverpod.dev/)
- [Dio 文档](https://pub.dev/packages/dio)
- [GoRouter 文档](https://pub.dev/packages/go_router)
- [Logger 文档](https://pub.dev/packages/logger)
- [fl_chart 文档](https://pub.dev/packages/fl_chart)
- [Flutter 最佳实践](https://flutter.dev/docs/development/data-and-backend/state-mgmt/intro)

## 致谢 🙏

- 感谢 [nisrulz/flutter-examples](https://github.com/nisrulz/flutter-examples) 提供的原项目
- 数据来源：[disease.sh API](https://disease.sh/)
- Riverpod 社区提供的最佳实践

---

**Happy Coding! 🎉**
