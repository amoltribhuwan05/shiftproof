class Property {
  final String? id;
  final List<String>? amenities;
  final int? deposit;
  final String? description;
  final String? imageUrl;
  final String? location;
  final int? occupiedRooms;
  final String? ownerAvatarUrl;
  final String? ownerName;
  final int? price;
  final double? rating;
  final String? title;
  final int? totalRooms;
  final String? type;

  const Property({
    this.id,
    this.amenities,
    this.deposit,
    this.description,
    this.imageUrl,
    this.location,
    this.occupiedRooms,
    this.ownerAvatarUrl,
    this.ownerName,
    this.price,
    this.rating,
    this.title,
    this.totalRooms,
    this.type,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] as String?,
      amenities: (json['amenities'] as List<dynamic>?)?.map((e) => e as String).toList(),
      deposit: json['deposit'] as int?,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      location: json['location'] as String?,
      occupiedRooms: json['occupiedRooms'] as int?,
      ownerAvatarUrl: json['ownerAvatarUrl'] as String?,
      ownerName: json['ownerName'] as String?,
      price: json['price'] as int?,
      rating: (json['rating'] as num?)?.toDouble(),
      title: json['title'] as String?,
      totalRooms: json['totalRooms'] as int?,
      type: json['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (amenities != null) 'amenities': amenities,
      if (deposit != null) 'deposit': deposit,
      if (description != null) 'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (location != null) 'location': location,
      if (occupiedRooms != null) 'occupiedRooms': occupiedRooms,
      if (ownerAvatarUrl != null) 'ownerAvatarUrl': ownerAvatarUrl,
      if (ownerName != null) 'ownerName': ownerName,
      if (price != null) 'price': price,
      if (rating != null) 'rating': rating,
      if (title != null) 'title': title,
      if (totalRooms != null) 'totalRooms': totalRooms,
      if (type != null) 'type': type,
    };
  }
}

class CreatePropertyRequest {
  final String location;
  final int price;
  final String title;
  final String type;
  final List<String>? amenities;
  final int? deposit;
  final String? description;
  final int? totalRooms;

  const CreatePropertyRequest({
    required this.location,
    required this.price,
    required this.title,
    required this.type,
    this.amenities,
    this.deposit,
    this.description,
    this.totalRooms,
  });

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'price': price,
      'title': title,
      'type': type,
      if (amenities != null) 'amenities': amenities,
      if (deposit != null) 'deposit': deposit,
      if (description != null) 'description': description,
      if (totalRooms != null) 'totalRooms': totalRooms,
    };
  }
}
