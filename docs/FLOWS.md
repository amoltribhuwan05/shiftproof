# ShiftProof — User Flow Diagrams

All key product flows from the Flutter app's perspective.

---

## 1. Authentication Flow

### First-Time Login (New User)

```mermaid
sequenceDiagram
    actor User
    participant App as Flutter App
    participant FB as Firebase Auth
    participant API as ShiftProof API
    participant DB as PostgreSQL

    User->>App: Tap "Sign in with Google"
    App->>FB: Trigger Google OAuth
    FB-->>App: Firebase ID Token (JWT, valid 1hr)
    App->>API: GET /auth/me\nAuthorization: Bearer <id_token>
    API->>FB: VerifyIDToken(id_token)
    FB-->>API: { uid, email, name, picture }
    API->>DB: Upsert user (firebase_uid)
    DB-->>API: User row
    API-->>App: AppUser { profileCompleted: false }
    App->>App: Navigate to Onboarding screen

    User->>App: Fill name, gender, city
    App->>API: POST /users/onboarding\n{ name, gender, city, area }
    API->>DB: UPDATE users SET profile_completed = true
    DB-->>API: Updated user row
    API-->>App: AppUser { profileCompleted: true }
    App->>App: Navigate to Home screen
```

### Returning User Login

```mermaid
sequenceDiagram
    actor User
    participant App as Flutter App
    participant FB as Firebase Auth
    participant Redis as Redis Cache
    participant API as ShiftProof API

    User->>App: Open app
    App->>FB: getIdToken() (auto-refreshes if expired)
    FB-->>App: Valid Firebase ID Token

    App->>API: GET /auth/me\nAuthorization: Bearer <token>
    API->>Redis: GET hash(token)
    Redis-->>API: Cache HIT — { uid, role } (0.5ms)
    API->>API: Load user from DB
    API-->>App: AppUser { profileCompleted: true }
    App->>App: Navigate to Home screen

    Note over API,Redis: Token cached for 5 minutes.\nFirebase is not called on every request.
```

### Logout

```mermaid
sequenceDiagram
    actor User
    participant App as Flutter App
    participant API as ShiftProof API
    participant Redis as Redis Cache
    participant FB as Firebase Auth

    User->>App: Tap Logout
    App->>API: POST /auth/logout\nAuthorization: Bearer <token>
    API->>Redis: SET denylist:hash(token) = "1" (TTL = token expiry)
    API-->>App: { message: "Logged out successfully" }
    App->>FB: signOut()
    App->>App: Navigate to Login screen

    Note over API,Redis: Any subsequent request with this\ntoken hits the denylist and gets 401.
```

---

## 2. Owner: Add Property & Room

```mermaid
sequenceDiagram
    actor Owner
    participant App as Flutter App
    participant API as ShiftProof API
    participant DB as PostgreSQL

    Owner->>App: Tap "Add Property"
    App->>API: POST /properties\n{ title, location, type, price, deposit, amenities }
    API->>API: Check role = OWNER
    API->>DB: INSERT INTO properties
    DB-->>API: property row
    API-->>App: Property { id: "prop_abc" }

    Owner->>App: Tap "Add Room" (inside property)
    App->>API: POST /properties/prop_abc/rooms\n{ roomNumber, type, capacity, rentAmount, deposit }
    API->>API: Check property:update permission
    API->>DB: INSERT INTO rooms
    DB-->>API: room row
    API-->>App: Room { id: "room_xyz", isAvailable: true }
```

---

## 3. Tenant Invite & Join Flow

This is the most important onboarding flow in the product.

```mermaid
sequenceDiagram
    actor Owner
    actor Tenant
    participant App as Flutter App
    participant API as ShiftProof API
    participant DB as PostgreSQL

    Owner->>App: Select tenant for Room 101
    App->>API: POST /properties/prop_abc/tenants/invite\n{ roomId, leaseStart, leaseEnd, rentAmount, email }
    API->>DB: INSERT INTO tenant_invites\n(invite_code = "INV-XYZABC", expires_at = now + 72h)
    DB-->>API: invite row
    API-->>App: { inviteCode: "INV-XYZABC", expiresAt: "..." }

    Owner->>Tenant: Share code "INV-XYZABC"\n(WhatsApp / SMS / in-person)

    Tenant->>App: Open ShiftProof, sign in
    Tenant->>App: Tap "Join Property", enter code
    App->>API: POST /tenants/join\n{ inviteCode: "INV-XYZABC" }
    API->>DB: SELECT invite WHERE code = ? AND used_at IS NULL AND expires_at > NOW()
    DB-->>API: valid invite row
    API->>DB: INSERT INTO stays\n(links tenant to room + property)
    API->>DB: UPDATE users SET roles = array_append(roles, 'TENANT')
    API->>DB: UPDATE tenant_invites SET used_at = NOW()
    DB-->>API: stay row
    API-->>App: CurrentStay { propertyName, roomNumber, rentAmount, leaseStart, leaseEnd }
    App->>App: Navigate to Tenant Home screen
```

