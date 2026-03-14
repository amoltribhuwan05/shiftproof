class Payment {
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
      amount: (json['amount'] as num).toInt(),
      date: json['date'] as String,
      status: json['status'] as String,
      type: json['type'] as String,
      tenantName: json['tenantName'] as String,
      propertyId: json['propertyId'] as String,
      description: json['description'] as String,
    );
  }
  final String id;
  final String title;

  /// Amount in rupees (integer). Use CurrencyFormatter.format() for display.
  final int amount;

  /// ISO 8601 date string (e.g. "2026-03-01"). Parse with DateTime.parse() for sorting/filtering.
  final String date;

  /// Payment status: 'paid' | 'pending' | 'overdue'
  final String status;

  /// Payment category: 'rent' | 'deposit' | 'maintenance' | 'electricity'
  final String type;

  final String tenantName;
  final String propertyId;
  final String description;

  bool get isPaid => status == 'paid';
  bool get isOverdue => status == 'overdue';
  bool get isPending => status == 'pending';
}

class Payout {
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
      amount: (json['amount'] as num).toInt(),
      date: json['date'] as String,
      status: json['status'] as String,
      bankLast4: json['bankLast4'] as String,
      propertyTitle: json['propertyTitle'] as String,
      description: json['description'] as String,
    );
  }
  final String id;

  /// Payout amount in rupees (integer). Use CurrencyFormatter.format() for display.
  final int amount;

  /// ISO 8601 date string (e.g. "2026-02-05"). Parse for sorting/filtering.
  final String date;

  /// Transfer status: 'completed' | 'processing' | 'failed'
  final String status;

  /// Last 4 digits of the destination bank account.
  final String bankLast4;

  final String propertyTitle;
  final String description;

  bool get isCompleted =>
      status.toLowerCase() == 'completed' || status.toLowerCase() == 'success';
}
