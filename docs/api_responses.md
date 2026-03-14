# ShiftProof — Complete API Response Structures

> **Note:** The app currently uses `MockApiService` backed by `mock_api.dart`. This document is the definitive type contract for the real REST API.

---

## Base URL & Common Conventions

```
Base URL:       https://api.shiftproof.in/v1
Auth:           Bearer <JWT token> in Authorization header
Content-Type:   application/json
```

### Field Type Rules (ENFORCED)

| Data Category     | API / DB Type      | Notes                                                                           |
| ----------------- | ------------------ | ------------------------------------------------------------------------------- |
| Monetary amounts  | `integer` (rupees) | Never send `"₹8,500"` — client uses `CurrencyFormatter.format()`                |
| Ratings           | `number` (float)   | e.g. `4.8` — never a quoted string                                              |
| Dates             | ISO 8601 string    | `"YYYY-MM-DD"` or `"YYYY-MM-DDTHH:MM:SSZ"` — never `"5 Mar 2026"` or `"2h ago"` |
| Room/count fields | `integer`          | Use integer, not float                                                          |
| Status/type enums | `string`           | Lowercase, documented per model                                                 |
| Boolean flags     | `boolean`          | `true` / `false`, never `"1"` / `"0"`                                           |

### Standard Error Envelope

```json
{
  "error": "Resource not found",
  "code": 404
}
```

---

## 1. Authentication

### `POST /auth/login`

**Request:**

```json
{ "phone": "+91 98765 43210", "otp": "123456" }
```