---

## 4. Payment Flows

### 4a. Manual Collection (Cash / UPI / Bank Transfer)

Owner creates payment, tenant pays outside the app, owner confirms receipt.

```mermaid
sequenceDiagram
    actor Owner
    actor Tenant
    participant App as Flutter App
    participant API as ShiftProof API
    participant DB as PostgreSQL
    participant Cron as Overdue Cron (Daily)

    Note over Cron,DB: Every day at midnight
    Cron->>DB: UPDATE payments SET status = 'overdue'\nWHERE date < TODAY AND status = 'pending'

    Owner->>App: Tap "Collect Rent" for Tenant
    App->>API: POST /payments\nX-Idempotency-Key: <uuid>\n{ propertyId, title, amount, type: "rent" }
    API->>DB: INSERT INTO payments\n(status='pending', collection_mode='manual')
    DB-->>API: payment row
    API-->>App: Payment { id: "pay_abc", status: "pending", collectionMode: "manual" }

    Tenant->>Owner: Pays ₹8,000 via UPI/Cash

    Owner->>App: Tap "Confirm Receipt"
    App->>API: POST /payments/pay_abc/confirm
    API->>DB: BEGIN TRANSACTION
    API->>DB: UPDATE payments SET status = 'paid'
    API->>DB: INSERT INTO payouts (status='processing')
    API->>DB: COMMIT
    DB-->>API: Updated payment
    API-->>App: Payment { status: "paid" }
```

---

### 4b. Online Payment via Razorpay

Tenant pays directly in-app. Webhook is the authoritative source of truth — never show success until webhook confirms.

```mermaid
sequenceDiagram
    actor Tenant
    participant App as Flutter App
    participant API as ShiftProof API
    participant RZP as Razorpay
    participant DB as PostgreSQL

    Note over Tenant,App: Payment already exists (status=pending)

    Tenant->>App: Tap "Pay Online"
    App->>API: POST /payments/pay_abc/checkout
    API->>RZP: Create Order (amount, currency, receipt)
    RZP-->>API: { orderId: "order_xyz", amount: 800000 }
    API->>DB: UPDATE payments SET status='checkout_created',\ncollection_mode='online', razorpay_order_id='order_xyz'
    API->>DB: INSERT INTO payment_attempts (raw_request=checkout JSON)
    API-->>App: PaymentCheckout { keyId, orderId, amountSubunits: 800000 }

    App->>App: Open Razorpay SDK with keyId + orderId
    Tenant->>RZP: Completes UPI / Card / NetBanking
    RZP-->>App: PaymentSuccessResponse { paymentId, signature }

    App->>API: POST /payments/pay_abc/pay\n{ provider, gatewayOrderId, gatewayPaymentId, gatewaySignature }
    API->>API: HMAC-SHA256 verify signature
    API->>DB: UPDATE payments SET status='processing'
    API-->>App: Payment { status: "processing" }

    Note over App: Show ⏳ spinner, start polling every 3s

    RZP->>API: POST /webhooks/razorpay\npayment.captured event
    API->>API: Verify webhook HMAC
    API->>DB: capture_payment_from_webhook(orderId, paymentId)\n→ status='paid', INSERT payouts
    DB-->>API: { payment_id, property_id, amount }

    App->>API: GET /payments/pay_abc  (polling)
    API-->>App: Payment { status: "paid" }
    App->>App: ✅ Show "Payment Successful" screen
```

---

## 5. Subscription Flow

```mermaid
sequenceDiagram
    actor Owner
    participant App as Flutter App
    participant API as ShiftProof API
    participant DB as PostgreSQL

    Owner->>App: Tap "Upgrade Plan"
    App->>API: GET /plans
    API->>DB: SELECT * FROM plans
    DB-->>API: [Free, Pro, Elite]
    API-->>App: Plans list with isCurrent flag

    Owner->>App: Select "Pro Plan"
    App->>API: POST /subscriptions\n{ planId: "plan_pro" }
    API->>DB: BEGIN TRANSACTION
    API->>DB: UPDATE subscriptions SET is_active = false\nWHERE owner_id = ? AND is_active = true
    API->>DB: INSERT INTO subscriptions\n(owner_id, plan_id: "plan_pro", is_active: true)
    API->>DB: COMMIT
    DB-->>API: New subscription row
    API->>DB: GET current subscription (with plan name/price)
    API-->>App: Subscription { planName: "Pro", status: "active", price: 999 }
```

