class Payment {
  final String id;
  final String title;
  final String amount;
  final String date;
  final String status; // 'paid', 'pending', 'overdue'
  final String type; // 'rent', 'deposit', 'maintenance', 'electricity'
  final String tenantName;
  final String propertyId;
  final String description;

  const Payment({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.status,
    required this.type,
    required this.tenantName,
    required this.propertyId,
    required this.description,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: json['amount'] as String,
      date: json['date'] as String,
      status: json['status'] as String,
      type: json['type'] as String,
      tenantName: json['tenantName'] as String,
      propertyId: json['propertyId'] as String,
      description: json['description'] as String,
    );
  }
}

class Payout {
  final String id;
  final String amount;
  final String date;
  final String status; // 'completed', 'processing', 'failed'
  final String bankLast4;
  final String propertyTitle;
  final String description;

  const Payout({
    required this.id,
    required this.amount,
    required this.date,
    required this.status,
    required this.bankLast4,
    required this.propertyTitle,
    required this.description,
  });

  factory Payout.fromJson(Map<String, dynamic> json) {
    return Payout(
      id: json['id'] as String,
      amount: json['amount'] as String,
      date: json['date'] as String,
      status: json['status'] as String,
      bankLast4: json['bankLast4'] as String,
      propertyTitle: json['propertyTitle'] as String,
      description: json['description'] as String,
    );
  }
}
