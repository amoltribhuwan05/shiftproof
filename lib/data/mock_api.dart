// ============================================================
// SHIFTPROOF MOCK API DATA
// This is the single source of truth for all mock data.
// When integrating with a real backend, replace the data in
// MockApiService with API calls — this file can be deleted.
//
// IMPORTANT: All monetary values are stored as plain integers (rupees).
// Use CurrencyFormatter.format(amount) for UI display.
// ============================================================

class MockApi {
  // ─── CURRENT LOGGED-IN USER (Owner) ──────────────────────
  static const Map<String, dynamic> currentOwner = {
    'id': 'usr_001',
    'name': 'Amol Sharma',
    'email': 'amol.sharma@example.com',
    'phone': '+91 98765 43210',
    'avatarUrl': 'https://i.pravatar.cc/150?img=11',
    'role': 'owner',
    'joinDate': 'Jan 2023',
    'location': 'Bangalore, Karnataka',
  };

  // ─── CURRENT LOGGED-IN USER (Tenant) ─────────────────────
  static const Map<String, dynamic> currentTenant = {
    'id': 'usr_002',
    'name': 'Riya Mehta',
    'email': 'riya.mehta@example.com',
    'phone': '+91 87654 32109',
    'avatarUrl': 'https://i.pravatar.cc/150?img=12',
    'role': 'tenant',
    'joinDate': 'Mar 2024',
    'location': 'Bangalore, Karnataka',
  };

  // ─── CURRENT STAY (Tenant view) ──────────────────────────
  static const Map<String, dynamic> currentStay = {
    'propertyName': 'Sunnyvale PG',
    'roomNumber': 'Room 302',
    'address': '14th Cross, Koramangala, Bangalore - 560034',
    'rentAmount': 8500,
    'dueDate': '2026-03-05',
    'ownerName': 'Amol Sharma',
    'ownerPhone': '+91 98765 43210',
    'ownerAvatarUrl': 'https://i.pravatar.cc/150?img=11',
    'leaseStart': '2025-06-01',
    'leaseEnd': '2026-05-31',
    'imageUrl':
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?q=80&w=2070&auto=format&fit=crop',
    'isRentDue': true,
  };

  // ─── PROPERTIES ───────────────────────────────────────────
  static const List<Map<String, dynamic>> properties = [
    {
      'id': 'prop_001',
      'title': 'Sunnyvale PG',
      'location': 'Koramangala, Bangalore',
      'type': 'PG',
      'price': 8500,
      'deposit': 17000,
      'rating': 4.8,
      'imageUrl':
          'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?q=80&w=2070&auto=format&fit=crop',
      'totalRooms': 16,
      'occupiedRooms': 12,
      'description':
          'A premium PG in the heart of Koramangala with modern amenities, high-speed WiFi, and 24/7 security. Walking distance from major tech parks.',
      'amenities': ['WiFi', 'AC', 'Meals', 'Laundry', 'Security', 'Parking'],
      'ownerName': 'Amol Sharma',
      'ownerAvatarUrl': 'https://i.pravatar.cc/150?img=11',
    },
    {
      'id': 'prop_002',
      'title': 'Grandview Apartments',
      'location': 'Indiranagar, Bangalore',
      'type': 'Flat',
      'price': 24000,
      'deposit': 120000,
      'rating': 4.5,
      'imageUrl':
          'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?q=80&w=2070&auto=format&fit=crop',
      'totalRooms': 8,
      'occupiedRooms': 8,
      'description':
          'Spacious 2BHK apartments in Indiranagar with modular kitchen, covered parking, and a rooftop terrace. Fully furnished.',
      'amenities': ['WiFi', 'AC', 'Power Backup', 'Gym', 'Lift', 'Parking'],
      'ownerName': 'Amol Sharma',
      'ownerAvatarUrl': 'https://i.pravatar.cc/150?img=11',
    },
    {
      'id': 'prop_003',
      'title': 'Sunset Heights',
      'location': 'HSR Layout, Bangalore',
      'type': 'PG',
      'price': 15000,
      'deposit': 45000,
      'rating': 4.2,
      'imageUrl':
          'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?q=80&w=2070&auto=format&fit=crop',
      'totalRooms': 24,
      'occupiedRooms': 24,
      'description':
          'Affordable shared accommodation in HSR Layout with all basic amenities. Close to metro and bus stops.',
      'amenities': ['WiFi', 'Meals', 'Security', 'Water', 'Laundry'],
      'ownerName': 'Amol Sharma',
      'ownerAvatarUrl': 'https://i.pravatar.cc/150?img=11',
    },
    {
      'id': 'prop_004',
      'title': 'The Marquee Plaza',
      'location': 'Whitefield, Bangalore',
      'type': 'Flat',
      'price': 35000,
      'deposit': 210000,
      'rating': 4.9,
      'imageUrl':
          'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?q=80&w=2000&auto=format&fit=crop',
      'totalRooms': 12,
      'occupiedRooms': 9,
      'description':
          'Luxury 3BHK apartments near Whitefield IT corridor. Premium finishes, clubhouse access, and concierge service.',
      'amenities': [
        'WiFi',
        'AC',
        'Gym',
        'Pool',
        'Security',
        'Parking',
        'Power Backup',
      ],
      'ownerName': 'Amol Sharma',
      'ownerAvatarUrl': 'https://i.pravatar.cc/150?img=11',
    },
    {
      'id': 'prop_005',
      'title': 'Riverside Lofts',
      'location': 'Electronic City, Bangalore',
      'type': 'PG',
      'price': 6500,
      'deposit': 6500,
      'rating': 4.0,
      'imageUrl':
          'https://images.unsplash.com/photo-1493246507139-91e8fad9978e?q=80&w=2070&auto=format&fit=crop',
      'totalRooms': 30,
      'occupiedRooms': 22,
      'description':
          'Budget-friendly PG near Electronic City with shuttle service to nearby tech parks. Great community and clean rooms.',
      'amenities': ['WiFi', 'Meals', 'Shuttle', 'Security', 'Water'],
      'ownerName': 'Amol Sharma',
      'ownerAvatarUrl': 'https://i.pravatar.cc/150?img=11',
    },
  ];

