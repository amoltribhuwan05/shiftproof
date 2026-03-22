# ShiftProof — Frontend Implementation Guide

> This document is the single source of truth for building the Flutter frontend.
> It contains everything needed without needing to read any other doc.
>
> **Backend repo:** `shiftproof-be`
> **API base URL:** `https://api.shiftproof.dev/api/v1`
> **Local API:** `http://10.0.2.2:8080/api/v1` (Android emulator) or `http://localhost:8080/api/v1` (iOS sim)

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [App Architecture](#2-app-architecture)
3. [Auth Flow](#3-auth-flow)
4. [Screen Map](#4-screen-map)
5. [Dart Models](#5-dart-models)
6. [API Integration Layer](#6-api-integration-layer)
7. [Screen-by-Screen API Calls](#7-screen-by-screen-api-calls)
8. [Critical Rules](#8-critical-rules)
9. [Error Handling](#9-error-handling)
10. [Navigation & Routing](#10-navigation--routing)

---

## 1. Project Overview

ShiftProof has **two completely different user experiences** in one app:

| User | Role | What they see |
|------|------|---------------|
| **Owner** | Landlord who owns properties | Properties, Rooms, Tenants, Payments, Reports, Subscription |
| **Tenant** | Person renting a room | Their current lease, rent status, notifications |

The same login flow handles both. After login, check `roles[]` on the user object to decide which home screen to show.

**App entry logic:**
```
Login
  └─ GET /auth/me
      ├─ profileCompleted = false → Onboarding Screen
      └─ profileCompleted = true
          ├─ roles contains "OWNER" → Owner Home
          └─ roles contains "TENANT" → Tenant Home
```

---

## 2. App Architecture

### Recommended Stack
```
Flutter
├── State Management   → Riverpod (or BLoC)
├── HTTP Client        → Dio (interceptors for auth token)
├── Auth               → firebase_auth + google_sign_in
├── Push Notifications → firebase_messaging
├── Image Picker       → image_picker + flutter_image_compress
├── Navigation         → go_router
└── Storage            → flutter_secure_storage (token caching)
```

### Folder Structure
```
lib/
├── main.dart
├── core/
│   ├── api/
│   │   ├── api_client.dart          # Dio instance with auth interceptor
│   │   └── api_endpoints.dart       # All endpoint constants
│   ├── models/                      # All Dart model classes
│   ├── errors/
│   │   └── app_exception.dart       # Unified error handling
│   └── utils/
│       └── formatters.dart          # Currency, date formatters
├── features/
│   ├── auth/                        # Login, Onboarding, Profile
│   ├── owner/
│   │   ├── properties/
│   │   ├── rooms/
│   │   ├── tenants/
│   │   ├── payments/
│   │   ├── reports/
│   │   └── subscription/
│   └── tenant/
│       ├── home/                    # Current stay
│       ├── payments/                # Payment history
│       └── notifications/
└── shared/
    └── widgets/                     # Reusable UI components
```

---

## 3. Auth Flow

### Setup Firebase
```dart
// main.dart
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

### Dio Client with Auth Interceptor
```dart
// core/api/api_client.dart
class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://api.shiftproof.dev/api/v1',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Firebase SDK auto-refreshes token if expired
          final token = await user.getIdToken();
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Token expired or revoked — force logout
          FirebaseAuth.instance.signOut();
          // Navigate to login
        }
        return handler.next(error);
      },
    ));
  }
}
```

### Google Sign-In Flow
```dart
Future<AppUser?> signInWithGoogle() async {
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  if (googleUser == null) return null; // user cancelled

  final googleAuth = await googleUser.authentication;
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  await FirebaseAuth.instance.signInWithCredential(credential);

  // Call backend to upsert user
  final response = await apiClient.get('/auth/me');
  final user = AppUser.fromJson(response.data);

  if (!user.profileCompleted) {
    // Navigate to onboarding
  }
  return user;
}
```

### Logout
```dart
Future<void> logout() async {
  try {
    await apiClient.post('/auth/logout');
  } catch (_) {} // best effort
  await FirebaseAuth.instance.signOut();
  await GoogleSignIn().signOut();
  // Navigate to login screen
}
```

---

## 4. Screen Map

### Owner Screens

```
Owner Home (bottom nav)
├── Properties Tab
│   ├── Property List Screen
│   │   └── Property Card → Property Detail Screen
│   │       ├── Rooms Tab
│   │       │   ├── Room List
│   │       │   ├── Add Room Screen
│   │       │   └── Edit Room Screen
│   │       ├── Tenants Tab
│   │       │   ├── Tenant List
│   │       │   ├── Invite Tenant Screen  ← generates invite code
│   │       │   └── Tenant Detail Screen
│   │       ├── Members Tab
│   │       │   └── Add Member Screen
│   │       └── Report Tab
│   │           └── Monthly Report Screen
│   └── Add Property Screen
│
├── Payments Tab
│   ├── Payment List Screen (with filters)
│   ├── Payment Summary Card (top)
│   ├── Create Payment Screen
│   └── Payment Detail Screen → Mark Paid Screen
│
├── Notifications Tab
│   └── Notification List Screen
│
└── Profile Tab
    ├── Edit Profile Screen
    ├── Upload Avatar Screen
    ├── Organization Screen
    │   ├── Create Org Screen
    │   ├── Upload Org Logo Screen
    │   └── Org Members Screen → Add/Remove Member
    ├── Subscription Screen
    │   └── Plans Screen → Select Plan
    └── Payouts Screen
```

### Tenant Screens

```
Tenant Home (bottom nav)
├── Home Tab
│   └── Current Stay Card (property, room, rent, due date)
│       └── Join Property Screen  ← if no active stay
│
├── Payments Tab
│   └── Payment History Screen
│
├── Notifications Tab
│   └── Notification List Screen
│
└── Profile Tab
    └── Edit Profile Screen
```

---

## 5. Dart Models

Copy these directly — they match the API response exactly.

```dart
// core/models/app_user.dart
class AppUser {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String avatarUrl;
  final String gender;           // "MALE" | "FEMALE" | "CO_LIVING"
  final List<String> roles;      // ["OWNER"] | ["TENANT"] | ["OWNER","TENANT"]
  final String city;
  final String area;
  final bool profileCompleted;
  final List<String> providers;  // ["google"] | ["phone"]
  final String createdAt;        // "YYYY-MM-DD"

  bool get isOwner => roles.contains('OWNER');
  bool get isTenant => roles.contains('TENANT');

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    phoneNumber: json['phoneNumber'] ?? '',
    avatarUrl: json['avatarUrl'] ?? '',
    gender: json['gender'] ?? '',
    roles: List<String>.from(json['roles'] ?? []),
    city: json['city'] ?? '',
    area: json['area'] ?? '',
    profileCompleted: json['profileCompleted'] ?? false,
    providers: List<String>.from(json['providers'] ?? []),
    createdAt: json['createdAt'] ?? '',
  );
}
```

```dart
// core/models/property.dart
class Property {
  final String id;
  final String title;
  final String location;
  final String type;          // "PG" | "Flat" | "House"
  final int price;            // rupees — ALWAYS int, never double
  final int deposit;          // rupees
  final double rating;
  final String imageUrl;
  final int totalRooms;
  final int occupiedRooms;    // derived — never send to API
  final String description;
  final List<String> amenities;
  final String ownerName;
  final String ownerAvatarUrl;

  factory Property.fromJson(Map<String, dynamic> json) => Property(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    location: json['location'] ?? '',
    type: json['type'] ?? '',
    price: json['price'] ?? 0,
    deposit: json['deposit'] ?? 0,
    rating: (json['rating'] ?? 0.0).toDouble(),
    imageUrl: json['imageUrl'] ?? '',
    totalRooms: json['totalRooms'] ?? 0,
    occupiedRooms: json['occupiedRooms'] ?? 0,
    description: json['description'] ?? '',
    amenities: List<String>.from(json['amenities'] ?? []),
    ownerName: json['ownerName'] ?? '',
    ownerAvatarUrl: json['ownerAvatarUrl'] ?? '',
  );
}
```

```dart
// core/models/room.dart
class Room {
  final String id;
  final String propertyId;
  final String roomNumber;
  final String type;          // "single" | "double" | "triple"
  final int capacity;
  final int occupiedBeds;     // derived
  final int rentAmount;       // rupees
  final int deposit;          // rupees
  final bool isAvailable;     // derived

  factory Room.fromJson(Map<String, dynamic> json) => Room(
    id: json['id'] ?? '',
    propertyId: json['propertyId'] ?? '',
    roomNumber: json['roomNumber'] ?? '',
    type: json['type'] ?? '',
    capacity: json['capacity'] ?? 0,
    occupiedBeds: json['occupiedBeds'] ?? 0,
    rentAmount: json['rentAmount'] ?? 0,
    deposit: json['deposit'] ?? 0,
    isAvailable: json['isAvailable'] ?? false,
  );
}
```

```dart
// core/models/tenant.dart
class Tenant {
  final String id;          // stay ID
  final String name;
  final String room;        // room number string
  final int rentAmount;     // rupees
  final String dueDate;     // "YYYY-MM-DD"
  final bool isPaid;
  final String avatarUrl;
  final String phone;
  final String email;
  final String joinDate;    // "YYYY-MM-DD"
  final String propertyId;
  final String status;      // "active" | "pending" | "overdue"

  factory Tenant.fromJson(Map<String, dynamic> json) => Tenant(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    room: json['room'] ?? '',
    rentAmount: json['rentAmount'] ?? 0,
    dueDate: json['dueDate'] ?? '',
    isPaid: json['isPaid'] ?? false,
    avatarUrl: json['avatarUrl'] ?? '',
    phone: json['phone'] ?? '',
    email: json['email'] ?? '',
    joinDate: json['joinDate'] ?? '',
    propertyId: json['propertyId'] ?? '',
    status: json['status'] ?? '',
  );
}
```

```dart
// core/models/payment.dart
class Payment {
  final String id;
  final String title;
  final int amount;         // rupees — ALWAYS int
  final String date;        // "YYYY-MM-DD"
  final String status;      // "paid" | "pending" | "overdue"
  final String type;        // "rent" | "deposit" | "electricity" | "maintenance"
  final String tenantName;
  final String propertyId;
  final String description;

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    amount: json['amount'] ?? 0,
    date: json['date'] ?? '',
    status: json['status'] ?? '',
    type: json['type'] ?? '',
    tenantName: json['tenantName'] ?? '',
    propertyId: json['propertyId'] ?? '',
    description: json['description'] ?? '',
  );
}
```

```dart
// core/models/current_stay.dart
class CurrentStay {
  final String propertyName;
  final String roomNumber;
  final String address;
  final int rentAmount;       // rupees
  final String dueDate;       // "YYYY-MM-DD"
  final String ownerName;
  final String ownerPhone;
  final String ownerAvatarUrl;
  final String leaseStart;    // "YYYY-MM-DD"
  final String leaseEnd;      // "YYYY-MM-DD"
  final String imageUrl;
  final bool isRentDue;

  factory CurrentStay.fromJson(Map<String, dynamic> json) => CurrentStay(
    propertyName: json['propertyName'] ?? '',
    roomNumber: json['roomNumber'] ?? '',
    address: json['address'] ?? '',
    rentAmount: json['rentAmount'] ?? 0,
    dueDate: json['dueDate'] ?? '',
    ownerName: json['ownerName'] ?? '',
    ownerPhone: json['ownerPhone'] ?? '',
    ownerAvatarUrl: json['ownerAvatarUrl'] ?? '',
    leaseStart: json['leaseStart'] ?? '',
    leaseEnd: json['leaseEnd'] ?? '',
    imageUrl: json['imageUrl'] ?? '',
    isRentDue: json['isRentDue'] ?? false,
  );
}
```

```dart
// core/models/notification.dart
class AppNotification {
  final String id;
  final String title;
  final String description;
  final String type;        // "rentDue"|"message"|"maintenance"|"leaseRenewal"|"general"
  final String timestamp;   // ISO 8601
  final bool isRead;

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    type: json['type'] ?? '',
    timestamp: json['timestamp'] ?? '',
    isRead: json['isRead'] ?? false,
  );
}
```

```dart
// core/models/subscription.dart
class Subscription {
  final String id;
  final String planId;
  final String planName;
  final String status;      // "active" | "cancelled"
  final String startDate;   // "YYYY-MM-DD"
  final String endDate;     // "YYYY-MM-DD" or ""
  final int price;          // rupees/month

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
    id: json['id'] ?? '',
    planId: json['planId'] ?? '',
    planName: json['planName'] ?? '',
    status: json['status'] ?? '',
    startDate: json['startDate'] ?? '',
    endDate: json['endDate'] ?? '',
    price: json['price'] ?? 0,
  );
}
```

```dart
// core/models/plan.dart
class Plan {
  final String id;
  final String name;
  final int price;
  final int maxProperties;
  final int maxTenants;
  final List<String> features;
  final bool isPopular;
  final bool isCurrent;

  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    price: json['price'] ?? 0,
    maxProperties: json['maxProperties'] ?? 0,
    maxTenants: json['maxTenants'] ?? 0,
    features: List<String>.from(json['features'] ?? []),
    isPopular: json['isPopular'] ?? false,
    isCurrent: json['isCurrent'] ?? false,
  );
}
```

```dart
// core/models/paginated_response.dart
class PaginatedResponse<T> {
  final List<T> data;
  final PaginationMeta meta;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) => PaginatedResponse(
    data: (json['data'] as List).map((e) => fromJson(e)).toList(),
    meta: PaginationMeta.fromJson(json['meta']),
  );
}

