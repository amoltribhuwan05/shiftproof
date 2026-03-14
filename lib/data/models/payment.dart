class Payment {
  final String? id;
  final int? amount;
  final String? date;
  final String? description;
  final String? propertyId;
  final String? status;
  final String? tenantName;
  final String? title;
  final String? type;

  const Payment({
    this.id,
    this.amount,
    this.date,
    this.description,
    this.propertyId,
    this.status,
    this.tenantName,
    this.title,
    this.type,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String?,
      amount: json['amount'] as int?,
      date: json['date'] as String?,
      description: json['description'] as String?,
      propertyId: json['propertyId'] as String?,
      status: json['status'] as String?,
      tenantName: json['tenantName'] as String?,
      title: json['title'] as String?,
      type: json['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
      if (description != null) 'description': description,
      if (propertyId != null) 'propertyId': propertyId,
      if (status != null) 'status': status,
      if (tenantName != null) 'tenantName': tenantName,
      if (title != null) 'title': title,
      if (type != null) 'type': type,
    };
  }
}

class PaymentSummary {
  final int? overdueTenants;
  final int? pendingAmount;
  final int? totalCollectedThisMonth;
  final int? totalTenants;

  const PaymentSummary({
    this.overdueTenants,
    this.pendingAmount,
    this.totalCollectedThisMonth,
    this.totalTenants,
  });

  factory PaymentSummary.fromJson(Map<String, dynamic> json) {
    return PaymentSummary(
      overdueTenants: json['overdueTenants'] as int?,
      pendingAmount: json['pendingAmount'] as int?,
      totalCollectedThisMonth: json['totalCollectedThisMonth'] as int?,
      totalTenants: json['totalTenants'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (overdueTenants != null) 'overdueTenants': overdueTenants,
      if (pendingAmount != null) 'pendingAmount': pendingAmount,
      if (totalCollectedThisMonth != null) 'totalCollectedThisMonth': totalCollectedThisMonth,
      if (totalTenants != null) 'totalTenants': totalTenants,
    };
  }
}

class CreatePaymentRequest {
  final int amount;
  final String propertyId;
  final String title;
  final String type;
  final String? description;

  const CreatePaymentRequest({
    required this.amount,
    required this.propertyId,
    required this.title,
    required this.type,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'propertyId': propertyId,
      'title': title,
      'type': type,
      if (description != null) 'description': description,
    };
  }
}
