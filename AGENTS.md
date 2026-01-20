# AGENTS.md - Codebase Guide for COVID-19 Tracker Flutter App

## Project Overview
This is a Flutter learning project (COVID-19 pandemic tracker) written in Dart with extensive Chinese documentation. The project demonstrates clean architecture with clear separation of concerns.

## Build, Lint, and Test Commands

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

# Run with coverage
flutter test --coverage

# Analyze code for issues
flutter analyze

# Fix linting issues automatically
dart fix --apply

# Build release APK
flutter build apk --release

# Build iOS app
flutter build ios --release
```

## Code Style Guidelines

### Import Conventions
- Use **relative imports** from `lib/` directory (no absolute package paths)
- Group external packages first, then local imports
- No unused imports allowed

```dart
import 'package:flutter/material.dart';  // External package
import '../services/api_service.dart';   // Relative import
import '../config/colors.dart';          // Relative import
```

### Formatting
- **Indentation**: 2 spaces (Dart convention)
- **Quotes**: Single quotes for all strings
- **Semicolons**: Always present (Dart requirement)
- **Trailing commas**: Required for multi-line lists and constructor calls

```dart
class Example extends StatelessWidget {
  const Example({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Title'),
        SizedBox(height: 16),
      ],
    );
  }
}
```

### Type System (Dart)
- Use **explicit type annotations** for parameters and return types
- Use **`final`** for immutable properties
- Use **`required`** keyword for constructor parameters
- Type assertion pattern: `as Type? ?? defaultValue`

```dart
class Model {
  final String name;
  final int count;

  Model({required this.name, required this.count});

  factory Model.fromJson(Map<String, dynamic> json) {
    return Model(
      name: json['name'] as String? ?? '',
      count: json['count'] as int? ?? 0,
    );
  }
}
```

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

```dart
try {
  final response = await http.get(url);
  if (response.statusCode != 200) {
    throw Exception('请求失败: HTTP ${response.statusCode}');
  }
  return response.body;
} on http.ClientException catch (e) {
  throw Exception('网络连接错误: ${e.message}');
} on FormatException catch (e) {
  throw Exception('数据格式错误: ${e.message}');
} catch (e) {
  throw Exception('未知错误: $e');
}
```

### Comments and Documentation
- **Classes and public methods**: Use `///` Dart doc comments
- **Inline comments**: Chinese language, descriptive
- **Code examples**: Markdown format in doc comments
- **Section dividers**: Use visual separators in constants

```dart
/// API服务类
///
/// 负责从COVID-19数据API获取所有数据
/// 使用免费的public API: disease.sh
class ApiService {
  ApiService._(); // 私有构造函数，防止实例化

  /// 获取全球数据和特定国家的历史数据
  ///
  /// 返回一个Map包含：
  /// - 'all': 全球总数据
  /// - 'country': 特定国家的每日病例数据
  static Future<Map<String, dynamic>> getAllData() async {
    // 实现代码
  }
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

## Widget Patterns

### Stateless vs Stateful
- Prefer `StatelessWidget` for screens
- Use `StatefulWidget` only when internal state management is required
- Always include `super.key` parameter

### Async Data Loading
- Use `FutureBuilder` for async operations
- Handle `waiting`, `hasError`, and `hasData` states
- Provide loading indicators and error messages

```dart
FutureBuilder<Map<String, dynamic>>(
  future: ApiService.getAllData(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }
    if (snapshot.hasError) {
      return Text('加载失败: ${snapshot.error}');
    }
    final data = snapshot.data!;
    return YourWidget(data);
  },
)
```

### Navigation
- Use named routes defined in `main.dart`
- `Navigator.pushReplacementNamed()` for full page transitions
- `showSearch()` for search functionality

## Utility Class Pattern
Use private constructors to prevent instantiation for utility classes:
```dart
class AppColors {
  AppColors._(); // Private constructor
  static const Color primary = Colors.blue;
  static const Color accent = Color(0xfff4796b);
}
```

## Key Dependencies
- `http ^1.2.0` - API requests
- `fl_chart ^0.66.0` - Chart visualization
- `number_display ^2.2.1` - Large number formatting
- `folding_cell ^0.1.2` - Expandable list cells
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
  - Countries: `https://disease.sh/v3/covid-19/countries`
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
