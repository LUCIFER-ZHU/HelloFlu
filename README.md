# HelloFlu

一个用于学习 Flutter 架构拆分的 COVID-19 追踪项目。

当前版本重点不是继续堆功能，而是把已有代码整理成更适合学习和演进的结构：

- 页面负责展示，不再承担主要数据加工逻辑
- 搜索状态拆成“原始数据 + 查询词 + 派生结果”
- Repository 不再只是转发接口，而是承担第三方数据清洗

主项目位于 [helloFluDemo](/E:/ZjmCode/HelloFlu/helloFluDemo)。

## 这次优化了什么

### 1. Screen 只做展示

全球统计页原本在页面里处理数字格式化、更新时间格式化、时间线解析和采样。现在这些逻辑已经迁到：

- [global_stats_presenter.dart](/E:/ZjmCode/HelloFlu/helloFluDemo/lib/presenters/global_stats_presenter.dart)

对应页面变得更轻：

- [global_stats.dart](/E:/ZjmCode/HelloFlu/helloFluDemo/lib/screens/global_stats.dart)

### 2. 搜索状态拆分

国家列表原本把搜索结果直接写回主状态。现在拆成：

- 原始远端数据：`countriesProvider`
- 搜索关键字：`countrySearchQueryProvider`
- 派生展示结果：`filteredCountriesProvider`

相关文件：

- [country_list_notifier.dart](/E:/ZjmCode/HelloFlu/helloFluDemo/lib/providers/country_list_notifier.dart)
- [country_search_providers.dart](/E:/ZjmCode/HelloFlu/helloFluDemo/lib/providers/country_search_providers.dart)
- [country_list.dart](/E:/ZjmCode/HelloFlu/helloFluDemo/lib/screens/country_list.dart)

### 3. Repository 负责第三方接口清洗

考虑到第三方接口字段不稳定，这一版没有强推严格强类型模型，而是先让 Repository 负责：

- 结构兜底
- 缺省值兜底
- timeline 清洗
- 国家列表字段统一

相关文件：

- [covid_repository.dart](/E:/ZjmCode/HelloFlu/helloFluDemo/lib/repositories/covid_repository.dart)

### 4. 默认国家和页面状态解耦

新增了 `selectedCountryProvider`，把“默认配置”和“当前页面状态”分开：

- [config_providers.dart](/E:/ZjmCode/HelloFlu/helloFluDemo/lib/providers/config_providers.dart)
- [global_stats_notifier.dart](/E:/ZjmCode/HelloFlu/helloFluDemo/lib/providers/global_stats_notifier.dart)

## 当前架构

```text
main.dart
  -> ProviderScope
  -> router / screens
  -> providers
  -> repository
  -> dio client
  -> disease.sh API
```

按目录看：

```text
helloFluDemo/lib/
├── config/        # 配置和主题
├── core/          # 网络与错误处理
├── presenters/    # 展示层数据加工
├── providers/     # Riverpod 状态和依赖
├── repositories/  # 第三方接口清洗与访问
├── screens/       # 页面
├── widgets/       # 复用组件
├── main.dart
└── router.dart
```

这套结构适合学习这些主题：

- Riverpod Generator 的依赖注入
- 页面与状态层的职责边界
- 第三方接口容错
- Flutter 中“派生状态”的组织方式

## 运行方式

```bash
cd helloFluDemo
flutter pub get
flutter run
```

Web 调试：

```bash
flutter run -d chrome --web-port=30000
```

## 学习建议

如果你后面继续往下练，推荐顺序是：

1. 先给图表、列表、repository 补测试
2. 再补缓存策略
3. 再考虑把部分动态 map 收敛成半强类型结构
4. 最后再增加更复杂的页面状态，比如筛选、排序、分页

## 相关文档

- [项目内说明文档](/E:/ZjmCode/HelloFlu/helloFluDemo/README.md)
- [代码规范与协作说明](/E:/ZjmCode/HelloFlu/AGENTS.md)
