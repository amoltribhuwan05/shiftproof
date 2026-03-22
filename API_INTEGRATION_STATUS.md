# API Integration Status — ShiftProof

> Last updated: 2026-03-22

---

## Infrastructure

| Item | Detail |
|------|--------|
| Base URL | `https://shiftproof-gw-3x6v50c1.uc.gateway.dev` |
| HTTP Client | Dio 5.9.2 |
| Auth | Firebase JWT via `AuthInterceptor` |
| State Management | Riverpod |

---

## App Flow & Screen Index

### User Journey

```
App Launch
  └─ GET /auth/me
      ├─ null → [S01] Login Screen
      │    ├─ Email → [S02] Email Auth → [S03] Email Registration
      │    ├─ Phone → [S04] Phone Login → [S05] OTP Verification
      │    └─ Forgot → [S06] Forgot Password
      │
      └─ authenticated
          ├─ profileCompleted = false → [S07] Onboarding
          └─ profileCompleted = true
               ├─ role = OWNER → [S08–S19] Owner Flow
               └─ role = TENANT → [S20–S28] Tenant Flow
```

---

## Screen → Service Mapping

### Auth Flow (Common)

| # | Screen | File | Service | Endpoints | Status |
|---|--------|------|---------|-----------|--------|
| S01 | Login | `screens/auth/login_screen.dart` | `AuthService` | Firebase email/Google/Apple sign-in | ✅ Done |
| S02 | Email Auth | `screens/auth/email_auth_screen.dart` | `AuthService` | Firebase `signInWithEmailAndPassword` | ✅ Done |
| S03 | Email Registration | `screens/auth/email_registration_screen.dart` | `AuthService` | Firebase `createUserWithEmailAndPassword` | ✅ Done |
| S04 | Phone Login | `screens/auth/phone_login_screen.dart` | `AuthService` | Firebase `verifyPhoneNumber` | ✅ Done |
| S05 | OTP Verification | `screens/auth/otp_verification_screen.dart` | `AuthService` | Firebase `PhoneAuthCredential` | ✅ Done |
| S06 | Forgot Password | `screens/auth/forgot_password_screen.dart` | `AuthService` | Firebase `sendPasswordResetEmail` | ✅ Done |
| S07 | Onboarding | `screens/auth/onboarding_screen.dart` | `ProfileService` | `POST /users/onboarding`, `PATCH /users/profile` | ❌ Missing endpoint |

---

### Owner Flow

| # | Screen | File | Service | Endpoints | Status |
|---|--------|------|---------|-----------|--------|
| S08 | Owner Home | `screens/properties/owner_main_screen.dart` | `PropertyService`, `PaymentService` | `GET /properties`, `GET /payments/summary` | ❌ Mock data |
| S09 | My Properties | `screens/properties/my_properties_screen.dart` | `PropertyService` | `GET /properties` | ❌ Mock data |
| S10 | Add Property | `screens/properties/add_property_screen.dart` | `PropertyService` | `POST /properties` | ❌ Mock data |
| S11 | Property Details | `screens/properties/property_details_screen.dart` | `PropertyService`, `PaymentService` | `GET /properties/{id}`, `GET /payments?propertyId` | ❌ Mock data |
| S12 | Room & Bed Setup | `screens/properties/room_bed_setup_screen.dart` | *(missing)* `RoomService` | `POST /properties/{id}/rooms`, `PATCH /rooms/{id}`, `DELETE /rooms/{id}` | ❌ No service |
| S13 | Manage Tenants | `screens/properties/manage_tenants_screen.dart` | *(missing)* `TenantService` | `GET /properties/{id}/tenants`, `POST /tenants`, `PATCH /tenants/{id}`, `DELETE /tenants/{id}` | ❌ No service |
| S14 | Rent Collections | `screens/payments/collections_screen.dart` | `PaymentService` | `GET /payments/collections`, `GET /payments/summary` | ❌ Mock data |
| S15 | Payouts | `screens/payments/payouts_screen.dart` | `PayoutService` | `GET /payouts` | ❌ Mock data |
| S16 | Export Report | `screens/properties/export_report_screen.dart` | *(missing)* `ReportService` | `GET /reports/properties/{id}`, `GET /reports/download` | ❌ No service |
| S17 | Owner Plans | `screens/payments/owner_plans_screen.dart` | `PlanService`, *(missing)* `SubscriptionService` | `GET /plans`, `POST /subscriptions`, `GET /subscriptions/current` | ❌ Partial (plans list only) |
| S18 | Notifications | `screens/notifications/notifications_screen.dart` | `NotificationService` | `GET /notifications`, `PATCH /notifications/{id}/read`, `PATCH /notifications/mark-all-read` | ❌ Mock data |
| S19 | Profile / Settings | `screens/profile/profile_screen.dart` | `ProfileService` | `PATCH /users/profile` | ✅ Done |

---

### Tenant Flow