class PaginationMeta {
  final int page;
  final int totalPages;
  final int total;

  factory PaginationMeta.fromJson(Map<String, dynamic> json) => PaginationMeta(
    page: json['page'] ?? 1,
    totalPages: json['totalPages'] ?? 1,
    total: json['total'] ?? 0,
  );
}
```

---

## 6. API Integration Layer

```dart
// core/api/api_endpoints.dart
class ApiEndpoints {
  // Auth
  static const me = '/auth/me';
  static const logout = '/auth/logout';
  static const currentStay = '/auth/me/current-stay';
  static const deviceToken = '/auth/device-token';
  static const onboarding = '/users/onboarding';
  static const updateProfile = '/users/profile';
  static const uploadAvatar = '/users/profile/avatar';
  static const linkProvider = '/users/link-provider';

  // Properties
  static const properties = '/properties';
  static String property(String id) => '/properties/$id';
  static String propertyMembers(String id) => '/properties/$id/members';
  static String propertyMember(String id, String userId) => '/properties/$id/members/$userId';

  // Rooms
  static String rooms(String propertyId) => '/properties/$propertyId/rooms';
  static String room(String id) => '/rooms/$id';

  // Tenants
  static String tenants(String propertyId) => '/properties/$propertyId/tenants';
  static String inviteTenant(String propertyId) => '/properties/$propertyId/tenants/invite';
  static const joinProperty = '/tenants/join';
  static String tenant(String id) => '/tenants/$id';