**Response:**

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "usr_001",
    "name": "Amol Sharma",
    "email": "amol.sharma@example.com",
    "phone": "+91 98765 43210",
    "avatarUrl": "https://i.pravatar.cc/150?img=11",
    "role": "owner",
    "joinDate": "2023-01-15",
    "location": "Bangalore, Karnataka"
  }
}
```

**AppUser field types:**
| Field | Type | Enum / Notes |
|---|---|---|
| `id` | string | |
| `role` | string | `"owner"` \| `"tenant"` |
| `joinDate` | string (ISO date) | `"YYYY-MM-DD"` |
| `avatarUrl` | string (URL) | |

---

### `POST /auth/logout`

```json
{ "success": true }
```

---

### `GET /auth/me/current-stay` _(tenant only)_

```json
{
  "propertyName": "Sunnyvale PG",
  "roomNumber": "Room 302",
  "address": "14th Cross, Koramangala, Bangalore - 560034",
  "rentAmount": 8500,
  "dueDate": "2026-03-05",
  "ownerName": "Amol Sharma",
  "ownerPhone": "+91 98765 43210",
  "ownerAvatarUrl": "https://i.pravatar.cc/150?img=11",
  "leaseStart": "2025-06-01",
  "leaseEnd": "2026-05-31",
  "imageUrl": "https://images.unsplash.com/...",
  "isRentDue": true
}
```

**CurrentStay field types:**
| Field | Type | Notes |
|---|---|---|
| `rentAmount` | integer | Rupees — no ₹ symbol |
| `dueDate` | string (ISO date) | `"YYYY-MM-DD"` |
| `leaseStart` / `leaseEnd` | string (ISO date) | Parse for duration calculations |
| `isRentDue` | boolean | |

---

## 2. Properties

### `GET /properties`

```json
[
  {
    "id": "prop_001",
    "title": "Sunnyvale PG",
    "location": "Koramangala, Bangalore",
    "type": "PG",
    "price": 8500,
    "deposit": 17000,
    "rating": 4.8,
    "imageUrl": "https://images.unsplash.com/...",
    "totalRooms": 16,
    "occupiedRooms": 12,
    "description": "A premium PG in the heart of Koramangala...",
    "amenities": ["WiFi", "AC", "Meals", "Laundry", "Security", "Parking"],
    "ownerName": "Amol Sharma",
    "ownerAvatarUrl": "https://i.pravatar.cc/150?img=11"
  }
]
```

**Property field types:**
| Field | Type | Enum / Notes |
|---|---|---|
| `type` | string | `"PG"` \| `"Flat"` \| `"House"` |
| `price` | integer | Monthly rent in rupees — no ₹ |
| `deposit` | integer | Deposit in rupees — no ₹ |
| `rating` | float | e.g. `4.8` — NOT `"4.8"` |
| `totalRooms` / `occupiedRooms` | integer | Integer only |
| `amenities` | string[] | Feature tag list |

### `GET /properties/{id}` — Single property (same schema)

### `POST /properties` — Create (same schema, server assigns `id`)

### `PUT /properties/{id}` — Partial update, returns updated property

### `DELETE /properties/{id}` — `{ "success": true }`

---

## 3. Rooms & Beds

### `GET /properties/{id}/rooms`

```json
[
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
]
```

| Field                        | Type    | Enum / Notes                              |
| ---------------------------- | ------- | ----------------------------------------- |
| `type`                       | string  | `"single"` \| `"shared"` \| `"dormitory"` |
| `pricePerBed`                | integer | Rupees — no ₹                             |
| `totalBeds` / `occupiedBeds` | integer |                                           |

---

## 4. Tenants

### `GET /properties/{id}/tenants`

```json
[
  {
    "id": "ten_001",
    "name": "Riya Mehta",
    "room": "Room 302",
    "rentAmount": 8500,
    "dueDate": "2026-03-05",
    "isPaid": false,
    "avatarUrl": "https://i.pravatar.cc/150?img=12",
    "phone": "+91 87654 32109",
    "email": "riya.mehta@example.com",
    "joinDate": "2025-06-01",
    "propertyId": "prop_001",
    "status": "overdue"
  }
]
```

| Field                  | Type              | Enum / Notes                             |
| ---------------------- | ----------------- | ---------------------------------------- |
| `rentAmount`           | integer           | Rupees — no ₹                            |
| `dueDate` / `joinDate` | string (ISO date) | `"YYYY-MM-DD"`                           |
| `isPaid`               | boolean           |                                          |
| `status`               | string            | `"active"` \| `"pending"` \| `"overdue"` |

### `GET /tenants/{id}` — Single tenant (same schema)

### `POST /properties/{id}/tenants/invite` — Returns tenant with `status: "pending"`

### `DELETE /properties/{id}/tenants/{tenantId}` — `{ "success": true }`

---

## 5. Payments

### `GET /payments` _(query: `?propertyId=`, `?status=`, `?type=`)_

```json
[
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
]
```

| Field    | Type              | Enum / Notes                                                  |
| -------- | ----------------- | ------------------------------------------------------------- |
| `amount` | integer           | Rupees — no ₹                                                 |
| `date`   | string (ISO date) | `"YYYY-MM-DD"`                                                |
| `status` | string            | `"paid"` \| `"pending"` \| `"overdue"`                        |
| `type`   | string            | `"rent"` \| `"deposit"` \| `"electricity"` \| `"maintenance"` |

### `GET /payments/collections` — Rent-type payments (same schema)

### `GET /payments/summary`

```json
{
  "totalCollectedThisMonth": 45000,
  "pendingAmount": 17000,
  "totalTenants": 5,
  "overdueTenants": 2
}
```

> All summary amounts are **integers** (rupees). Format with `CurrencyFormatter` in UI.

---

## 6. Payouts

### `GET /payouts`

```json
[
  {
    "id": "pout_001",
    "amount": 45000,
    "date": "2026-02-05",
    "status": "completed",
    "bankLast4": "4821",
    "propertyTitle": "Sunnyvale PG",
    "description": "February 2026 rent collection payout"
  }
]
```

| Field       | Type              | Enum / Notes                                  |
| ----------- | ----------------- | --------------------------------------------- |
| `amount`    | integer           | Rupees — no ₹                                 |
| `date`      | string (ISO date) | `"YYYY-MM-DD"`                                |
| `status`    | string            | `"completed"` \| `"processing"` \| `"failed"` |
| `bankLast4` | string            | Last 4 digits only                            |

### `GET /payouts/summary`

```json
{ "totalSettled": 114000, "processing": 2800 }
```

---

## 7. Notifications

### `GET /notifications`

```json
[
  {
    "id": "notif_001",
    "title": "Rent Due Reminder",
    "description": "Your March 2026 rent of ₹8,500 is due on 5 Mar. Tap to pay now.",
    "type": "rentDue",
    "timestamp": "2026-03-04T22:00:00Z",
    "isRead": false
  }
]
```

| Field       | Type                  | Enum / Notes                                                                     |
| ----------- | --------------------- | -------------------------------------------------------------------------------- |
| `type`      | string                | `"rentDue"` \| `"message"` \| `"maintenance"` \| `"leaseRenewal"` \| `"general"` |
| `timestamp` | string (ISO datetime) | `"YYYY-MM-DDTHH:MM:SSZ"` — **never** `"2h ago"` — format in UI                   |
| `isRead`    | boolean               |                                                                                  |

> **Note:** `description` may contain ₹-formatted text for human readability — this is acceptable in notification body strings only.

### `PATCH /notifications/{id}/read` — `{ "success": true, "isRead": true }`

### `PATCH /notifications/mark-all-read` — `{ "success": true, "updatedCount": 3 }`

---

## 8. Subscription Plans

### `GET /plans`

```json
[
  {
    "id": "plan_basic",
    "name": "Starter",
    "price": 499,
    "maxProperties": 1,
    "maxTenants": 10,
    "features": ["Rent Collection", "Basic Analytics", "Email Support"],
    "isPopular": false,
    "isCurrent": true
  }
]
```

| Field                          | Type    | Notes                       |
| ------------------------------ | ------- | --------------------------- |
| `price`                        | integer | Monthly plan cost in rupees |
| `maxProperties` / `maxTenants` | integer |                             |
| `isPopular` / `isCurrent`      | boolean |                             |

---

## Appendix: Type Anti-Patterns (NEVER DO)

| ❌ Wrong                | ✅ Correct                            |
| ----------------------- | ------------------------------------- |
| `"amount": "₹8,500"`    | `"amount": 8500`                      |
| `"rating": "4.8"`       | `"rating": 4.8`                       |
| `"date": "5 Mar 2026"`  | `"date": "2026-03-05"`                |
| `"timestamp": "2h ago"` | `"timestamp": "2026-03-04T22:00:00Z"` |
| `"totalRooms": 16.0`    | `"totalRooms": 16`                    |
| `"isPaid": "true"`      | `"isPaid": true`                      |
