class Payout {
  const Payout({
    this.id,
    this.amount,
    this.bankLast4,
    this.date,
    this.description,
    this.propertyTitle,
    this.status,
  });

  factory Payout.fromJson(Map<String, dynamic> json) {
    return Payout(
      id: json['id'] as String?,
      amount: json['amount'] as int?,
      bankLast4: json['bankLast4'] as String?,
      date: json['date'] as String?,
      description: json['description'] as String?,
      propertyTitle: json['propertyTitle'] as String?,
      status: json['status'] as String?,
    );
  }
  final String? id;
  final int? amount;
  final String? bankLast4;
  final String? date;
  final String? description;
  final String? propertyTitle;
  final String? status;

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (bankLast4 != null) 'bankLast4': bankLast4,
      if (date != null) 'date': date,
      if (description != null) 'description': description,
      if (propertyTitle != null) 'propertyTitle': propertyTitle,
      if (status != null) 'status': status,
    };
  }
}
