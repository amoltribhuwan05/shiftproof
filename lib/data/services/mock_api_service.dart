import '../mock_api.dart';
import '../models/property_model.dart';
import '../models/tenant_model.dart';
import '../models/payment_model.dart';
import '../models/notification_model.dart';
import '../models/user_model.dart';

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

  // Dashboard summary
  static String getTotalCollectedThisMonth() {
    final paid = getPayments()
        .where((p) => p.status == 'paid' && p.date.contains('Mar 2026'))
        .map((p) => _parseAmount(p.amount))
        .fold(0, (a, b) => a + b);
    return '₹${_formatAmount(paid)}';
  }

  static String getPendingAmount() {
    final pending = getPayments()
        .where((p) => p.status == 'pending' || p.status == 'overdue')
        .map((p) => _parseAmount(p.amount))
        .fold(0, (a, b) => a + b);
    return '₹${_formatAmount(pending)}';
  }

  // ─── Payouts ─────────────────────────────────────────────
  static List<Payout> getPayouts() =>
      MockApi.payouts.map(Payout.fromJson).toList();

  static String getTotalSettled() {
    final settled = getPayouts()
        .where(
          (p) =>
              p.status.toLowerCase() == 'completed' ||
              p.status.toLowerCase() == 'success',
        )
        .map((p) => _parseAmount(p.amount))
        .fold(0, (a, b) => a + b);
    return '₹${_formatAmount(settled)}';
  }

  // ─── Notifications ───────────────────────────────────────
  static List<AppNotification> getNotifications() =>
      MockApi.notifications.map(AppNotification.fromJson).toList();

  static int getUnreadCount() =>
      getNotifications().where((n) => !n.isRead).length;

  // ─── Helpers ─────────────────────────────────────────────
  static int _parseAmount(String amount) {
    return int.tryParse(
          amount.replaceAll('₹', '').replaceAll(',', '').trim(),
        ) ??
        0;
  }

  static String _formatAmount(int amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      final s = amount.toString();
      return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
    }
    return amount.toString();
  }
}
