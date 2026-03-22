class Room {
  const Room({
    this.id,
    this.roomNumber,
    this.type,
    this.capacity,
    this.occupiedBeds,
    this.propertyId,
    this.rentAmount,
    this.deposit,
    this.isAvailable,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as String?,
      roomNumber: json['roomNumber'] as String?,
      type: json['type'] as String?,
      capacity: json['capacity'] as int?,
      occupiedBeds: json['occupiedBeds'] as int?,
      propertyId: json['propertyId'] as String?,
      rentAmount: json['rentAmount'] as int?,
      deposit: json['deposit'] as int?,
      isAvailable: json['isAvailable'] as bool?,
    );
  }

  final String? id;
  final String? roomNumber;

  /// "single" | "double" | "triple"
  final String? type;
  final int? capacity;
  final int? occupiedBeds;
  final String? propertyId;
  final int? rentAmount;
  final int? deposit;
  final bool? isAvailable;

  int get availableBeds => (capacity ?? 0) - (occupiedBeds ?? 0);

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (roomNumber != null) 'roomNumber': roomNumber,
      if (type != null) 'type': type,
      if (capacity != null) 'capacity': capacity,
      if (occupiedBeds != null) 'occupiedBeds': occupiedBeds,
      if (propertyId != null) 'propertyId': propertyId,
      if (rentAmount != null) 'rentAmount': rentAmount,
      if (deposit != null) 'deposit': deposit,
      if (isAvailable != null) 'isAvailable': isAvailable,
    };
  }
}

class CreateRoomRequest {
  const CreateRoomRequest({
    required this.roomNumber,
    required this.capacity,
    required this.type,
    required this.rentAmount,
    this.deposit,
  });

  final String roomNumber;
  final int capacity;

  /// "single" | "double" | "triple"
  final String type;
  final int rentAmount;
  final int? deposit;

  Map<String, dynamic> toJson() {
    return {
      'roomNumber': roomNumber,
      'capacity': capacity,
      'type': type,
      'rentAmount': rentAmount,
      if (deposit != null) 'deposit': deposit,
    };
  }
}

class UpdateRoomRequest {
  const UpdateRoomRequest({
    this.roomNumber,
    this.capacity,
    this.rentAmount,
    this.deposit,
  });

  final String? roomNumber;
  final int? capacity;
  final int? rentAmount;
  final int? deposit;

  Map<String, dynamic> toJson() {
    return {
      if (roomNumber != null) 'roomNumber': roomNumber,
      if (capacity != null) 'capacity': capacity,
      if (rentAmount != null) 'rentAmount': rentAmount,
      if (deposit != null) 'deposit': deposit,
    };
  }
}