  // Payments
  static const payments = '/payments';
  static const paymentSummary = '/payments/summary';
  static const paymentCollections = '/payments/collections';
  static String payPayment(String id) => '/payments/$id/pay';

  // Notifications
  static const notifications = '/notifications';
  static String markRead(String id) => '/notifications/$id/read';
  static const markAllRead = '/notifications/mark-all-read';

  // Subscriptions
  static const currentSubscription = '/subscriptions/current';
  static const subscriptions = '/subscriptions';
  static String subscription(String id) => '/subscriptions/$id';

  // Plans & Payouts
  static const plans = '/plans';
  static const payouts = '/payouts';

  // Organizations
  static const orgs = '/orgs';
  static const myOrg = '/orgs/me';
  static String orgMembers(String id) => '/orgs/$id/members';
  static String orgMember(String id, String userId) => '/orgs/$id/members/$userId';

  // Reports
  static String propertyReport(String propertyId) => '/reports/properties/$propertyId';
}
```

```dart
// core/errors/app_exception.dart
class AppException implements Exception {
  final int code;
  final String message;

  AppException({required this.code, required this.message});

  factory AppException.fromResponse(Response response) {
    final body = response.data;
    return AppException(
      code: body['code'] ?? response.statusCode ?? 0,
      message: body['error'] ?? 'Something went wrong',
    );
  }

