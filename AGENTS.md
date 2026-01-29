# AGENTS.md - Codebase Guide for COVID-19 Tracker Flutter App

## Project Overview
Enterprise-grade Flutter COVID-19 tracker using modern architecture (Riverpod, Dio, GoRouter). Clean separation of concerns with dependency injection and state management best practices.

## Build, Lint, and Test Commands

### Installation
```bash
cd helloFluDemo && flutter pub get
```

### Running the App
```bash
# Run on connected device/emulator
flutter run

# Specific platforms
flutter run -d android
flutter run -d ios
flutter run -d chrome

# Chrome with fixed debug port (prevents multiple instances)
flutter run -d chrome --web-port=30000
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test by name
flutter test --name="test_name_here"

# Run single test file
flutter test test/widget_test.dart
```

### Code Quality
```bash
# Analyze code
flutter analyze

# Fix linting issues automatically
dart fix --apply

# Format code
dart format .
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
- Catch specific exceptions: `DioException` (not `http.ClientException`)
- Always include generic `catch` fallback
- Provide user-friendly error messages in Chinese
- Use `AsyncValue.when()` for async error handling in UI (Riverpod)
- Use `AsyncValue.guard()` for error wrapping in notifiers

### State Management (Riverpod)
- **StateNotifier Pattern**: Extend `StateNotifier<T>` for stateful logic
- **ConsumerWidget**: Use for screens that read state (`ref.watch()`)
- **ConsumerStatefulWidget**: Use when needing `initState` with `ref.read()`
- **Dependency Injection**: Inject dependencies via constructor parameters
- **Provider Types**:
  - `Provider<T>`: Read-only values (theme, locale, services)
  - `StateNotifierProvider<T, State>`: Mutable state with business logic
  - `FutureProvider.family<T, Arg>`: Async data with parameters
  - `AsyncValue`: Handle `loading`, `data`, `error` states

### Provider Organization
- All providers defined in `lib/providers/providers.dart`
- Group by purpose: Config → Services → State → Route
- Use `ref.watch()` for dependencies between providers
- Use `ref.read()` for one-time reads (e.g., in callbacks)

### Comments and Documentation
- **Classes and public methods**: Use `///` Dart doc comments
- **Inline comments**: Chinese language, descriptive
- **Code examples**: Markdown format in doc comments
- **Section dividers**: Use visual separators in constants

### Widget Patterns

**Stateless vs Stateful**: Prefer `StatelessWidget` for screens; use `StatefulWidget` only when internal state management is required. Always include `super.key` parameter.

**Async Data Loading**: Use `FutureBuilder` for async operations. Handle `waiting`, `hasError`, and `hasData` states. Provide loading indicators and error messages.

**Navigation**: Use GoRouter for navigation (configured in `lib/providers/providers.dart`). `context.push()` for navigation, `context.pop()` to go back, `context.pushReplacement()` to replace current route.

**Theme and Styling**: Material Design dark theme, primary color blue, accent color red (#f4796b). All colors centralized in `lib/config/colors.dart`.

### Utility Class Pattern
Use private constructors to prevent instantiation for utility classes:
```dart
class AppColors {
  AppColors._();
  static const Color primary = Colors.blue;
  static const Color accent = Color(0xfff4796b);
}
```

## Project Structure
```
lib/
├── config/              # Configuration files (colors, constants)
├── core/               # Core functionality
│   └── network/        # Network layer (dio_client.dart)
├── models/             # Data models (covid_models.dart)
├── notifiers/          # State notifiers (Riverpod)
├── providers/          # Riverpod providers (providers.dart)
├── screens/            # Page widgets
├── services/           # Service layer (api_service.dart)
└── widgets/            # Reusable components
```

## Key Dependencies
- `dio ^5.7.0` - HTTP client (enterprise-grade, interceptors)
- `flutter_riverpod ^2.6.1` - State management & dependency injection
- `go_router ^14.6.0` - Declarative routing
- `logger ^2.4.0` - Logging
- `shared_preferences ^2.3.2` - Key-value storage
- `flutter_dotenv ^5.1.0` - Environment configuration
- `intl ^0.20.1` - Internationalization
- `fl_chart ^0.70.1` - Chart visualization
- `cupertino_icons ^1.0.8` - iOS-style icons
- `flutter_lints ^5.0.0` - Code linting (relaxed for learning)

## Linter Configuration
Relaxed lint rules for learners: `prefer_const_constructors`, `use_key_in_widget_constructors`, `prefer_final_fields`, `prefer_const_literals_to_create_immutables`, `prefer_const_constructors_in_immutables`, `avoid_print` all set to `false`.

## Testing
Tests located in `test/` directory. Use `flutter test` to run all tests, `flutter test --name="test_name"` for specific tests. Widget tests use `WidgetTester` for interaction testing.

## API Integration
- **API Provider**: disease.sh (free public COVID-19 API)
- **Endpoints**:
  - Global: `https://disease.sh/v3/covid-19/all`
  - Countries: `https://disease.sh/v3/covid-19/countries?sort=country`
  - History: `https://disease.sh/v3/covid-19/historical/{country}`
- All API calls centralized in `ApiService` class using `DioClient.dio`
- Always handle HTTP status codes and parse errors

## Language and Localization
UI text: Simplified Chinese. Comments: Simplified Chinese with English technical terms. Code: English variable names, Chinese explanations.

## When Adding New Features
1. Define data models in `lib/models/` if new data structures needed
2. Add API methods in `lib/services/api_service.dart`
3. Create screen widgets in `lib/screens/`
4. Extract reusable widgets to `lib/widgets/`
5. Add constants to `lib/config/constants.dart` or colors to `lib/config/colors.dart`
6. Follow existing naming and formatting conventions
7. Add Chinese documentation for all public APIs
8. Handle errors gracefully with user-friendly messages

## Environment Configuration
Environment variables loaded via `flutter_dotenv` (`.env` files in root). Environment switching: `flutter run --dart-define=ENVIRONMENT=production`. Configuration read from `lib/config/app_config.dart`.

## Chrome Debug Port Configuration

### Fixed Debug Port Issue

**Problem**: `flutter run -d chrome` auto-assigns different ports (8080, 8081...), causing multiple Chrome instances.

**Solution**: Use fixed port to prevent duplicate instances.

### How to Use Fixed Port

```bash
# Method 1: Command line
flutter run -d chrome --web-port=30000

# Method 2: VS Code - Create `.vscode/launch.json`
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter",
      "type": "dart",
      "request": "launch",
      "args": ["-d", "chrome", "--web-port=30000"]
    }
  ]
}
```

**Benefits**: Avoid port conflicts, reduce Chrome instances, consistent debugging
**Notes**: Use alternate ports (30001, 30002) if 30000 is occupied

---

**Last Updated**: 2026-01-29 - Updated for enterprise architecture (Riverpod, Dio, GoRouter)

