import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shiftproof/data/services/mock_api_service.dart';

part 'dashboard_provider.g.dart';

class DashboardStats {
  DashboardStats({
    required this.totalTenants,
    required this.totalProperties,
    required this.collected,
    required this.pending,
  });
  final int totalTenants;
  final int totalProperties;
  final String collected;
  final String pending;
}

@riverpod
DashboardStats dashboardStats(DashboardStatsRef ref) {
  return DashboardStats(
    totalTenants: MockApiService.getTotalTenants(),
    totalProperties: MockApiService.getProperties().length,
    collected: MockApiService.getTotalCollectedThisMonth(),
    pending: MockApiService.getPendingAmount(),
  );
}
