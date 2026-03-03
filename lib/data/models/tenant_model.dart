class Tenant {
  final String id;
  final String name;
  final String room;
  final String rentAmount;
  final String dueDate;
  final bool isPaid;
  final String avatarUrl;
  final String phone;
  final String email;
  final String joinDate;
  final String propertyId;
  final String status; // 'active', 'pending', 'overdue'

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
      id: json['id'] as String,
      name: json['name'] as String,
      room: json['room'] as String,
      rentAmount: json['rentAmount'] as String,
      dueDate: json['dueDate'] as String,
      isPaid: json['isPaid'] as bool,
      avatarUrl: json['avatarUrl'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      joinDate: json['joinDate'] as String,
      propertyId: json['propertyId'] as String,
      status: json['status'] as String,
    );
  }
}
