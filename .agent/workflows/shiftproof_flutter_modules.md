---
description: Shiftproof Flutter Module Architecture & Routing
---

# Shiftproof Module-Wise Architecture

## 1. Core Modular Breakdown (`lib/screens/`)

### Auth & Onboarding (`lib/screens/auth/`)

- Enforce boundaries around `GetStartedScreen` and specific role (Owner/Tenant) initial states.
- **Unified Auth Pattern**: Email authentication should _always_ route through a single `email_auth_screen.dart` that attempts sign in first.
  - If `invalid-credential` or `user-not-found` is thrown, smoothly route arguments (email, password) to `email_registration_screen.dart` to gather just the remaining info (Full Name) to complete sign up.

### Dashboard (`lib/screens/dashboard/`)

- Enforce strict role contexts: `TenantDashboardScreen` vs `PropertyDashboardScreen`.

### Properties (`lib/screens/properties/`)

- Restrict asset context logic here: `MyPropertiesScreen`, `PropertyDetailsScreen`, `AddPropertyScreen`, `RoomBedSetupScreen`, `ManageTenantsScreen`, `ExportReportScreen`.

### Tenant Management (`lib/screens/tenant/`)

- Enforce search and interaction boundaries: `FindPgScreen`, `JoinPgScreen`.

### Payments & Finances (`lib/screens/payments/`)

- Restrict logic around transaction components: `PayBillScreen`, `CollectionsScreen`, `PayoutsScreen`, `PaymentHistoryScreen`, `OwnerPlansScreen`.

### User & Profile (`lib/screens/profile/`)

- Manage global state boundaries: `ProfileScreen`, Support, Logout flows.

## 2. Shared Architecture

- **Core Foundation (`lib/core/`):** Strict thematic mapping.
- **Reusable Widgets (`lib/widgets/`):** Shared interaction logic `buttons/`, `cards/`, `nav/`.

## 3. Routing Strategy

- Restrict module navigation chains to maintain dependency trees cleanly during `Navigator`/`go_router` transitions.
