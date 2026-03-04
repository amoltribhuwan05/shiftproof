---
description: Shiftproof Flutter Screen States & Data Models
---

# Shiftproof Screen States & Models

## 1. Data Models (`lib/models/`)

- **Immutability Mandate:** All data models must be strictly immutable. Enforce `freezed` or `equatable` + `copyWith`.

### Required Core Models

- `user_model.dart`
- `property_model.dart`
- `room_model.dart`
- `tenant_model.dart`
- `payment_model.dart`

## 2. Screen States

Separation between UI and business logic is mandatory. Screens must respond to a strict `ViewState`.

### Mandatory State Types

- **Loading:** Render explicit shimmer loaders (not blocking spinners) during data fetch.
- **Empty:** Enforce actionable empty states (e.g., "Add Property" button).
- **Loaded:** Default successful UI population.
- **Error:** Catch all failures. Present user-friendly error messages accompanied by a "Retry" mechanism.

### Implementation Pattern

Use strongly typed branches for evaluating properties.

```dart
abstract class ScreenState {}
class ScreenInitial extends ScreenState {}
class ScreenLoading extends ScreenState {}
class ScreenLoaded<T> extends ScreenState { final T data; ScreenLoaded(this.data); }
class ScreenError extends ScreenState { final String message; ScreenError(this.message); }
```
