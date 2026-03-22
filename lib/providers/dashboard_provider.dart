/// Dashboard statistics model used by PropertyDashboardScreen.
/// The dashboardStatsProvider is defined in service_providers.dart,
/// composed from paymentSummaryProvider and propertiesProvider.
class DashboardStats {
  DashboardStats({
    required this.totalTenants,
    required this.totalProperties,
    required this.collected,
    required this.pending,
  });

  final int totalTenants;
  final int totalProperties;

  /// Formatted string, e.g. "₹1,20,000"
  final String collected;

  /// Formatted string, e.g. "₹30,000"
  final String pending;
}
