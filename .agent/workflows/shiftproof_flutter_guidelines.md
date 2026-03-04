---
description: Shiftproof Flutter Development Guidelines & Skills
---

# Shiftproof Application Guidelines

## 1. Core Directives

- **Unified Design:** Enforce identical UI across Android and iOS. Prohibit platform-specific widgets (like `CupertinoXYZ`). Rely on customized Material 3 widgets.
- **Theming System:** Support exactly two `ThemeData` options (Light/Dark). Hardcoded hex codes are prohibited. Use `Theme.of(context).colorScheme`.
- **Responsive UI:** Enforce dynamic layouts. Avoid hardcoded fixed widget sizes.

## 2. Project Structure

Enforce strict separation into directories:

- `lib/core/` (constants, theme, utils, routing)
- `lib/widgets/` (reusable globally-shared UI)
- `lib/screens/` (independent screen logic)
- `lib/models/` (immutable data models)

## 3. Theming Implementation

- **Centralized Source:** `lib/core/theme/app_theme.dart` must act as the absolute single source of truth for `ThemeData` configuration.

## 4. Execution Rules

- **Component Analysis:** Ensure a generalized widget doesn't exist in `lib/widgets/` before building a new one.
- **Naming Conventions:** Follow Dart naming conventions (`snake_case.dart` for files, `CamelCase` for classes) strictly.
