class AppUser {
  const AppUser({
    required this.id,
    this.avatarUrl,
    this.email,
    this.joinDate,
    this.location,
    this.name,
    this.phone,
    this.role,
    this.isOwner = false,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      email: json['email'] as String?,
      joinDate: json['joinDate'] as String?,
      location: json['location'] as String?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as String?,
      isOwner: json['isOwner'] as bool? ?? false,
    );
  }
  final String id;
  final String? avatarUrl;
  final String? email;
  final String? joinDate;
  final String? location;
  final String? name;
  final String? phone;
  final String? role;
  final bool isOwner;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (email != null) 'email': email,
      if (joinDate != null) 'joinDate': joinDate,
      if (location != null) 'location': location,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (role != null) 'role': role,
      'isOwner': isOwner,
    };
  }
}