  // ─── TENANTS ──────────────────────────────────────────────
  static const List<Map<String, dynamic>> tenants = [
    {
      'id': 'ten_001',
      'name': 'Riya Mehta',
      'room': 'Room 302',
      'rentAmount': 8500,
      'dueDate': '2026-03-05',
      'isPaid': false,
      'avatarUrl': 'https://i.pravatar.cc/150?img=12',
      'phone': '+91 87654 32109',
      'email': 'riya.mehta@example.com',
      'joinDate': '2025-06-01',
      'propertyId': 'prop_001',
      'status': 'overdue',
    },
    {
      'id': 'ten_002',
      'name': 'Arjun Verma',
      'room': 'Room 101',
      'rentAmount': 8500,
      'dueDate': '2026-03-05',
      'isPaid': true,
      'avatarUrl': 'https://i.pravatar.cc/150?img=15',
      'phone': '+91 76543 21098',
      'email': 'arjun.verma@example.com',
      'joinDate': '2024-08-01',
      'propertyId': 'prop_001',
      'status': 'active',
    },
    {
      'id': 'ten_003',
      'name': 'Priya Nair',
      'room': 'Room 205',
      'rentAmount': 8500,
      'dueDate': '2026-03-10',
      'isPaid': false,
      'avatarUrl': 'https://i.pravatar.cc/150?img=16',
      'phone': '+91 65432 10987',
      'email': 'priya.nair@example.com',
      'joinDate': '2024-11-01',
      'propertyId': 'prop_001',
      'status': 'pending',
    },
    {
      'id': 'ten_004',
      'name': 'Suresh Kiran',
      'room': 'A-201',
      'rentAmount': 24000,
      'dueDate': '2026-04-01',
      'isPaid': true,
      'avatarUrl': 'https://i.pravatar.cc/150?img=20',
      'phone': '+91 54321 09876',
      'email': 'suresh.kiran@example.com',
      'joinDate': '2025-01-01',
      'propertyId': 'prop_002',
      'status': 'active',
    },
    {
      'id': 'ten_005',
      'name': 'Meera Pillai',
      'room': 'B-104',
      'rentAmount': 15000,
      'dueDate': '2026-03-05',
      'isPaid': false,
      'avatarUrl': 'https://i.pravatar.cc/150?img=25',
      'phone': '+91 43210 98765',
      'email': 'meera.pillai@example.com',
      'joinDate': '2024-10-15',
      'propertyId': 'prop_003',
      'status': 'overdue',
    },
  ];

