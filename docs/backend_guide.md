# ShiftProof — Backend Development Guide

> **Single source of truth** for anyone starting backend work on ShiftProof. Covers all API contracts, enforced data type rules, business logic, and how the Antigravity AI assistant is configured for this project.

---

## 1. Project Overview

ShiftProof is a **property management and tenant portal** app targeting PG/hostel owners and tenants in India.

**Two user roles:**
| Role | Access |
|---|---|
| `owner` | Manage properties, view rent collections, payouts, tenant list |
| `tenant` | View current stay, pay rent, view payment history, notifications |

**Current stack:** Flutter (Dart) mobile app with `MockApiService` backed by `lib/data/mock_api.dart`. The mock service is a **drop-in replacement** layer — each method maps 1:1 to a real REST endpoint.

---

## 2. Replacing the Mock Layer

To connect a real backend, open `lib/data/services/mock_api_service.dart` and replace each method body with an HTTP call. The `fromJson` factories on every model are already written and will deserialize the API response directly.

**Example swap:**

```dart
// Current (mock):
static List<Property> getProperties() =>
    MockApi.properties.map(Property.fromJson).toList();

// Real backend:
static Future<List<Property>> getProperties() async {
  final res = await http.get(Uri.parse('$baseUrl/properties'),
      headers: {'Authorization': 'Bearer $token'});
  final List data = jsonDecode(res.body);
  return data.map((j) => Property.fromJson(j)).toList();
}
```

---

## 3. Base URL & Auth

```
Base URL:     https://api.shiftproof.in/v1
Auth:         Bearer <JWT> in Authorization header
Content-Type: application/json
```

**Standard error envelope:**

```json
{ "error": "Resource not found", "code": 404 }
```

---

## 4. Enforced Data Type Rules

> ⚠️ Breaking these will cause runtime crashes in the Flutter `fromJson` factories.

| Data category                     | API / DB type      | Example                  | ❌ Never       |
| --------------------------------- | ------------------ | ------------------------ | -------------- |
| Money (amounts, prices, deposits) | `integer` (rupees) | `8500`                   | `"₹8,500"`     |
| Ratings                           | `float/double`     | `4.8`                    | `"4.8"`        |
| Dates                             | ISO 8601 string    | `"2026-03-05"`           | `"5 Mar 2026"` |
| Timestamps                        | ISO 8601 datetime  | `"2026-03-04T22:00:00Z"` | `"2h ago"`     |
| Room/count fields                 | `integer`          | `16`                     | `16.0`         |
| Booleans                          | `boolean`          | `true`                   | `"true"` / `1` |

**UI formatting:** The Flutter app uses `CurrencyFormatter.format(int amount)` in `lib/core/utils/currency_formatter.dart` to display `"₹8,500"`. The API must never send pre-formatted strings.

---

## 5. Complete API Contract

### 5.1 Authentication

| Method | Path                    | Description                      | Auth      |
| ------ | ----------------------- | -------------------------------- | --------- |
| POST   | `/auth/login`           | Phone + OTP → returns JWT + user | ❌        |
| GET    | `/auth/me`              | Get current user profile         | ✅        |
| POST   | `/auth/logout`          | Invalidate JWT                   | ✅        |
| GET    | `/auth/me/current-stay` | Tenant's active stay details     | ✅ tenant |
| POST   | `/auth/device-token`    | Register FCM push token          | ✅        |

**AppUser schema:**

```json
{
  "id": "usr_001",
  "name": "Amol Sharma",
  "email": "amol.sharma@example.com",
  "phone": "+91 98765 43210",
  "avatarUrl": "https://...",
  "role": "owner",
  "joinDate": "2023-01-15",
  "location": "Bangalore, Karnataka"
}
```

> `role`: `"owner"` | `"tenant"`  
> `joinDate`: ISO date string `"YYYY-MM-DD"`

**CurrentStay schema (tenant only):**

```json
{
  "propertyName": "Sunnyvale PG",
  "roomNumber": "Room 302",
  "address": "14th Cross, Koramangala, Bangalore - 560034",
  "rentAmount": 8500,
  "dueDate": "2026-03-05",
  "ownerName": "Amol Sharma",
  "ownerPhone": "+91 98765 43210",
  "ownerAvatarUrl": "https://...",
  "leaseStart": "2025-06-01",
  "leaseEnd": "2026-05-31",
  "imageUrl": "https://...",
  "isRentDue": true
}
```

---

### 5.2 Properties

| Method | Path               | Description                                     | Role  |
| ------ | ------------------ | ----------------------------------------------- | ----- |
| GET    | `/properties`      | List all (owner: theirs; tenant: all available) | ✅    |
| GET    | `/properties/{id}` | Single property                                 | ✅    |
| POST   | `/properties`      | Create property                                 | owner |
| PUT    | `/properties/{id}` | Update property                                 | owner |
| DELETE | `/properties/{id}` | Soft delete                                     | owner |

**Property schema:**