  bool get isNotFound => code == 404;
  bool get isUnauthorized => code == 401;
  bool get isForbidden => code == 403;
  bool get isConflict => code == 409;

  @override
  String toString() => message;
}

// Helper to wrap all API calls
Future<T> apiCall<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on DioException catch (e) {
    if (e.response != null) {
      throw AppException.fromResponse(e.response!);
    }
    throw AppException(code: 0, message: 'Network error. Check your connection.');
  }
}
```

---

## 7. Screen-by-Screen API Calls

### Auth Screens

**Login Screen**
```dart
// 1. Trigger Firebase Google Sign-In
// 2. On success, call:
GET /auth/me
// Returns AppUser
// → if !profileCompleted → go to Onboarding
// → if isOwner → go to Owner Home
// → if isTenant → go to Tenant Home
```

**Onboarding Screen**
```dart
POST /users/onboarding
Body: {
  "name": "Amol",
  "gender": "MALE",        // "MALE" | "FEMALE" | "CO_LIVING"
  "phoneNumber": "+91...", // optional
  "city": "Pune",          // optional
  "area": "Koregaon Park"  // optional
}
// Returns AppUser with profileCompleted: true
```

**Edit Profile Screen**
```dart
PATCH /users/profile
Body: { "name": "...", "gender": "...", "city": "...", "area": "..." }
// All fields optional — only send what changed
```

**Upload Avatar Screen**
```dart
// IMPORTANT: Base64 JSON, NOT multipart form

