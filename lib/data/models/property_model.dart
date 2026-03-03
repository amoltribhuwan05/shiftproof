class Property {
  final String id;
  final String title;
  final String location;
  final String type; // 'PG', 'Flat', 'House'
  final String price;
  final String deposit;
  final String rating;
  final String imageUrl;
  final int totalRooms;
  final int occupiedRooms;
  final String description;
  final List<String> amenities;
  final String ownerName;
  final String ownerAvatarUrl;

  const Property({
    required this.id,
    required this.title,
    required this.location,
    required this.type,
    required this.price,
    required this.deposit,
    required this.rating,
    required this.imageUrl,
    required this.totalRooms,
    required this.occupiedRooms,
    required this.description,
    required this.amenities,
    required this.ownerName,
    required this.ownerAvatarUrl,
  });

  int get availableRooms => totalRooms - occupiedRooms;

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] as String,
      title: json['title'] as String,
      location: json['location'] as String,
      type: json['type'] as String,
      price: json['price'] as String,
      deposit: json['deposit'] as String,
      rating: json['rating'] as String,
      imageUrl: json['imageUrl'] as String,
      totalRooms: json['totalRooms'] as int,
      occupiedRooms: json['occupiedRooms'] as int,
      description: json['description'] as String,
      amenities: List<String>.from(json['amenities'] as List),
      ownerName: json['ownerName'] as String,
      ownerAvatarUrl: json['ownerAvatarUrl'] as String,
    );
  }
}