---

## 6. Notification Flow

```mermaid
sequenceDiagram
    participant Cron as Background Cron
    participant API as ShiftProof API
    participant DB as PostgreSQL
    participant FCM as Firebase Cloud Messaging
    participant App as Flutter App (Tenant)

    Note over Cron: Daily midnight job
    Cron->>DB: Find tenants with rent due tomorrow
    DB-->>Cron: [tenant_1, tenant_2, ...]

    loop For each tenant
        Cron->>DB: INSERT INTO notifications\n{ user_id, title: "Rent Due Tomorrow",\n  type: "rentDue" }
        Cron->>FCM: Send push to tenant.fcm_token\n{ title, body, data }
        FCM-->>App: Push notification appears\non tenant's phone
    end

    Note over App: Tenant opens app
    App->>API: GET /notifications?page=1&limit=20
    API->>DB: SELECT * FROM notifications\nWHERE user_id = ? ORDER BY timestamp DESC
    DB-->>API: Notification rows
    API-->>App: { data: [...], meta: { total: 5 } }

    App->>API: PATCH /notifications/notif_abc/read
    API->>DB: UPDATE notifications SET is_read = true\nWHERE id = ? AND user_id = ?
    API-->>App: Notification { isRead: true }
```

---

## 7. Monthly Report Flow

```mermaid
sequenceDiagram
    actor Owner
    participant App as Flutter App
    participant API as ShiftProof API
    participant DB as PostgreSQL

    Owner->>App: Open Reports tab, select property
    App->>API: GET /reports/properties/prop_abc?month=2024-01
    API->>API: Parse month param → date range\n2024-01-01 to 2024-01-31

    API->>DB: GetPropertyReport query:\n- SUM(paid payments) → totalCollected\n- SUM(pending payments) → totalPending\n- COUNT(overdue) → overdueCount\n- COUNT(active tenants) / total beds → occupancyRate

    API->>DB: ListPaymentsForReport:\n- All payments in Jan 2024 for this property

    DB-->>API: Aggregated stats + payment list
    API-->>App: PropertyReport {\n  totalCollected: 48000,\n  totalPending: 16000,\n  overdueCount: 2,\n  occupancyRate: 0.70,\n  payments: [...]\n}

    App->>App: Render bar charts, payment table
```

---

## 8. Policy Engine Flow

How property-level and global-role permissions are enforced on every protected request.

```mermaid
flowchart TD
    Request["Incoming Request\nGET /properties/prop_abc/tenants"]
    AuthMW["auth middleware\nVerify Firebase token\nLoad user from DB"]
    HasUser{"User found?"}
    PolicyEngine["policy.Enforce(ActionTenantList)\nresolve property context"]
    GlobalRole{"global role\nrequired?"}
    HasRole{"user has property role\nwith required permission?"}
    Allow["✅ Allow\nPass to handler"]
    Deny401["❌ 401 Unauthorized"]
    Deny403["❌ 403 Forbidden"]

    Request --> AuthMW
    AuthMW --> HasUser
    HasUser -->|No| Deny401
    HasUser -->|Yes| PolicyEngine
    PolicyEngine --> GlobalRole
    GlobalRole -->|No global gate| HasRole
    GlobalRole -->|Required role missing| Deny403
    GlobalRole -->|Role satisfied| HasRole
    HasRole -->|Yes| Allow
    HasRole -->|No| Deny403
```

---

## 9. Avatar Upload Flow

```mermaid
sequenceDiagram
    actor User
    participant App as Flutter App
    participant API as ShiftProof API
    participant GCS as Google Cloud Storage

    User->>App: Pick image from gallery
    App->>App: Compress image to < 5MB\nConvert to base64 string
    App->>API: POST /users/profile/avatar\n{\n  contentType: "image/jpeg",\n  data: "/9j/4AAQSk..."\n}
    API->>API: Decode base64 → bytes\nValidate content type\nCheck size ≤ 5MB
    API->>GCS: Upload to avatars/{uid}.jpg\nContent-Type: image/jpeg\nPublic read access
    GCS-->>API: Public URL
    API->>DB: UPDATE users SET avatar_url = <url>
    DB-->>API: Updated user
    API-->>App: AppUser { avatarUrl: "https://storage.googleapis.com/..." }
    App->>App: Update profile picture display
```