```json
{
  "id": "prop_001",
  "title": "Sunnyvale PG",
  "location": "Koramangala, Bangalore",
  "type": "PG",
  "price": 8500,
  "deposit": 17000,
  "rating": 4.8,
  "imageUrl": "https://...",
  "totalRooms": 16,
  "occupiedRooms": 12,
  "description": "...",
  "amenities": ["WiFi", "AC", "Meals"],
  "ownerName": "Amol Sharma",
  "ownerAvatarUrl": "https://..."
}
```

> `type`: `"PG"` | `"Flat"` | `"House"`  
> `price`, `deposit`: integer rupees  
> `rating`: float (double)  
> `totalRooms`, `occupiedRooms`: integer

---

### 5.3 Rooms & Beds

| Method | Path                              | Description            |
| ------ | --------------------------------- | ---------------------- |
| GET    | `/properties/{id}/rooms`          | Room and bed breakdown |
| PUT    | `/properties/{id}/rooms/{roomId}` | Update room config     |

**Room schema:**

```json
{
  "id": "room_001",
  "roomNumber": "Room 101",
  "type": "single",
  "totalBeds": 1,
  "occupiedBeds": 1,
  "pricePerBed": 8500,
  "amenities": ["AC", "Attached Bathroom"],
  "tenantIds": ["ten_002"]
}
```

> `type`: `"single"` | `"shared"` | `"dormitory"`  
> `pricePerBed`: integer rupees

---

### 5.4 Tenants

| Method | Path                                  | Description            | Role  |
| ------ | ------------------------------------- | ---------------------- | ----- |
| GET    | `/properties/{id}/tenants`            | Tenants for a property | owner |
| GET    | `/tenants/{id}`                       | Single tenant profile  | owner |
| POST   | `/properties/{id}/tenants/invite`     | Invite new tenant      | owner |
| DELETE | `/properties/{id}/tenants/{tenantId}` | Remove tenant          | owner |

**Tenant schema:**

```json
{
  "id": "ten_001",
  "name": "Riya Mehta",
  "room": "Room 302",
  "rentAmount": 8500,
  "dueDate": "2026-03-05",
  "isPaid": false,
  "avatarUrl": "https://...",
  "phone": "+91 87654 32109",
  "email": "riya.mehta@example.com",
  "joinDate": "2025-06-01",
  "propertyId": "prop_001",
  "status": "overdue"
}
```

> `rentAmount`: integer rupees  
> `dueDate`, `joinDate`: ISO date `"YYYY-MM-DD"`  
> `status`: `"active"` | `"pending"` | `"overdue"`

---

### 5.5 Payments

| Method | Path                                  | Description             | Role   |
| ------ | ------------------------------------- | ----------------------- | ------ |
| GET    | `/payments`                           | User's payment history  | ✅     |
| GET    | `/payments?propertyId=&status=&type=` | Filtered payments       | ✅     |
| POST   | `/payments`                           | Initiate payment        | tenant |
| GET    | `/payments/collections`               | Rent-type payments only | owner  |
| GET    | `/payments/summary`                   | Dashboard stats         | ✅     |

**Payment schema:**

```json
{
  "id": "pay_001",
  "title": "March 2026 Rent",
  "amount": 8500,
  "date": "2026-03-01",
  "status": "pending",
  "type": "rent",
  "tenantName": "Riya Mehta",
  "propertyId": "prop_001",
  "description": "Room 302 — March 2026 monthly rent"
}
```

> `amount`: integer rupees  
> `date`: ISO date `"YYYY-MM-DD"`  
> `status`: `"paid"` | `"pending"` | `"overdue"`  
> `type`: `"rent"` | `"deposit"` | `"electricity"` | `"maintenance"`

**Summary schema** (all integer rupees):

```json
{
  "totalCollectedThisMonth": 45000,
  "pendingAmount": 17000,
  "totalTenants": 5,
  "overdueTenants": 2
}
```

---

### 5.6 Payouts

| Method | Path                    | Description       |
| ------ | ----------------------- | ----------------- |
| GET    | `/payouts`              | All bank payouts  |
| GET    | `/payouts/summary`      | Settlement totals |
| POST   | `/payouts/bank-account` | Link bank account |

**Payout schema:**

```json
{
  "id": "pout_001",
  "amount": 45000,
  "date": "2026-02-05",
  "status": "completed",
  "bankLast4": "4821",
  "propertyTitle": "Sunnyvale PG",
  "description": "February 2026 rent collection payout"
}
```

> `amount`: integer rupees  
> `date`: ISO date `"YYYY-MM-DD"`  
> `status`: `"completed"` | `"processing"` | `"failed"`

---

### 5.7 Notifications

| Method | Path                           | Description                |
| ------ | ------------------------------ | -------------------------- |
| GET    | `/notifications`               | All notifications for user |
| PATCH  | `/notifications/{id}/read`     | Mark single as read        |
| PATCH  | `/notifications/mark-all-read` | Mark all as read           |

