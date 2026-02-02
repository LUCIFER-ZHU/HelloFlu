# HelloFlu - Flutter学习项目 📱

一个完整的 Flutter COVID-19 疫情追踪应用，采用企业级架构和现代化技术栈。

**项目状态**: ✅ 生产就绪 | 🏗️ 企业级架构 | 📱 跨平台支持 | 📚 完整教程

---

## 📚 完整开发教程（重点推荐）

### 从零到一：网络数据 → UI 展示的完整流程

**[📖 查看完整教程](./helloFluDemo/README.md)**

本教程提供详细的端到端示例，带你完整体验：

```
第1步：定义数据层（Repository）      → 网络请求 + 缓存 + 错误处理
第2步：定义状态管理（StateNotifier）  → 管理异步状态
第3步：注册Provider（依赖注入）       → Riverpod配置
第4步：创建UI页面（Screen）          → 显示数据卡片
第5步：添加路由配置                   → 页面导航
```

### 教程亮点

- ✅ **从零开始**：不需要任何前置知识
- ✅ **详细注释**：每行代码都有说明
- ✅ **完整流程**：网络 → 数据 → 状态 → UI
- ✅ **最佳实践**：企业级架构和代码规范
- ✅ **错误处理**：网络错误、超时、服务器错误分类处理
- ✅ **缓存机制**：内存缓存 + 磁盘缓存
- ✅ **响应式UI**：加载中、成功、失败三种状态

---

## 项目结构 📁

```
HelloFlu/
├── helloFluDemo/              # 主项目（含完整教程）
│   ├── lib/                   # 源代码
│   │   ├── core/             # 核心功能（缓存、错误处理、网络）
│   │   ├── config/           # 配置文件
│   │   ├── models/           # 数据模型
│   │   ├── notifiers/        # 状态管理
│   │   ├── providers/        # 依赖注入
│   │   ├── repositories/     # 数据仓库
│   │   ├── screens/          # 页面
│   │   ├── widgets/          # 组件
│   │   └── main.dart         # 入口
│   ├── README.md             # ⭐ 完整开发教程
│   └── pubspec.yaml          # 依赖配置
│
├── temp_flutter_examples/     # 参考项目（原版对比）
│   └── covid19_mobile_app/
│
└── README.md                 # 本文件
```

---

## 核心技术栈

| 功能 | 技术 | 版本 | 用途 |
|------|------|------|------|
| **状态管理** | flutter_riverpod | ^2.6.1 | 响应式状态管理 + 依赖注入 |
| **网络请求** | dio | ^5.9.1 | HTTP客户端 + 拦截器 |
| **路由** | go_router | ^17.0.1 | 声明式路由 |
| **图表** | fl_chart | ^1.1.0 | 数据可视化 |
| **缓存** | shared_preferences | ^2.5.4 | 本地持久化 |
| **日志** | logger | ^2.6.2 | 彩色日志输出 |

---

## 快速开始

```bash
# 1. 进入项目
cd helloFluDemo

# 2. 安装依赖
flutter pub get

# 3. 运行应用
flutter run

# 4. 或运行特定平台
flutter run -d chrome --web-port=30000
```

### 环境要求

- Flutter SDK >= 3.8.0
- Dart SDK >= 3.0.0
- Android Studio / VS Code

---

## 学习资源

### 必读文档

| 文档 | 说明 | 适合人群 |
|------|------|----------|
| [helloFluDemo/README.md](./helloFluDemo/README.md) | ⭐ 完整开发教程（重点） | 所有人 |
| [AGENTS.md](./AGENTS.md) | 代码规范和架构说明 | 开发者 |

### 推荐学习路径

1. **零基础入门** → 阅读 [完整教程](./helloFluDemo/README.md)
2. **理解架构** → 查看 [AGENTS.md](./AGENTS.md)
3. **动手实践** → 按照教程自己实现一遍
4. **对比学习** → 参考 temp_flutter_examples/ 中的原版

---

## 主要功能

- 📊 **全球疫情概览**：实时统计数据展示
- 📈 **趋势图表**：折线图展示历史数据
- 🌍 **国家列表**：所有国家详细数据
- 🔍 **搜索功能**：按国家名称搜索
- 🔄 **下拉刷新**：手动刷新数据
- 💾 **智能缓存**：减少API调用，支持离线

---

## 最佳实践

### 架构设计

- ✅ **分层架构**：Core → Config → Models → Repositories → Notifiers → Screens
- ✅ **依赖注入**：Riverpod Provider 管理所有依赖
- ✅ **单一职责**：每层只做一件事
- ✅ **缓存优先**：先查缓存，再请求API
- ✅ **错误分类**：不同错误不同处理

### 代码规范

- ✅ **类型安全**：全面使用 Null Safety
- ✅ **统一日志**：Logger 替代 print()
- ✅ **环境配置**：.env 文件管理配置
- ✅ **响应式UI**：AsyncValue 处理三种状态

---

## 常用命令

```bash
# 进入项目
cd helloFluDemo

# 安装依赖
flutter pub get

# 运行应用
flutter run

# 代码分析
flutter analyze

# 格式化代码
dart format .

# 构建发布版本
flutter build apk --release
flutter build ios --release
flutter build web --release
```

---

## 参考资源

- [Flutter官方文档](https://flutter.dev/docs)
- [Dart语言指南](https://dart.dev/guides)
- [Riverpod文档](https://riverpod.dev/)
- [Dio文档](https://pub.dev/packages/dio)

---

## 许可证

本项目基于 Apache License 2.0 开源。

---

**🎉 开始学习Flutter企业级开发！**

[👉 点击阅读完整教程](./helloFluDemo/README.md)
