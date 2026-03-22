import 'package:shiftproof/data/api_client.dart';

/// Represents the aggregated report returned by GET /api/v1/reports/properties/{propertyId}.
class PropertyReport {
  const PropertyReport({
    required this.propertyId,
    required this.month,
    required this.totalCollected,
    required this.totalPending,
    required this.totalPayments,
    required this.paidCount,
    required this.pendingCount,
  });

  factory PropertyReport.fromJson(Map<String, dynamic> json) {
    return PropertyReport(
      propertyId: json['propertyId'] as String? ?? '',
      month: json['month'] as String? ?? '',
      totalCollected: (json['totalCollected'] as num?)?.toInt() ?? 0,
      totalPending: (json['totalPending'] as num?)?.toInt() ?? 0,
      totalPayments: (json['totalPayments'] as num?)?.toInt() ?? 0,
      paidCount: (json['paidCount'] as num?)?.toInt() ?? 0,
      pendingCount: (json['pendingCount'] as num?)?.toInt() ?? 0,
    );
  }

  final String propertyId;

  /// YYYY-MM format, e.g. "2026-03"
  final String month;
  final int totalCollected;
  final int totalPending;
  final int totalPayments;
  final int paidCount;
  final int pendingCount;
}

class ReportService {
  ReportService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient.instance;
  final ApiClient _apiClient;

  /// GET /api/v1/reports/properties/{propertyId}?month=YYYY-MM
  /// [month] defaults to current month on the backend when omitted.
  Future<PropertyReport> getPropertyReport(
    String propertyId, {
    String? month,
  }) async {
    final response = await _apiClient.dio.get<Map<String, dynamic>>(
      '/api/v1/reports/properties/$propertyId',
      queryParameters: {
        if (month != null) 'month': month,
      },
    );
    return PropertyReport.fromJson(response.data!);
  }
}