import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

final image = await ImagePicker().pickImage(source: ImageSource.gallery);
final compressed = await FlutterImageCompress.compressWithFile(
  image!.path,
  quality: 80,
  minWidth: 400,
  minHeight: 400,
);

POST /users/profile/avatar
Body: {
  "contentType": "image/jpeg",
  "data": base64Encode(compressed!)  // base64 string, NOT bytes
}
```

**Register FCM Token** (call on app start after login)
```dart
final fcmToken = await FirebaseMessaging.instance.getToken();
POST /auth/device-token
Body: { "token": fcmToken }
```

---

### Owner: Properties

**Property List Screen**
```dart
GET /properties?page=1&limit=10
// Returns PaginatedResponse<Property>
// Implement infinite scroll — load next page when reaching bottom
```

**Create Property Screen**
```dart
POST /properties
Body: {
  "title": "Sunrise PG",
  "location": "Near FC Road, Pune",
  "type": "PG",           // "PG" | "Flat" | "House"
  "price": 8000,          // int, rupees
  "deposit": 16000,       // int, rupees
  "totalRooms": 10,
  "description": "...",   // optional
  "amenities": ["WiFi", "AC"]  // optional
}
// Returns Property with 201
```

**Property Detail Screen**
```dart
GET /properties/:id
// Returns Property
```

**Edit Property Screen**
```dart
PUT /properties/:id
Body: { same as create — all fields required }
```

**Delete Property**
```dart
DELETE /properties/:id
// Returns 204 No Content — no body to parse
```

---

### Owner: Property Images

**Image Gallery** (inside Property Detail Screen)
```dart
GET /properties/:id/images
// Returns List<PropertyImage>
// isCover: true → show star/cover badge
// Ordered by position ascending
```

**Upload Property Image**
```dart
// Base64 JSON, NOT multipart — same pattern as avatar upload
POST /properties/:id/images
Body: {
  "contentType": "image/jpeg",   // "image/jpeg" | "image/png" | "image/webp"
  "data": base64Encode(bytes)    // max 10 MB compressed
}
// Returns PropertyImage with 201
// First image uploaded automatically becomes isCover: true
```

**Delete Property Image**
```dart
DELETE /properties/:id/images/:imageId
// Returns 204 No Content
// If deleted image was isCover, backend auto-promotes next image as cover
```

```dart
// core/models/property_image.dart
class PropertyImage {
  final String id;
  final String url;
  final bool isCover;
  final int position;

  factory PropertyImage.fromJson(Map<String, dynamic> json) => PropertyImage(
    id: json['id'] ?? '',
    url: json['url'] ?? '',
    isCover: json['isCover'] ?? false,
    position: json['position'] ?? 0,
  );
}
```

---

### Owner: Rooms

**Room List Screen**
```dart
GET /properties/:propertyId/rooms
// Returns List<Room> (not paginated)
// Show isAvailable badge on each card
```

**Create Room Screen**
```dart
POST /properties/:propertyId/rooms
Body: {
  "roomNumber": "101",
  "type": "double",       // "single" | "double" | "triple"
  "capacity": 2,          // total beds
  "rentAmount": 8000,     // int, rupees per bed
  "deposit": 16000        // int, rupees
}
```

**Edit Room Screen**
```dart
PATCH /rooms/:id
Body: {
  "roomNumber": "102",    // all optional
  "type": "triple",
  "capacity": 3,
  "rentAmount": 7500,
  "deposit": 15000
}
```

---

### Owner: Tenants

**Tenant List Screen**
```dart
GET /properties/:propertyId/tenants?page=1&limit=20
// Returns PaginatedResponse<Tenant>
// Show status badge: active (green) | overdue (red) | pending (orange)
// Show isPaid indicator
```

**Invite Tenant Screen**
```dart
// 1. First load rooms to let owner pick
GET /properties/:propertyId/rooms

