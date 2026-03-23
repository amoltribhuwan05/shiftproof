import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftproof/core/utils/currency_formatter.dart';
import 'package:shiftproof/data/models/models.dart';
import 'package:shiftproof/providers/dashboard_provider.dart';
import 'package:shiftproof/services/auth_service.dart';
import 'package:shiftproof/services/notification_service.dart';
import 'package:shiftproof/services/payment_service.dart';
import 'package:shiftproof/services/payout_service.dart';
import 'package:shiftproof/services/plan_service.dart';
import 'package:shiftproof/services/profile_service.dart';
import 'package:shiftproof/services/property_service.dart';
import 'package:shiftproof/services/report_service.dart';
import 'package:shiftproof/services/room_service.dart';
import 'package:shiftproof/services/tenant_service.dart';

// ─── Service singletons ───────────────────────────────────────────────────────

final authServiceProvider = Provider<AuthService>((ref) => AuthService.instance);
final profileServiceProvider = Provider<ProfileService>((ref) => ProfileService.instance);
final propertyServiceProvider = Provider<PropertyService>((ref) => PropertyService());
final paymentServiceProvider = Provider<PaymentService>((ref) => PaymentService());
final payoutServiceProvider = Provider<PayoutService>((ref) => PayoutService());
final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService());
final planServiceProvider = Provider<PlanService>((ref) => PlanService());
final tenantServiceProvider = Provider<TenantService>((ref) => TenantService());
final roomServiceProvider = Provider<RoomService>((ref) => RoomService());
final reportServiceProvider = Provider<ReportService>((ref) => ReportService());

// ─── Data providers ───────────────────────────────────────────────────────────

/// Owner's property list — used by MyPropertiesScreen (S09) and FindPgScreen (S22).
/// Fetches all pages so the full list is returned regardless of backend page size.
final propertiesProvider = FutureProvider.autoDispose<List<Property>>((ref) async {
  final service = ref.read(propertyServiceProvider);
  final first = await service.listProperties(page: 0);
  final totalPages = first.meta?.totalPages ?? 1;
  if (totalPages <= 1) return first.data;

  final all = List<Property>.from(first.data);
  for (var page = 1; page < totalPages; page++) {
    final result = await service.listProperties(page: page);
    all.addAll(result.data);
  }
  return all;
});

/// Tenant's payment history — used by PaymentHistoryScreen (S25).
final paymentHistoryProvider = FutureProvider.autoDispose<List<Payment>>((ref) async {
  final result = await ref.read(paymentServiceProvider).listPayments();
  return result.data;
});

/// Owner's rent collections — used by CollectionsScreen (S14).
final collectionsProvider = FutureProvider.autoDispose<List<Payment>>((ref) async {
  final result = await ref.read(paymentServiceProvider).getCollections();
  return result.data;
});

/// Payment summary stats — used by CollectionsScreen (S14) and Owner Dashboard (S08).
final paymentSummaryProvider = FutureProvider.autoDispose<PaymentSummary>((ref) async {
  return ref.read(paymentServiceProvider).getPaymentSummary();
});

/// Owner's payouts — used by PayoutsScreen (S15).
final payoutsProvider = FutureProvider.autoDispose<List<Payout>>((ref) async {
  final result = await ref.read(payoutServiceProvider).listPayouts();
  return result.data;
});

/// Notifications list — used by NotificationsScreen (S18/S26).
final notificationsProvider = FutureProvider.autoDispose<List<AppNotification>>((ref) async {
  final result = await ref.read(notificationServiceProvider).listNotifications();
  return result.data;
});

/// Plans list — used by OwnerPlansScreen (S17).
final plansProvider = FutureProvider.autoDispose<List<Plan>>((ref) async {
  return ref.read(planServiceProvider).listPlans();
});

/// Tenants for a specific property — used by ManageTenantsScreen (S13).
/// Pass an empty string to skip the API call and return [].
final tenantsProvider =
    FutureProvider.autoDispose.family<List<Tenant>, String>((ref, propertyId) async {
  if (propertyId.isEmpty) return [];
  final result =
      await ref.read(tenantServiceProvider).listTenants(propertyId: propertyId);
  return result.data;
});

/// Current tenant's stay info — used by TenantDashboardScreen (S21).
final currentStayProvider = FutureProvider.autoDispose<CurrentStay?>((ref) async {
  return ref.read(authServiceProvider).getCurrentStay();
});

/// Rooms for a specific property — used by RoomBedSetupScreen (S12).
/// Pass an empty string to skip the API call and return [].
final roomsProvider =
    FutureProvider.autoDispose.family<List<Room>, String>((ref, propertyId) async {
  if (propertyId.isEmpty) return [];
  return ref.read(roomServiceProvider).listRooms(propertyId: propertyId);
});

/// Single property by ID — used by PropertyDetailsScreen (S11).
/// Pass an empty string to skip the API call and return null.
final propertyByIdProvider =
    FutureProvider.autoDispose.family<Property?, String>((ref, id) async {
  if (id.isEmpty) return null;
  return ref.read(propertyServiceProvider).getProperty(id);
});

/// Dashboard aggregate stats — used by PropertyDashboardScreen (S08).
/// Composes paymentSummary + properties to avoid a separate dashboard endpoint.
final dashboardStatsProvider = FutureProvider.autoDispose<DashboardStats>((ref) async {
  final summary = await ref.watch(paymentSummaryProvider.future);
  final properties = await ref.watch(propertiesProvider.future);
  return DashboardStats(
    totalTenants: summary.totalTenants ?? 0,
    totalProperties: properties.length,
    collected: CurrencyFormatter.format(summary.totalCollectedThisMonth ?? 0),
    pending: CurrencyFormatter.format(summary.pendingAmount ?? 0),
  );
});