  // ─── PAYMENTS ─────────────────────────────────────────────
  static const List<Map<String, dynamic>> payments = [
    {
      'id': 'pay_001',
      'title': 'March 2026 Rent',
      'amount': 8500,
      'date': '2026-03-01',
      'status': 'pending',
      'type': 'rent',
      'tenantName': 'Riya Mehta',
      'propertyId': 'prop_001',
      'description': 'Room 302 — March 2026 monthly rent',
    },
    {
      'id': 'pay_002',
      'title': 'February 2026 Rent',
      'amount': 8500,
      'date': '2026-02-01',
      'status': 'paid',
      'type': 'rent',
      'tenantName': 'Riya Mehta',
      'propertyId': 'prop_001',
      'description': 'Room 302 — February 2026 monthly rent',
    },
    {
      'id': 'pay_003',
      'title': 'January 2026 Rent',
      'amount': 8500,
      'date': '2026-01-01',
      'status': 'paid',
      'type': 'rent',
      'tenantName': 'Riya Mehta',
      'propertyId': 'prop_001',
      'description': 'Room 302 — January 2026 monthly rent',
    },
    {
      'id': 'pay_004',
      'title': 'Security Deposit',
      'amount': 17000,
      'date': '2025-06-01',
      'status': 'paid',
      'type': 'deposit',
      'tenantName': 'Riya Mehta',
      'propertyId': 'prop_001',
      'description': '2-month security deposit on move-in',
    },
    {
      'id': 'pay_005',
      'title': 'Electricity Bill — Feb',
      'amount': 1200,
      'date': '2026-02-15',
      'status': 'paid',
      'type': 'electricity',
      'tenantName': 'Riya Mehta',
      'propertyId': 'prop_001',
      'description': 'February 2026 shared electricity charges',
    },
    {
      'id': 'pay_006',
      'title': 'Maintenance Charge',
      'amount': 500,
      'date': '2026-01-10',
      'status': 'paid',
      'type': 'maintenance',
      'tenantName': 'Riya Mehta',
      'propertyId': 'prop_001',
      'description': 'Water filter service and plumbing',
    },
    {
      'id': 'pay_007',
      'title': 'March 2026 Rent — Arjun',
      'amount': 8500,
      'date': '01 Mar 2026',
      'status': 'paid',
      'type': 'rent',
      'tenantName': 'Arjun Verma',
      'propertyId': 'prop_001',
      'description': 'Room 101 — March 2026 monthly rent',
    },
    {
      'id': 'pay_008',
      'title': 'March 2026 Rent — Priya',
      'amount': 8500,
      'date': '01 Mar 2026',
      'status': 'overdue',
      'type': 'rent',
      'tenantName': 'Priya Nair',
      'propertyId': 'prop_001',
      'description': 'Room 205 — March 2026 monthly rent',
    },
  ];

  // ─── PAYOUTS ──────────────────────────────────────────────
  static const List<Map<String, dynamic>> payouts = [
    {
      'id': 'pout_001',
      'amount': 45000,
      'date': '2026-02-05',
      'status': 'completed',
      'bankLast4': '4821',
      'propertyTitle': 'Sunnyvale PG',
      'description': 'February 2026 rent collection payout (12 tenants)',
    },
    {
      'id': 'pout_002',
      'amount': 24000,
      'date': '2026-02-05',
      'status': 'completed',
      'bankLast4': '4821',
      'propertyTitle': 'Grandview Apartments',
      'description': 'February 2026 rent collection payout',
    },
    {
      'id': 'pout_003',
      'amount': 45000,
      'date': '2026-01-05',
      'status': 'completed',
      'bankLast4': '4821',
      'propertyTitle': 'Sunnyvale PG',
      'description': 'January 2026 rent collection payout',
    },
    {
      'id': 'pout_004',
      'amount': 2800,
      'date': '2026-03-12',
      'status': 'processing',
      'bankLast4': '4821',
      'propertyTitle': 'Sunset Heights',
      'description': 'March 2026 partial payout — collections in progress',
    },
  ];

  // ─── NOTIFICATIONS ────────────────────────────────────────
  static const List<Map<String, dynamic>> notifications = [
    {
      'id': 'notif_001',
      'title': 'Rent Due Reminder',
      'description':
          'Your March 2026 rent of ₹8,500 is due on 5 Mar. Tap to pay now.',
      'type': 'rentDue',
      'timestamp': '2026-03-04T22:00:00Z',
      'isRead': false,
    },
    {
      'id': 'notif_002',
      'title': 'New Message from Owner',
      'description':
          'Amol Sharma: "The water filter in your floor will be serviced tomorrow between 10–12am."',
      'type': 'message',
      'timestamp': '2026-03-04T19:00:00Z',
      'isRead': false,
    },
    {
      'id': 'notif_003',
      'title': 'Maintenance Request Updated',
      'description':
          'Your request #MR-003 (AC not cooling) has been assigned to a technician. ETA: Tomorrow.',
      'type': 'maintenance',
      'timestamp': '2026-03-04T00:00:00Z',
      'isRead': false,
    },
    {
      'id': 'notif_004',
      'title': 'Lease Renewal Upcoming',
      'description':
          'Your lease expires on 31 May 2026. Renew early to lock in your current rate.',
      'type': 'leaseRenewal',
      'timestamp': '2026-03-02T00:00:00Z',
      'isRead': true,
    },
    {
      'id': 'notif_005',
      'title': 'Payment Successful',
      'description':
          'Your payment of ₹8,500 was received successfully for February 2026.',
      'type': 'general',
      'timestamp': '2026-02-28T00:00:00Z',
      'isRead': true,
    },
  ];
}