// 2. Create invite
POST /properties/:propertyId/tenants/invite
Body: {
  "roomId": "room_abc",
  "leaseStart": "2024-02-01",   // "YYYY-MM-DD"
  "leaseEnd": "2025-01-31",
  "rentAmount": 8000,
  "email": "tenant@email.com"   // optional
}
// Returns { inviteCode: "INV-XYZABC", expiresAt: "..." }
// Show code prominently with a Share/Copy button
// Expires in 72 hours — show countdown
```

**Update Tenant Screen**
```dart
PATCH /tenants/:id
Body: {
  "leaseEnd": "2025-06-30",   // all optional
  "rentAmount": 9000,
  "roomId": "room_xyz"
}
```

**Remove Tenant**
```dart
DELETE /tenants/:id
// Returns 204 No Content
```

---

### Owner: Payments

**Payment Summary Card** (dashboard widget)
```dart
GET /payments/summary
// Returns:
// { totalCollectedThisMonth: 72000, pendingAmount: 16000,
//   totalTenants: 12, overdueTenants: 2 }
// Show as 4 stat cards at the top of payments tab
```

**Payment List Screen**
```dart
GET /payments?page=1&limit=20&propertyId=...&status=pending&type=rent
// Query params all optional — use for filters
// Returns PaginatedResponse<Payment>
```

**Create Payment Screen**
```dart
// Generate idempotency key before submitting (prevents double-submit on retry)
import 'package:uuid/uuid.dart';
final idempotencyKey = const Uuid().v4();

POST /payments
Headers: { "X-Idempotency-Key": idempotencyKey }
Body: {
  "propertyId": "prop_abc",
  "title": "February Rent",
  "amount": 8000,           // int, rupees
  "type": "rent",           // "rent"|"deposit"|"electricity"|"maintenance"
  "description": "..."      // optional
}
```

**Mark Payment as Paid Screen**
```dart
POST /payments/:id/pay
Body: {
  "paymentMethod": "UPI",        // free text: "UPI" | "Cash" | "Bank Transfer"
  "transactionRef": "UTR123456"  // reference number
}
// Returns updated Payment with status: "paid"
```

---

### Tenant: Home

**Current Stay Screen**
```dart
GET /auth/me/current-stay
// ⚠️ Returns 204 (NO BODY) if tenant has no active stay
// Handle 204 → show "Join a property" prompt

// If 200 → show CurrentStay card:
// - Property name, room number, address
// - Rent amount + due date
// - isRentDue: true → show red alert banner
// - Owner contact (name, phone, avatar)
// - Lease dates
```

**Join Property Screen** (when tenant has no active stay)
```dart
POST /tenants/join
Body: { "inviteCode": "INV-XYZABC" }
// Returns CurrentStay on success
// 404 → "Invalid or expired code"
```

---

### Tenant: Payments

**Tenant Payment History**
```dart
GET /payments?page=1&limit=20
// Tenant automatically sees only their own payments (backend scopes by role)
```

---

### Notifications (Both Owner & Tenant)

**Notification List Screen**
```dart
GET /notifications?page=1&limit=20
// Returns PaginatedResponse<AppNotification>
// Show unread count badge on tab icon (meta.total unread)
```

**Mark Single Read**
```dart
PATCH /notifications/:id/read
```

**Mark All Read**
```dart
PATCH /notifications/mark-all-read
// Returns { updated: 5 }
```

**FCM Push Notification Setup**
```dart
// In main.dart after login:
FirebaseMessaging.onMessage.listen((message) {
  // App is in foreground — show in-app banner
  showInAppNotification(message.notification?.title, message.notification?.body);
  // Refresh notification list
  ref.invalidate(notificationsProvider);
});

FirebaseMessaging.onMessageOpenedApp.listen((message) {
  // App was in background, user tapped notification
  // Navigate to notifications screen
  router.go('/notifications');
});
```

---

### Subscriptions (Owner only)

**Current Subscription Screen**
```dart
GET /subscriptions/current
// ⚠️ Returns 204 (NO BODY) if owner has no active subscription
// Handle 204 → show "Choose a plan" prompt
```

**Plans Screen**
```dart
GET /plans
// Returns List<Plan>
// isCurrent: true → highlight current plan
// isPopular: true → show "Most Popular" badge

