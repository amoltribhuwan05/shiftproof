class Property {
  final String id;
  final String title;
  final String location;

  /// Property category: 'PG' | 'Flat' | 'House'
  final String type;

  /// Monthly rent per room/bed in rupees (integer). Use CurrencyFormatter.format() for display.
  final int price;

  /// Security deposit in rupees (integer). Use CurrencyFormatter.format() for display.
  final int deposit;

  /// Average star rating. Stored as double for sorting and averaging calculations.
  final double rating;

  final String imageUrl;

  /// Total count of rooms in the property.
  final int totalRooms;

  /// Currently occupied rooms.
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

  /// Available rooms ready to rent.
  int get availableRooms => totalRooms - occupiedRooms;

  /// Occupancy as a ratio between 0.0 and 1.0.
  double get occupancyRate =>
      totalRooms == 0 ? 0.0 : occupiedRooms / totalRooms;

  /// True when all rooms are occupied.
  bool get isFullyOccupied => availableRooms == 0;

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] as String,
      title: json['title'] as String,
      location: json['location'] as String,
      type: json['type'] as String,
      price: (json['price'] as num).toInt(),
      deposit: (json['deposit'] as num).toInt(),
      // Safe parse: API may send double (4.8) or string ("4.8")
      rating: double.tryParse(json['rating'].toString()) ?? 0.0,
      imageUrl: json['imageUrl'] as String,
      totalRooms: (json['totalRooms'] as num).toInt(),
      occupiedRooms: (json['occupiedRooms'] as num).toInt(),
      description: json['description'] as String,
      amenities: List<String>.from(json['amenities'] as List),
      ownerName: json['ownerName'] as String,
      ownerAvatarUrl: json['ownerAvatarUrl'] as String,
    );
  }
}
