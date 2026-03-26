# helloFluDemo

Flutter COVID-19 学习项目，当前版本聚焦于“架构整理”和“职责边界”。

## 目标

这个项目不追求把所有层都堆满，而是优先把下面三件事做对：

1. Screen 尽量只负责展示
2. Provider 负责组织状态，不直接揉杂搜索后的临时结果
3. Repository 负责吸收第三方接口的不稳定性

## 当前数据流

```text
UI(Screen)
  -> Provider / AsyncNotifier
  -> Repository
  -> DioClient
  -> disease.sh API
```

## 本次重构摘要

### 页面层收敛

全球统计页原来的数据加工逻辑已经从页面中拆出，迁移到了 presenter：

- [global_stats.dart](/E:/ZjmCode/HelloFlu/helloFluDemo/lib/screens/global_stats.dart)
- [global_stats_presenter.dart](/E:/ZjmCode/HelloFlu/helloFluDemo/lib/presenters/global_stats_presenter.dart)

现在 presenter 统一负责：

- 数字格式化
- 时间格式化
- timeline 容错解析
- timeline 下采样

### 搜索状态拆分

国家列表搜索不再覆盖原始异步数据，而是采用派生状态：

- 原始列表：`countriesProvider`
- 搜索词：`countrySearchQueryProvider`
- 展示列表：`filteredCountriesProvider`

相关文件：

- [country_list_notifier.dart](/E:/ZjmCode/HelloFlu/helloFluDemo/lib/providers/country_list_notifier.dart)
- [country_search_providers.dart](/E:/ZjmCode/HelloFlu/helloFluDemo/lib/providers/country_search_providers.dart)
- [country_list.dart](/E:/ZjmCode/HelloFlu/helloFluDemo/lib/screens/country_list.dart)

### Repository 增强

考虑到第三方 API 字段不稳定，这里先采用“清洗后的动态结构”方案，而不是一步到位强类型化。

Repository 现在负责：

- 校验响应是不是 `Map` / `List`
- 缺失字段兜底为安全默认值
- country list 结构统一
- historical timeline 结构统一

相关文件：

- [covid_repository.dart](/E:/ZjmCode/HelloFlu/helloFluDemo/lib/repositories/covid_repository.dart)

### 页面状态与默认配置分离

新增 `selectedCountryProvider`，把“默认国家配置”和“当前页面选中状态”拆开：

- [config_providers.dart](/E:/ZjmCode/HelloFlu/helloFluDemo/lib/providers/config_providers.dart)
- [global_stats_notifier.dart](/E:/ZjmCode/HelloFlu/helloFluDemo/lib/providers/global_stats_notifier.dart)

## 目录结构

```text
lib/
├── config/
├── core/
│   ├── errors/
│   └── network/
├── presenters/
├── providers/
├── repositories/
├── screens/
├── widgets/
├── main.dart
└── router.dart
```

### 各层职责

- `config/`: 环境、主题、常量
- `core/`: 网络基础设施和统一错误处理
- `presenters/`: 页面展示所需的数据转换
- `providers/`: Riverpod 状态、依赖注入、派生状态
- `repositories/`: API 访问和第三方数据清洗
- `screens/`: 页面组合与状态消费
- `widgets/`: 可复用组件

## 主要文件

- [main.dart](/E:/ZjmCode/HelloFlu/helloFluDemo/lib/main.dart)
- [router.dart](/E:/ZjmCode/HelloFlu/helloFluDemo/lib/router.dart)
- [core_providers.dart](/E:/ZjmCode/HelloFlu/helloFluDemo/lib/providers/core_providers.dart)
- [config_providers.dart](/E:/ZjmCode/HelloFlu/helloFluDemo/lib/providers/config_providers.dart)
- [global_stats_notifier.dart](/E:/ZjmCode/HelloFlu/helloFluDemo/lib/providers/global_stats_notifier.dart)
- [country_search_providers.dart](/E:/ZjmCode/HelloFlu/helloFluDemo/lib/providers/country_search_providers.dart)
- [covid_repository.dart](/E:/ZjmCode/HelloFlu/helloFluDemo/lib/repositories/covid_repository.dart)

## 常用命令

```bash
flutter pub get
flutter run
flutter run -d chrome --web-port=30000
flutter test
flutter analyze
dart format .
```

## 后续推荐练习

如果你继续拿这个库练 Flutter，建议按这个顺序继续：

1. 给 presenter 和 repository 补单测
2. 给 provider 补状态测试
3. 在 repository 增加缓存
4. 再逐步把最稳定的几块数据收敛成半强类型结构

## 说明

本次改动后，这个项目更适合作为“学习 Riverpod 分层和第三方接口容错”的示例，而不是“所有数据都立刻强类型化”的示例。
