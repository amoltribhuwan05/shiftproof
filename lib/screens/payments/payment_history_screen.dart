import 'package:flutter/material.dart';
import '../../widgets/buttons/notification_bell_button.dart';
import '../../data/services/mock_api_service.dart';
import '../../data/models/payment_model.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  Color _statusColor(String status) {
    switch (status) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.amber;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'rent':
        return Icons.home_outlined;
      case 'deposit':
        return Icons.lock_outlined;
      case 'electricity':
        return Icons.electric_bolt_outlined;
      case 'maintenance':
        return Icons.build_outlined;
      default:
        return Icons.receipt_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final payments = MockApiService.getTenantPayments();
    final paidPayments = payments.where((p) => p.status == 'paid').toList();
    final pendingPayments = payments
        .where((p) => p.status == 'pending' || p.status == 'overdue')
        .toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black87,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: Text(
          'Payment History',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          const NotificationBellButton(),
          IconButton(
            icon: Icon(
              Icons.search,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              labelColor: colorScheme.primary,
              unselectedLabelColor: isDark
                  ? Colors.grey.shade500
                  : Colors.grey.shade500,
              indicatorColor: colorScheme.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              tabs: [
                Tab(text: 'All (${payments.length})'),
                Tab(text: 'Paid (${paidPayments.length})'),
                Tab(text: 'Pending (${pendingPayments.length})'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildPaymentList(context, payments, isDark),
                  _buildPaymentList(context, paidPayments, isDark),
                  _buildPaymentList(context, pendingPayments, isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentList(
    BuildContext context,
    List<Payment> payments,
    bool isDark,
  ) {
    if (payments.isEmpty) {
      return const Center(child: Text('No payments found'));
    }
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: payments.length,
      itemBuilder: (context, index) =>
          _buildHistoryItem(context, payments[index], isDark),
    );
  }

  Widget _buildHistoryItem(BuildContext context, Payment payment, bool isDark) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColor = _statusColor(payment.status);
    final icon = _typeIcon(payment.type);

    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: colorScheme.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          payment.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.2),
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          payment.status.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        payment.amount,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Colors.grey.shade300
                              : Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• ${payment.date}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.grey.shade500
                              : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
