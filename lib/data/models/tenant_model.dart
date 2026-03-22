class Tenant {
  const Tenant({
    required this.id,
    required this.name,
    required this.room,
    required this.rentAmount,
    required this.dueDate,
    required this.isPaid,
    required this.avatarUrl,
    required this.phone,
    required this.email,
    required this.joinDate,
    required this.propertyId,
    required this.status,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      room: json['room'] as String? ?? '',
      rentAmount: (json['rentAmount'] as num?)?.toInt() ?? 0,
      dueDate: json['dueDate'] as String? ?? '',
      isPaid: json['isPaid'] as bool? ?? false,
      avatarUrl: json['avatarUrl'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      joinDate: json['joinDate'] as String? ?? '',
      propertyId: json['propertyId'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
    );
  }
  final String id;
  final String name;
  final String room;

  /// Monthly rent in rupees (integer). Use CurrencyFormatter.format() for display.
  final int rentAmount;

  /// ISO 8601 date string (e.g. "2026-03-05"). Parse with DateTime.parse() for comparisons.
  final String dueDate;

  /// True if the current period's rent has been paid.
  final bool isPaid;

  final String avatarUrl;
  final String phone;
  final String email;

  /// ISO 8601 date string (e.g. "2025-06-01"). Parse for tenancy duration calculations.
  final String joinDate;

  final String propertyId;

  /// Rent status: 'active' | 'pending' | 'overdue'
  final String status;

  /// Number of months this tenant has been staying. Returns -1 if unparseable.
  int get monthsStaying {
    try {
      final start = DateTime.parse(joinDate);
      final now = DateTime.now();
      return (now.year - start.year) * 12 + now.month - start.month;
    } on Exception catch (_) {
      return -1;
    }
  }
}

/// Request body for POST /api/v1/properties/{propertyId}/tenants/invite
class InviteTenantRequest {
  const InviteTenantRequest({
    required this.roomId,
    required this.leaseStart,
    required this.leaseEnd,
    required this.rentAmount,
    this.email,
    this.phoneNumber,
  });

  final String roomId;

  /// ISO 8601 date string, e.g. "2026-04-01"
  final String leaseStart;

  /// ISO 8601 date string, e.g. "2027-03-31"
  final String leaseEnd;

  final int rentAmount;
  final String? email;
  final String? phoneNumber;

  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'leaseStart': leaseStart,
      'leaseEnd': leaseEnd,
      'rentAmount': rentAmount,
      if (email != null) 'email': email,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
    };
  }
}

/// Response from POST /api/v1/properties/{propertyId}/tenants/invite
class TenantInviteResponse {
  const TenantInviteResponse({
    required this.inviteCode,
    required this.expiresAt,
  });

  factory TenantInviteResponse.fromJson(Map<String, dynamic> json) {
    return TenantInviteResponse(
      inviteCode: json['inviteCode'] as String? ?? '',
      expiresAt: json['expiresAt'] as String? ?? '',
    );
  }

  final String inviteCode;

  /// ISO 8601 datetime string
  final String expiresAt;
}
