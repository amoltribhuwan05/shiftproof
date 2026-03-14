# ShiftProof

ShiftProof is a comprehensive property management and tenant portal mobile application built with Flutter.

## Overview

The application features role-based access for both property owners and tenants:

- **For Owners**: Dashboard for properties, rent collection, occupancy status, tenant management, and payment history.
- **For Tenants**: Dashboard for rent payment, upcoming dues, maintenance requests, and announcements.

## UI Architecture & Guidelines

This project strictly adheres to a centralized UI design system to ensure consistency, responsiveness, and performance.

### Core Principles

1. **Theming & Styling**
   - **No Hardcoded Values:** Colors, text styles, and spacing are driven by `Theme.of(context)`. The `lib/core/theme/app_theme.dart` is the single source of truth.
   - **Dynamic Theme Support:** Full support for dynamic color switching (Light / Dark mode) utilizing `theme.colorScheme`.

2. **Responsiveness & Adaptive Layouts**
   - Built to be screen-agnostic, adapting to different aspect ratios safely using `Expanded`, `Flexible`, and grid delegates.
   - Uses `SafeArea` to prevent overlap with notches and navigation bars.
   - Strict adherence to scrollable boundaries (`SingleChildScrollView`, `ListView`, `CustomScrollView`) avoiding overflow errors.

3. **Reusability**
   - Standardized atomic components are isolated within the `lib/widgets/` directory.
   - Complex inline builders have been extracted to generic, parameterized stateless widgets.

4. **Performance Constraints**
   - Pervasive use of `const` constructors for unmutating rendering paths.
   - Use of `CustomScrollView` and sliver delegates for efficient rendering of heavy dynamic lists.
   - Clean architecture separating services, screens, and reusable widgets.

## Development

Before committing code, ensure the following checks pass:

```bash
# Format the codebase
dart format lib/

# Run static analysis
dart analyze lib/
```

## Setup

1. Install Flutter (minimum version according to `pubspec.yaml`).
2. Run `flutter pub get` to fetch dependencies.
3. Run `flutter run` on an emulator or physical device.

## Directory Structure

```text
lib/
├── core/            # App-wide theme and color constants
├── data/            # Data models and API client
├── features/        # Feature-specific components
├── screens/         # UI Screens grouped by feature module
├── services/        # Real Backend API services (e.g., UserService)
└── widgets/         # Reusable atomic UI components
    ├── buttons/     # Standardized app buttons
    ├── cards/       # Various reusable cards
    ├── nav/         # Bottom navigation bars
    └── network/     # Network status and connection wrappers
```

## Documentation

| Document                                           | Description                                                                                    |
| -------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| [Backend Development Guide](docs/backend_guide.md) | **Start here for backend work** — API contracts, type rules, business logic, Antigravity setup |
| [API Response Structures](docs/api_responses.md)   | Detailed JSON schemas and field reference for all endpoints                                    |

## Important Implementation Details

- **State Management:** Screens primarily rely on local `setState` combined with stateless presentation widgets.
- **Routing:** Current routing utilizes `Navigator.push` and `Navigator.pushReplacement` with `MaterialPageRoute`.
- **Services Architecture:** 
  - **Mock Services:** Located in `lib/data/services/mock_api_service.dart`. Used for UI prototyping.
  - **Real Services:** Located in `lib/services/`. These interact with the real backend via `ApiClient`. (e.g., `UserService` for profile management).
- **UI Performance/Layout:** Ensure heavily scrolling lists utilizing `ListView.builder` or `SliverList` bounds remain wrapped properly to avoid render overflows on smaller screens. Explicit padding/spacing strictly adheres to an 8-point grid paradigm.