**Notification schema:**

```json
{
  "id": "notif_001",
  "title": "Rent Due Reminder",
  "description": "Your March 2026 rent of ₹8,500 is due on 5 Mar.",
  "type": "rentDue",
  "timestamp": "2026-03-04T22:00:00Z",
  "isRead": false
}
```

> `type`: `"rentDue"` | `"message"` | `"maintenance"` | `"leaseRenewal"` | `"general"`  
> `timestamp`: ISO datetime `"YYYY-MM-DDTHH:MM:SSZ"` — **never** `"2h ago"`  
> `description` body text may contain `₹` symbols — that is acceptable

---

### 5.8 Subscription Plans

| Method | Path               | Description       |
| ------ | ------------------ | ----------------- |
| GET    | `/plans`           | Available plans   |
| POST   | `/plans/subscribe` | Subscribe/upgrade |

**Plan schema:**

```json
{
  "id": "plan_pro",
  "name": "Pro",
  "price": 999,
  "maxProperties": 5,
  "maxTenants": 100,
  "features": ["Rent Collection", "Payout Automation", "Priority Support"],
  "isPopular": true,
  "isCurrent": false
}
```

> `price`: integer rupees (monthly)

---

## 6. Pagination Envelope (Recommended)

Wrap all list endpoints:

```json
{
  "data": [...],
  "meta": { "page": 1, "totalPages": 5, "total": 47 }
}
```

---

## 7. Business Logic Rules

- **Role guards:** All owner-only endpoints must return `403` if accessed with a tenant JWT.
- **Payment status flow:** `pending` → `paid` (on success) or `overdue` (after due date passes). Never skip states.
- **Payout trigger:** Payouts are generated server-side after a payment is confirmed `paid`. Never manually create payouts from the client.
- **Occupancy:** `occupiedRooms` is a derived count on the server — never accept it as a write field from the client.
- **Lease dates:** `leaseEnd` determines `isRentDue` logic. If `DateTime.now() >= DateTime.parse(dueDate)` and `!isPaid`, status becomes `overdue`.

---

## 8. Antigravity AI Setup for This Project

The Antigravity AI coding assistant is configured with project-specific skills, rules, and workflows stored in `.agent/`.

### 8.1 Enforced UI Rules (`.agent/rules/shiftproof-ui.md`)

Applied automatically to every Flutter edit:

- **No hardcoded colors** — always `Theme.of(context).colorScheme`
- **8-point grid** — all padding/margins in multiples of 8
- **No `.withOpacity()`** — use `.withValues(alpha: x)`
- **`const` constructors** everywhere possible
- **Shimmer loaders** for async lists, explicit empty states, Snackbar error handling

### 8.2 Skills

| Skill                       | Path                                             | When Used                     |
| --------------------------- | ------------------------------------------------ | ----------------------------- |
| `flutter-skill`             | `.agent/skills/universal_flow/SKILL.md`          | Any UI screen build           |
| `material-design`           | `.agent/skills/material_design/SKILL.md`         | Component/widget design       |
| `performance`               | `.agent/skills/performance_diagnostics/SKILL.md` | List rendering, image caching |
| `signals-and-flutter-hooks` | `.agent/skills/reactive_state/SKILL.md`          | State management patterns     |

### 8.3 Workflows (slash commands)

| Command                          | What it does                                   |
| -------------------------------- | ---------------------------------------------- |
| `/shiftproof_flutter_guidelines` | Applies ShiftProof Flutter UI coding standards |
| `/shiftproof_flutter_models`     | Sets up screen states and data model patterns  |
| `/shiftproof_flutter_modules`    | Manages module architecture and routing        |
| `/prompt_optimization`           | Refines prompts using bubobot-optimizer        |

### 8.4 Data Contract Regression Commands

Run before every commit that touches a model or mock data file:

```bash
dart analyze lib/
dart format lib/
grep -rn "'₹\|\"₹" lib/data/          # Must return 0 — no ₹ in data layer
grep -rn "ago'" lib/data/              # Must return 0 — no pre-formatted timestamps
grep -rn " as int" lib/data/models/   # Must return 0 — use (num).toInt()
```

---

## 9. Key Files Reference

| File                                      | Purpose                                                 |
| ----------------------------------------- | ------------------------------------------------------- |
| `lib/data/mock_api.dart`                  | All mock data — delete when real API is live            |
| `lib/data/services/mock_api_service.dart` | Service layer — replace method bodies with HTTP calls   |
| `lib/data/models/*.dart`                  | Dart models with `fromJson` — already match API schemas |
| `lib/core/utils/currency_formatter.dart`  | UI-only ₹ formatting utility                            |
| `lib/core/theme/app_theme.dart`           | Centralized theme/color tokens                          |
| `docs/api_responses.md`                   | Detailed API response field reference                   |
| `.agent/rules/shiftproof-ui.md`           | Flutter UI coding rules (auto-enforced by Antigravity)  |
