# AGENTS.md - Codebase Guide for COVID-19 Tracker Flutter App

## Project Overview
This is a Flutter learning project (COVID-19 pandemic tracker) written in Dart with extensive Chinese documentation. The project demonstrates clean architecture with clear separation of concerns.

## Build, Lint, and Test Commands

### Installation
```bash
# Install dependencies
cd helloFluDemo && flutter pub get

# Run the app (on connected device/emulator)
flutter run

# Run on specific platforms
flutter run -d android
flutter run -d ios
flutter run -d chrome

# Run all tests
flutter test

# Run a single test file
flutter test test/widget_test.dart

# Run specific test by name
flutter test --name="test_name_here"

# Analyze code for issues
flutter analyze

# Fix linting issues automatically
dart fix --apply
```

## Code Style Guidelines

### Import Conventions
- Use **relative imports** from `lib/` directory (no absolute package paths)
- Group external packages first, then local imports
- No unused imports allowed

### Formatting
- **Indentation**: 2 spaces (Dart convention)
- **Quotes**: Single quotes for all strings
- **Semicolons**: Always present (Dart requirement)
- **Trailing commas**: Required for multi-line lists and constructor calls

### Type System (Dart)
- Use **explicit type annotations** for parameters and return types
- Use **`final`** for immutable properties
- Use **`required`** keyword for constructor parameters
- Type assertion pattern: `as Type? ?? defaultValue`

### Naming Conventions
- **Classes**: PascalCase (`HomeScreen`, `ApiService`, `GlobalStats`)
- **Methods/Functions**: camelCase (`getAllData`, `_formatNumber`)
- **Variables**: camelCase (`countryName`, `timelineData`)
- **Private members**: underscore prefix (`_parseTimelineData`, `_formatNumber`)
- **Constants**: camelCase static const (`static const String defaultCountry = 'China'`)
- **Files**: snake_case (`home.dart`, `api_service.dart`)

### Error Handling
- Catch specific exceptions: `http.ClientException`, `FormatException`
- Always include generic `catch` fallback
- Provide user-friendly error messages in Chinese
- Use `FutureBuilder` for async error handling in UI

### Comments and Documentation
- **Classes and public methods**: Use `///` Dart doc comments
- **Inline comments**: Chinese language, descriptive
- **Code examples**: Markdown format in doc comments
- **Section dividers**: Use visual separators in constants

### Widget Patterns

### Stateless vs Stateful
- Prefer `StatelessWidget` for screens
- Use `StatefulWidget` only when internal state management is required
- Always include `super.key` parameter

### Async Data Loading
- Use `FutureBuilder` for async operations
- Handle `waiting`, `hasError`, and `hasData` states
- Provide loading indicators and error messages

### Navigation
- Use named routes defined in `main.dart`
- `Navigator.pushReplacementNamed()` for full page transitions
- `showSearch()` for search functionality

### Theme and Styling
- **Theme**: Material Design dark theme
- **Primary color**: Blue
- **Accent color**: Red (#f4796b)
- **Font**: Default Material font
- All colors centralized in `lib/config/colors.dart`

### Utility Class Pattern
Use private constructors to prevent instantiation for utility classes:
```dart
class AppColors {
  AppColors._(); // Private constructor
  static const Color primary = Colors.blue;
  static const Color accent = Color(0xfff4796b);
}
```

## Project Structure
```
lib/
├── config/              # Configuration files
│   ├── colors.dart      # Theme colors (AppColors utility class)
│   └── constants.dart   # API URLs, default values (AppConstants class)
├── models/              # Data models
│   └── covid_models.dart  # GlobalStats, CountryStats, TimelineDataPoint
├── screens/             # Page widgets
│   ├── home.dart           # Home screen with global data and charts
│   ├── country_list.dart   # Country list with folding cells
│   └── country_search.dart # Search functionality
├── services/            # Service layer
│   └── api_service.dart    # API service (getAllData, getAllCountriesData)
└── widgets/             # Reusable components
    ├── drawer.dart         # Navigation drawer
    ├── folding_cell.dart   # Expandable list cells
    ├── graph.dart         # Chart component (fl_chart)
    └── info_card.dart     # Info card widget
```

## Key Dependencies
- `http ^1.2.0` - API requests
- `fl_chart ^0.66.0` - Chart visualization
- `number_display ^2.2.1` - Large number formatting
- `folding_cell ^0.1.2` - Expandable list cells
- `cupertino_icons ^1.0.0` - iOS-style icons
- `flutter_lints ^3.0.0` - Code linting (relaxed for learning)

## Linter Configuration
The project uses relaxed lint rules intentionally for learners:
- `prefer_const_constructors: false`
- `use_key_in_widget_constructors: false`
- `prefer_final_fields: false`
- `avoid_print: false`

## Testing
- Tests located in `test/` directory
- Use `flutter test` to run all tests
- Use `flutter test --name="test_name"` for specific tests
- Widget tests use `WidgetTester` for interaction testing

## Theme and Styling
- **Theme**: Material Design dark theme
- **Primary color**: Blue
- **Accent color**: Red (#f4796b)
- **Font**: Default Material font
- All colors centralized in `lib/config/colors.dart`

## API Integration
- **API Provider**: disease.sh (free public COVID-19 API)
- **Endpoints**:
  - Global data: `https://disease.sh/v3/covid-19/all`
  - Countries: `https://disease.sh/v3/covid-19/countries?sort=country`
  - History: `https://disease.sh/v3/covid-19/historical/{country}`
- All API calls centralized in `ApiService` class
- Always handle HTTP status codes and parse errors

## Language and Localization
- **UI text**: Simplified Chinese
- **Comments**: Simplified Chinese with English technical terms
- **Code**: English variable names, Chinese explanations

## When Adding New Features
1. Define data models in `lib/models/` if new data structures needed
2. Add API methods in `lib/services/api_service.dart`
3. Create screen widgets in `lib/screens/`
4. Extract reusable widgets to `lib/widgets/`
5. Add constants to `lib/config/constants.dart` or colors to `lib/config/colors.dart`
6. Follow existing naming and formatting conventions
7. Add Chinese documentation for all public APIs
8. Handle errors gracefully with user-friendly messages

## Chrome Debug Port Configuration

### Fixed Debug Port Issue

**Problem**: 每次启动 Chrome 浏览器调试时，`flutter run -d chrome` 会自动分配不同的端口（如 8080, 8081, 8082...），导致多个调试终端同时打开，造成混乱和资源占用。

**Solution**: 每次使用固定的调试端口，避免重复启动。

### How to Use Fixed Port

**方法 1: 使用固定端口号启动**
```bash
flutter run -d chrome --web-port=30000
```

**方法 2: 在 VS Code 中配置调试端口（推荐）**
在项目根目录创建 `.vscode/launch.json`：
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter",
      "type": "dart",
      "request": "launch",
      "args": [
        "-d",
        "chrome",
        "--web-port=30000"
      ]
    }
  ]
}
```

### 为什么使用固定端口

1. **避免冲突**: 固定端口确保不会与其他应用冲突
2. **资源优化**: 减少打开多余 Chrome 实例
3. **调试一致性**: 保持相同的调试环境配置
4. **可预测**: 端口号固定，便于记忆和使用

### 注意事项

- 如果端口 30000 被占用，可以尝试其他端口（如 30001, 30002）
- 使用 VS Code 的 "Run and Debug" 按钮可以直接启动调试，无需手动输入命令
- 确保 Chrome 浏览器已关闭（Ctrl+Shift+W 或点击停止按钮）

---

**Last Updated**: 2026-01-23 - Added Chrome debug port configuration guide