| # | Screen | File | Service | Endpoints | Status |
|---|--------|------|---------|-----------|--------|
| S20 | Tenant Home | `screens/tenant/tenant_main_screen.dart` | `AuthService` | `GET /auth/me/current-stay` | ❌ Mock data |
| S21 | Tenant Dashboard | `screens/dashboard/tenant_dashboard_screen.dart` | `AuthService`, `PaymentService` | `GET /auth/me/current-stay`, `GET /payments?type=RENT` | ❌ Mock data |
| S22 | Find PG | `screens/tenant/find_pg_screen.dart` | `PropertyService` | `GET /properties` | ❌ Mock data |
| S23 | Join PG | `screens/tenant/join_pg_screen.dart` | *(missing)* `TenantService` | `POST /tenants/join` | ❌ No service |
| S24 | Pay Bill | `screens/payments/pay_bill_screen.dart` | `PaymentService`, *(missing)* payment gateway | `POST /payments/{id}/pay` | ❌ No service |
| S25 | Payment History | `screens/payments/payment_history_screen.dart` | `PaymentService` | `GET /payments` | ❌ Mock data |
| S26 | Notifications | `screens/notifications/notifications_screen.dart` | `NotificationService` | `GET /notifications`, `PATCH /notifications/{id}/read` | ❌ Mock data |
| S27 | Profile | `screens/profile/profile_screen.dart` | `ProfileService` | `PATCH /users/profile` | ✅ Done |
| S28 | Settings | `screens/profile/settings_screen.dart` | `AuthService` | `POST /auth/logout` | ✅ Done |

---

## Service Inventory

| Service | File | Used By Screens | Status |
|---------|------|-----------------|--------|
| `AuthService` | `services/auth_service.dart` | S01–S06, S20, S28 | ✅ Fully integrated |
| `ProfileService` | `services/profile_service.dart` | S07, S19, S27 | ✅ Fully integrated |
| `HealthService` | `services/health_service.dart` | App startup | ✅ Fully integrated |
| `PropertyService` | `services/property_service.dart` | S08–S11, S22 | ⚠️ Service ready, UI uses mock |
| `PaymentService` | `services/payment_service.dart` | S08, S11, S14, S21, S24, S25 | ⚠️ Service ready, UI uses mock |
| `PayoutService` | `services/payout_service.dart` | S15 | ⚠️ Service ready, UI uses mock |
| `NotificationService` | `services/notification_service.dart` | S18, S26 | ⚠️ Service ready, UI uses mock |
| `PlanService` | `services/plan_service.dart` | S17 | ⚠️ Service ready, UI uses mock |
| `RoomService` | *(missing)* | S12 | ❌ Not implemented |
| `TenantService` | *(missing)* | S13, S23 | ❌ Not implemented |
| `ReportService` | *(missing)* | S16 | ❌ Not implemented |
| `SubscriptionService` | *(missing)* | S17 | ❌ Not implemented |

---

## Action Items (by priority)

### P1 — Wire existing services to UI (no new code needed)
1. **S08 Owner Home** — replace mock with `PropertyService.listProperties()` + `PaymentService.getSummary()`
2. **S09 My Properties** — replace mock with `PropertyService.listProperties()`
3. **S10 Add Property** — replace mock with `PropertyService.createProperty()`
4. **S11 Property Details** — replace mock with `PropertyService.getProperty(id)` + `PaymentService.listPayments(propertyId)`
5. **S14 Rent Collections** — replace mock with `PaymentService.getCollections()` + `PaymentService.getSummary()`
6. **S15 Payouts** — replace mock with `PayoutService.listPayouts()`
7. **S17 Owner Plans** — replace mock with `PlanService.listPlans()`
8. **S18 / S26 Notifications** — replace mock with `NotificationService.listNotifications()`
9. **S20 / S21 Tenant Home + Dashboard** — replace mock with `AuthService.getCurrentStay()`
10. **S22 Find PG** — replace mock with `PropertyService.listProperties()`
11. **S25 Payment History** — replace mock with `PaymentService.listPayments()`

### P2 — Create missing services
12. **`TenantService`** — CRUD for tenants + `POST /tenants/join` + `POST /tenants/leave` (S13, S23)
13. **`RoomService`** — room/bed CRUD under a property (S12)
14. **`SubscriptionService`** — `POST /subscriptions`, `PATCH /subscriptions/{id}`, `GET /subscriptions/current` (S17)

### P3 — Implement missing endpoints
15. **S07 Onboarding** — call `POST /users/onboarding` after profile form submit
16. **S16 Export Report** — `ReportService` with download + share flow
17. **S24 Pay Bill** — payment gateway integration (Razorpay / Stripe) + `POST /payments/{id}/pay`

### P4 — Routing fix
18. **`main.dart`** — add role check: after `profileCompleted = true`, route `OWNER` → `OwnerMainScreen`, `TENANT` → `TenantMainScreen`
