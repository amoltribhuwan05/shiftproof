class Plan {
  final String? id;
  final List<String>? features;
  final bool? isCurrent;
  final bool? isPopular;
  final int? maxProperties;
  final int? maxTenants;
  final String? name;
  final int? price;

  const Plan({
    this.id,
    this.features,
    this.isCurrent,
    this.isPopular,
    this.maxProperties,
    this.maxTenants,
    this.name,
    this.price,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'] as String?,
      features: (json['features'] as List<dynamic>?)?.map((e) => e as String).toList(),
      isCurrent: json['isCurrent'] as bool?,
      isPopular: json['isPopular'] as bool?,
      maxProperties: json['maxProperties'] as int?,
      maxTenants: json['maxTenants'] as int?,
      name: json['name'] as String?,
      price: json['price'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (features != null) 'features': features,
      if (isCurrent != null) 'isCurrent': isCurrent,
      if (isPopular != null) 'isPopular': isPopular,
      if (maxProperties != null) 'maxProperties': maxProperties,
      if (maxTenants != null) 'maxTenants': maxTenants,
      if (name != null) 'name': name,
      if (price != null) 'price': price,
    };
  }
}
