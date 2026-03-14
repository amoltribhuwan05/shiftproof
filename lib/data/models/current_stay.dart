class CurrentStay {
  const CurrentStay({
    this.address,
    this.dueDate,
    this.imageUrl,
    this.isRentDue,
    this.leaseEnd,
    this.leaseStart,
    this.ownerAvatarUrl,
    this.ownerName,
    this.ownerPhone,
    this.propertyName,
    this.rentAmount,
    this.roomNumber,
  });

  factory CurrentStay.fromJson(Map<String, dynamic> json) {
    return CurrentStay(
      address: json['address'] as String?,
      dueDate: json['dueDate'] as String?,
      imageUrl: json['imageUrl'] as String?,
      isRentDue: json['isRentDue'] as bool?,
      leaseEnd: json['leaseEnd'] as String?,
      leaseStart: json['leaseStart'] as String?,
      ownerAvatarUrl: json['ownerAvatarUrl'] as String?,
      ownerName: json['ownerName'] as String?,
      ownerPhone: json['ownerPhone'] as String?,
      propertyName: json['propertyName'] as String?,
      rentAmount: json['rentAmount'] as int?,
      roomNumber: json['roomNumber'] as String?,
    );
  }
  final String? address;
  final String? dueDate;
  final String? imageUrl;
  final bool? isRentDue;
  final String? leaseEnd;
  final String? leaseStart;
  final String? ownerAvatarUrl;
  final String? ownerName;
  final String? ownerPhone;
  final String? propertyName;
  final int? rentAmount;
  final String? roomNumber;

  Map<String, dynamic> toJson() {
    return {
      if (address != null) 'address': address,
      if (dueDate != null) 'dueDate': dueDate,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (isRentDue != null) 'isRentDue': isRentDue,
      if (leaseEnd != null) 'leaseEnd': leaseEnd,
      if (leaseStart != null) 'leaseStart': leaseStart,
      if (ownerAvatarUrl != null) 'ownerAvatarUrl': ownerAvatarUrl,
      if (ownerName != null) 'ownerName': ownerName,
      if (ownerPhone != null) 'ownerPhone': ownerPhone,
      if (propertyName != null) 'propertyName': propertyName,
      if (rentAmount != null) 'rentAmount': rentAmount,
      if (roomNumber != null) 'roomNumber': roomNumber,
    };
  }
}
