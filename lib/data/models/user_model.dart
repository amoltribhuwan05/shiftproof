class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final String role; // 'owner', 'tenant'
  /// ISO 8601 date string (e.g. "2023-01-15"). Use DateTime.parse() for logic.
  final String joinDate;
  final String location;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.role,
    required this.joinDate,
    required this.location,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      avatarUrl: json['avatarUrl'] as String,
      role: json['role'] as String,
      joinDate: json['joinDate'] as String,
      location: json['location'] as String,
    );
  }
}

class CurrentStay {
  final String propertyName;
  final String roomNumber;
  final String address;

  /// Monthly rent in rupees (integer). Use CurrencyFormatter.format() for display.
  final int rentAmount;

  /// ISO 8601 date string (e.g. "2026-03-05"). Parse with DateTime.parse() for comparisons.
  final String dueDate;

  final String ownerName;
  final String ownerPhone;
  final String ownerAvatarUrl;

  /// ISO 8601 date strings for lease period. Parse for duration calculations.
  final String leaseStart;
  final String leaseEnd;

  final String imageUrl;

  /// True if rent for the current period is unpaid.
  final bool isRentDue;

  const CurrentStay({
    required this.propertyName,
    required this.roomNumber,
    required this.address,
    required this.rentAmount,
    required this.dueDate,
    required this.ownerName,
    required this.ownerPhone,
    required this.ownerAvatarUrl,
    required this.leaseStart,
    required this.leaseEnd,
    required this.imageUrl,
    required this.isRentDue,
  });

  /// Convenience getter — parses leaseEnd to compute remaining days.
  int get daysUntilLeaseExpiry {
    try {
      return DateTime.parse(leaseEnd).difference(DateTime.now()).inDays;
    } catch (_) {
      return -1;
    }
  }

  factory CurrentStay.fromJson(Map<String, dynamic> json) {
    return CurrentStay(
      propertyName: json['propertyName'] as String,
      roomNumber: json['roomNumber'] as String,
      address: json['address'] as String,
      rentAmount: (json['rentAmount'] as num).toInt(),
      dueDate: json['dueDate'] as String,
      ownerName: json['ownerName'] as String,
      ownerPhone: json['ownerPhone'] as String,
      ownerAvatarUrl: json['ownerAvatarUrl'] as String? ?? '',
      leaseStart: json['leaseStart'] as String,
      leaseEnd: json['leaseEnd'] as String,
      imageUrl: json['imageUrl'] as String,
      isRentDue: json['isRentDue'] as bool,
    );
  }
}