// Subscribe or switch plan:
POST /subscriptions
Body: { "planId": "plan_pro" }
// Works for both new subscription AND switching plans
// Returns Subscription with 201
```

---

### Owner: Organizations

> Organizations group multiple owners sharing a billing account. Most owners won't need this initially — show it only if `orgs/me` returns 404.

**Get My Org**
```dart
GET /orgs/me
// Returns Organization | 404 (no org yet)
// 404 → show "Create Organization" prompt
```

**Create Organization**
```dart
POST /orgs
Body: { "name": "My Property Group" }
// Returns Organization with 201
// One org per user — 409 if already exists
```

**Upload Org Logo**
```dart
POST /orgs/:id/logo
Body: {
  "contentType": "image/jpeg",
  "data": base64Encode(bytes)    // max 5 MB
}
// Returns updated Organization with logoUrl populated
```

**Org Members Screen**
```dart
GET /orgs/:id/members
// Returns List<OrgMember>
// role: "owner" | "member"
```

**Add Org Member**
```dart
POST /orgs/:id/members
Body: { "userId": "usr_...", "role": "member" }   // "owner" | "member"
// Returns 204 No Content
```

**Remove Org Member**
```dart
DELETE /orgs/:id/members/:userId
// Returns 204 No Content
```

```dart
// core/models/organization.dart
class Organization {
  final String id;
  final String name;
  final String billingOwnerId;
  final String logoUrl;      // "" when no logo uploaded
  final String createdAt;    // "YYYY-MM-DD"

  factory Organization.fromJson(Map<String, dynamic> json) => Organization(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    billingOwnerId: json['billingOwnerId'] ?? '',
    logoUrl: json['logoUrl'] ?? '',
    createdAt: json['createdAt'] ?? '',
  );
}

// core/models/org_member.dart
class OrgMember {
  final String userId;
  final String name;
  final String email;
  final String avatarUrl;
  final String role;       // "owner" | "member"
  final String joinedAt;   // "YYYY-MM-DD"

  factory OrgMember.fromJson(Map<String, dynamic> json) => OrgMember(
    userId: json['userId'] ?? '',
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    avatarUrl: json['avatarUrl'] ?? '',
    role: json['role'] ?? '',
    joinedAt: json['joinedAt'] ?? '',
  );
}
```

---

### Reports (Owner only)

**Monthly Report Screen**
```dart
GET /reports/properties/:propertyId?month=2024-01
// month param optional, defaults to current month
// Returns PropertyReport:
// { totalCollected, totalPending, overdueCount, occupancyRate, payments: [...] }
// occupancyRate is 0.0–1.0 → display as percentage (e.g. 0.7 → "70%")

