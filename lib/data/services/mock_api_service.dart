import '../mock_api.dart';
import '../models/property_model.dart';
import '../models/tenant_model.dart';
import '../models/payment_model.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';
import '../../core/utils/currency_formatter.dart';

/// Mock API service — all data comes from MockApi (mock_api.dart).
/// To switch to a real backend: replace each method body with an
/// HTTP call and deserialize the JSON response using the same
/// fromJson constructors.
class MockApiService {
  // ─── User ───────────────────────────────────────────────
  static AppUser getCurrentOwner() => AppUser.fromJson(MockApi.currentOwner);

  static AppUser getCurrentTenant() => AppUser.fromJson(MockApi.currentTenant);

  // ─── Current Tenant Stay ────────────────────────────────
  static CurrentStay getCurrentStay() =>
      CurrentStay.fromJson(MockApi.currentStay);

  // ─── Properties ─────────────────────────────────────────
  static List<Property> getProperties() =>
      MockApi.properties.map(Property.fromJson).toList();

  static Property? getPropertyById(String id) {
    try {
      return getProperties().firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // ─── Tenants ─────────────────────────────────────────────
  static List<Tenant> getTenants() =>
      MockApi.tenants.map(Tenant.fromJson).toList();

  static List<Tenant> getTenantsByProperty(String propertyId) =>
      getTenants().where((t) => t.propertyId == propertyId).toList();

  // Dashboard stats
  static int getTotalTenants() => getTenants().length;
  static int getOverdueTenants() =>
      getTenants().where((t) => t.status == 'overdue').length;

  // ─── Payments ────────────────────────────────────────────
  static List<Payment> getPayments() =>
      MockApi.payments.map(Payment.fromJson).toList();

  static List<Payment> getTenantPayments() => getPayments()
      .where((p) => p.tenantName == MockApi.currentTenant['name'])
      .toList();

  static List<Payment> getCollections() =>
      getPayments().where((p) => p.type == 'rent').toList();

  // Dashboard summary — returns int for clean arithmetic
  static int getTotalCollectedThisMonthRaw() {
    return getPayments()
        .where((p) => p.status == 'paid' && p.date.contains('Mar 2026'))
        .fold(0, (sum, p) => sum + p.amount);
  }

  static int getPendingAmountRaw() {
    return getPayments()
        .where((p) => p.status == 'pending' || p.status == 'overdue')
        .fold(0, (sum, p) => sum + p.amount);
  }

  // Formatted versions for backwards-compatible display use
  static String getTotalCollectedThisMonth() =>
      CurrencyFormatter.format(getTotalCollectedThisMonthRaw());

  static String getPendingAmount() =>
      CurrencyFormatter.format(getPendingAmountRaw());

  // ─── Payouts ─────────────────────────────────────────────
  static List<Payout> getPayouts() =>
      MockApi.payouts.map(Payout.fromJson).toList();

  static int getTotalSettledRaw() {
    return getPayouts()
        .where(
          (p) =>
              p.status.toLowerCase() == 'completed' ||
              p.status.toLowerCase() == 'success',
        )
        .fold(0, (sum, p) => sum + p.amount);
  }

  static String getTotalSettled() =>
      CurrencyFormatter.format(getTotalSettledRaw());

  // ─── Notifications ───────────────────────────────────────
  static List<AppNotification> getNotifications() =>
      MockApi.notifications.map(AppNotification.fromJson).toList();

  static int getUnreadCount() =>
      getNotifications().where((n) => !n.isRead).length;
}
