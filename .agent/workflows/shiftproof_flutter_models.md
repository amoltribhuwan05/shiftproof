---
description: Shiftproof Flutter Screen States & Data Models
---

# Shiftproof Flutter Screen States & Data Models

This guide outlines how to handle states and model data throughout the different screens of the Shiftproof application. Use this document when adding new data models or screen states.

## Data Models

All data models should reside in `lib/models/`. Data models should be immutable and preferably use a code generation package like `freezed` or standard `equatable` classes + `copyWith` methods to ensure robust equality checking and state immutability.

### Core Models Structure

- **User Model (`user_model.dart`)**: Represents the logged-in user (Owner, Tenant, Admin). Contains personal info, role, and authentication tokens.
- **Property Model (`property_model.dart`)**: Represents a PG, Flat, or House. Contains details like name, location, total beds, amenities, images, and property configurations.
- **Room Model (`room_model.dart`)**: Represents a specific unit/room within a property. Details include room number, type (Private, Shared), total beds, occupied beds, and specific room amenities.
- **Tenant Model (`tenant_model.dart`)**: Represents an active tenant assigned to a room/bed. Includes tenant personal details, lease status, and payment standing.
- **Payment Model (`payment_model.dart`)**: Represents a transaction (rent, deposit, maintenance). Includes amount, due date, status (Paid, Pending, Overdue), and payment method.

## Screen States

Screens should clearly separate UI from business logic. A given screen should ideally react to a well-defined `ViewState` object stringently describing its loading, empty, loaded, or error states.

### State Types

1. **Loading State**: Shown when fetching API data. Often represented by shimmer effects or a centered progress indicator.
2. **Empty State**: Shown when a list (like My Properties or Collections) is empty. Use descriptive empty state widgets with clear call-to-action buttons (e.g., "Add your first property").
3. **Loaded State**: The standard successful data-populated UI.
4. **Error State**: Whenever an API call fails or connectivity drops. Show a user-friendly error message and a "Retry" button.

### Implementation Pattern

When managing states, follow this structural pattern:

```dart
// Example State Representation
abstract class ScreenState {}

class ScreenInitial extends ScreenState {}
class ScreenLoading extends ScreenState {}
class ScreenLoaded<T> extends ScreenState {
  final T data;
  ScreenLoaded(this.data);
}
class ScreenError extends ScreenState {
  final String message;
  ScreenError(this.message);
}
```

- View components (Widgets) should strictly listen to these states and return the appropriate UI branch according to the current state type.
- Complex forms (like Add Property) should maintain form validation states and loading states independently for submitting data.