// Month picker: show last 12 months as a dropdown/chip selector
// Format: DateTime → "${year}-${month.toString().padLeft(2, '0')}"
```

---

## 8. Critical Rules

### Money — Always Int, Never Float
```dart
// CORRECT
Text('₹${payment.amount}')
Text('₹${NumberFormat('#,##,###').format(payment.amount)}')

// WRONG — never do this
double amount = payment.amount.toDouble(); // NO
Text('₹${payment.amount.toStringAsFixed(2)}'); // NO
```

### Currency Formatter
```dart
// core/utils/formatters.dart
import 'package:intl/intl.dart';

String formatRupees(int amount) {
  return '₹${NumberFormat('#,##,###').format(amount)}';
  // 8000 → "₹8,000"
  // 100000 → "₹1,00,000" (Indian format)
}
```

### Dates — Always String, Never DateTime in JSON
```dart
// API sends "2024-02-01" — display it, don't parse unless needed
Text(tenant.dueDate)  // "2024-02-01"

// For display formatting:
String formatDate(String isoDate) {
  final dt = DateTime.parse(isoDate);
  return DateFormat('dd MMM yyyy').format(dt); // "01 Feb 2024"
}

// For sending to API:
String toApiDate(DateTime dt) => DateFormat('yyyy-MM-dd').format(dt);
```

### 204 No Content — Two endpoints return this
```dart
// Handle explicitly — no body to parse
try {
  final response = await dio.get('/subscriptions/current');
  if (response.statusCode == 204) {
    // No subscription — show "Choose a plan"
    return null;
  }
  return Subscription.fromJson(response.data);
} on DioException catch (e) {
  if (e.response?.statusCode == 204) return null;
  rethrow;
}
```

### Pagination — Load More Pattern
```dart
class PaginatedNotifier<T> extends StateNotifier<AsyncValue<List<T>>> {
  int _page = 1;
  bool _hasMore = true;

  Future<void> loadMore() async {
    if (!_hasMore) return;
    final response = await fetchPage(_page);
    _hasMore = _page < response.meta.totalPages;
    _page++;
    state = AsyncData([...state.value ?? [], ...response.data]);
  }
}
```

### Idempotency Key for Payments
```dart
// Generate ONCE before showing the form
// Reuse the same key on retry (don't regenerate on each tap)
final _idempotencyKey = const Uuid().v4();

// Pass as header
await dio.post('/payments',
  data: body,
  options: Options(headers: {'X-Idempotency-Key': _idempotencyKey}),
);
```

---

## 9. Error Handling

All API errors return:
```json
{ "code": 400, "error": "Human readable message" }
```

```dart
// Unified error display
void handleApiError(AppException e, BuildContext context) {
  switch (e.code) {
    case 401:
      // Force logout — token expired
      ref.read(authProvider.notifier).logout();
      break;
    case 402:
      // Plan limit exceeded (too many properties or tenants for current plan)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)), // e.g. "Upgrade your plan to add more properties"
      );
      // Optionally navigate to subscription screen
      router.go('/profile/subscription');
      break;
    case 403:
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You don\'t have permission to do this')),
      );
      break;
    case 404:
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
      break;
    case 409:
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)), // e.g. "Org already exists"
      );
      break;
    default:
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
  }
}
```

---

## 10. Navigation & Routing

```dart
// Using go_router
final router = GoRouter(
  redirect: (context, state) {
    final user = ref.read(authProvider);
    if (user == null) return '/login';
    if (!user.profileCompleted) return '/onboarding';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),

    // Owner routes
    ShellRoute(
      builder: (_, __, child) => OwnerShell(child: child),
      routes: [
        GoRoute(path: '/properties', builder: (_, __) => const PropertyListScreen()),
        GoRoute(path: '/properties/:id', builder: (_, state) =>
          PropertyDetailScreen(id: state.pathParameters['id']!)),
        GoRoute(path: '/payments', builder: (_, __) => const PaymentListScreen()),
        GoRoute(path: '/notifications', builder: (_, __) => const NotificationScreen()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      ],
    ),

    // Tenant routes
    ShellRoute(
      builder: (_, __, child) => TenantShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const TenantHomeScreen()),
        GoRoute(path: '/join', builder: (_, __) => const JoinPropertyScreen()),
        GoRoute(path: '/my-payments', builder: (_, __) => const TenantPaymentScreen()),
      ],
    ),
  ],
);
```

---

## Quick Reference

| Need | Call |
|------|------|
| Current user | `GET /auth/me` |
| Owner's properties | `GET /properties` |
| Rooms in a property | `GET /properties/:id/rooms` |
| Tenants in a property | `GET /properties/:id/tenants` |
| Create invite code | `POST /properties/:id/tenants/invite` |
| Tenant joins with code | `POST /tenants/join` |
| Create rent payment | `POST /payments` + `X-Idempotency-Key` header |
| Confirm cash/UPI received | `POST /payments/:id/pay` |
| Tenant's lease info | `GET /auth/me/current-stay` (204 if none) |
| Monthly report | `GET /reports/properties/:id?month=YYYY-MM` |
| Active subscription | `GET /subscriptions/current` (204 if none) |
| Subscribe to plan | `POST /subscriptions` `{ planId: "plan_pro" }` |
| Available plans | `GET /plans` |
| Notification list | `GET /notifications` |
| Mark all read | `PATCH /notifications/mark-all-read` |
| Property images | `GET /properties/:id/images` |
| Upload property image | `POST /properties/:id/images` (base64 JSON) |
| Delete property image | `DELETE /properties/:id/images/:imageId` |
| My organization | `GET /orgs/me` (404 if none) |
| Create organization | `POST /orgs` `{ name: "..." }` |
| Org members | `GET /orgs/:id/members` |
| Health check | `GET /health` |
| Readiness probe | `GET /ready` |
