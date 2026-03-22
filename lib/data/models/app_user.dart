class AppUser {
  const AppUser({
    required this.id,
    this.name,
    this.gender,
    this.roles = const [],
    this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.city,
    this.area,
    this.profileCompleted = false,
    this.authIdentifier,
    this.createdAt,
    this.updatedAt,
    this.providers = const [],
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    // Swagger returns `role` (string) — tolerate both `roles` array and `role` string.
    List<String> parseRoles() {
      if (json['roles'] is List) {
        return (json['roles'] as List<dynamic>).map((e) => e as String).toList();
      }
      final role = json['role'] as String?;
      if (role != null && role.isNotEmpty) return [role];
      return const [];
    }

    return AppUser(
      id: json['id'] as String,
      name: json['name'] as String?,
      gender: json['gender'] as String?,
      roles: parseRoles(),
      email: json['email'] as String?,
      // Swagger uses `phone`; future backend may use `phoneNumber` — accept both.
      phoneNumber: (json['phoneNumber'] ?? json['phone']) as String?,
      avatarUrl: json['avatarUrl'] as String?,
      // Swagger uses `location` (single string); local model splits into city/area.
      city: (json['city'] ?? json['location']) as String?,
      area: json['area'] as String?,
      profileCompleted: json['profileCompleted'] as bool? ?? false,
      authIdentifier: json['authIdentifier'] as String?,
      createdAt: (json['createdAt'] ?? json['joinDate']) as String?,
      updatedAt: json['updatedAt'] as String?,
      providers: (json['providers'] is List)
              ? (json['providers'] as List<dynamic>)
                  .map((e) => e as String)
                  .toList()
              : const [],
    );
  }
  final String id;
  final String? name;
  final String? gender;
  final List<String> roles;
  final String? email;
  final String? phoneNumber;
  final String? avatarUrl;
  final String? city;
  final String? area;
  final bool profileCompleted;
  final String? authIdentifier;
  final String? createdAt;
  final String? updatedAt;
  final List<String> providers;

  bool get isOwner => roles.contains('OWNER');
  bool get isTenant => roles.contains('TENANT');

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'roles': roles,
      'email': email,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'city': city,
      'area': area,
      'profileCompleted': profileCompleted,
      'authIdentifier': authIdentifier,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'providers': providers,
    };
  }

  AppUser copyWith({
    String? id,
    String? name,
    String? gender,
    List<String>? roles,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    String? city,
    String? area,
    bool? profileCompleted,
    String? authIdentifier,
    String? createdAt,
    String? updatedAt,
    List<String>? providers,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      roles: roles ?? this.roles,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      city: city ?? this.city,
      area: area ?? this.area,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      authIdentifier: authIdentifier ?? this.authIdentifier,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      providers: providers ?? this.providers,
    );
  }
}
