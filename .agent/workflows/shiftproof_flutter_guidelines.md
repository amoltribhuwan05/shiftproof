---
description: Shiftproof Flutter Development Guidelines & Skills
---

# Shiftproof Application - Flutter Agent Skill

This guide outlines the architectural, theming, and development standards for building the Shiftproof mobile application in Flutter. Use this document as the source of truth whenever generating or refactoring Flutter code for this project.

## Core Directives

1. **Unified Design**: The UI must be identical and unified across Android and iOS platforms. Avoid platform-specific widgets (like `CupertinoXYZ`) unless absolutely necessary for core UX flows. Rely primarily on Material 3 widgets that are customized to look cross-platform standard.
2. **Theming System**: The application strictly supports two themes using Flutter's `ThemeData`:
   - **Light Mode**: Primary colors are Blue and White.
   - **Dark Mode**: Primary colors are Dark Black and Blue.
   - Always map colors through `Theme.of(context).colorScheme` or specific custom theme extensions. Hardcoded color hex codes inside widget trees are prohibited.
3. **Responsive UI**: Screen layouts should adapt elegantly. Use `LayoutBuilder`, `MediaQuery`, or responsive packages appropriately. Avoid hardcoded fixed widget sizes where text scaling might clip.

## Project Structure

```text
lib/
├── core/
│   ├── constants/
│   │   ├── colors.dart       # Color definitions
│   │   └── text_styles.dart  # Typography definitions
│   ├── theme/
│   │   └── app_theme.dart    # ThemeData configurations for Light and Dark modes
│   ├── utils/                # Helper functions
│   └── routing/              # Navigation setup
├── widgets/                  # Reusable globally-shared UI components
│   ├── buttons/
│   ├── inputs/
│   └── cards/
├── screens/                  # Independent screen implementations
│   ├── auth/
│   ├── dashboard/
│   ├── properties/
│   ├── payments/
│   └── profile/
└── models/                   # Data models
```

## Theming Implementation

All thematic styling should be centralized in `lib/core/theme/app_theme.dart`.

```dart
// Example structure:
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: Colors.white,
      // Configure TextTheme, ButtonTheme, etc.
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: Colors.black, // Dark Black
      // Configure TextTheme, ButtonTheme, etc.
    );
  }
}
```

## State Management Approach

For this phase, utilize lightweight standard approaches (e.g., `Provider`, `ValueNotifier`, or `Riverpod`, based on project configuration) to manage view state. Decouple business logic from UI elements. Models should be immutable where possible.

## Execution Rules

- Before creating a new UI component, check if a suitable generalized widget exists in `lib/widgets/`.
- Ensure new files follow Dart naming conventions (`snake_case.dart` for files, `CamelCase` for classes).
- Update these guidelines as the architectural patterns evolve or new critical libraries are introduced.
