---
description: Shiftproof Flutter Module Architecture & Routing
---

# Shiftproof Flutter Module-Wise Architecture

This guide details the module-wise breakdown of the Shiftproof application. Use this document to understand where to place features, files, and logic when scaling the application.

## Core Modular Breakdown

The project follows a feature-first/module-first approach, housed primarily under `lib/screens/` and `lib/core/`. The key modules are:

### 1. **Auth & Onboarding Module** (`lib/screens/auth/`)

Handles user entry, authentication, and role selection.

- **`GetStartedScreen`**: The intro screen where the user selects their role (Property Owner vs. Tenant). Sets the initial context for the application.
- **Future Growth**: Login, Signup, OTP Verification screens should reside here.

### 2. **Dashboard Module** (`lib/screens/dashboard/`)

The primary landing screens post-authentication, heavily split by role.

- **`TenantDashboardScreen`**: Overview of tenant's current stay, upcoming rent, open complaints, and notices. Uses Light/White mapping heavily.
- **`PropertyDashboardScreen`**: Overview for the property owner regarding total collections, vacant beds, and major alerts.

### 3. **Properties Module** (`lib/screens/properties/`)

Everything related to managing physical assets (buildings, rooms, beds).

- **`MyPropertiesScreen`**: List view of all properties managed by an owner.
- **`PropertyDetailsScreen`**: Deep dive into a specific property.
- **`AddPropertyScreen` & `RoomBedSetupScreen`**: Complex multi-step flows for onboarding a new building and mapping out its exact room/bed capacity.
- **`ManageTenantsScreen`**: A hybrid screen showing occupied vs. available beds within a property context.
- **`ExportReportScreen`**: Generating occupancy and collection analytics.

### 4. **Tenant Management Module** (`lib/screens/tenant/`)

For the tenant user executing actions relative to finding or interacting with a property.

- **`FindPgScreen`**: Browsing and searching for available rentals.
- **`JoinPgScreen`**: Entering a specific code or scanning a QR to formally request to join an existing PG.

### 5. **Payments & Finances Module** (`lib/screens/payments/`)

Handles all transactions and financial tracking for both roles.

- **`PayBillScreen`**: Tenant interface for clearing monthly dues (Rent, Electricity, etc.).
- **`CollectionsScreen`**: Owner interface showing total cash flow grouped by month/property.
- **`PayoutsScreen`**: Owner interface for tracking funds settled to their bank.
- **`PaymentHistoryScreen`**: Ledger of past transactions for a tenant.
- **`OwnerPlansScreen`**: SaaS pricing tier selection for the property owner.

### 6. **User & Profile Module** (`lib/screens/profile/`)

Global user settings and profile management.

- **`ProfileScreen`**: Standard user details, app navigation elements (FAQs, Support, Logout).

## Shared Architecture

### Core Foundation (`lib/core/`)

- `lib/core/constants/colors.dart`: Strict definitions mapping branding colors to Material themes.
- `lib/core/theme/app_theme.dart`: The single source of truth for `ThemeData` generation (Light/Dark).

### Reusable Widgets (`lib/widgets/`)

To maintain consistency and reduce duplication, components are globally shared:

- **`buttons/`**: Standard interactive elements (`PrimaryButton`, `SocialButton`) that auto-adapt to themes.
- **`cards/`**: Standard display elements (`PropertyCard`, `ProfileMenuCard`).
- **`nav/`**: Reusable navigation bars (`OwnerBottomNav`, `TenantBottomNav`).

## Routing Strategy

- Application currently implements standard `Navigator.push` and `Navigator.pop`.
- When transitioning to a robust router (like `go_router`), separate the routes per module to maintain clean dependency trees.
