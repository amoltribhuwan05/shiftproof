import 'package:flutter/material.dart';
import 'package:shiftproof/core/utils/currency_formatter.dart';
import 'package:shiftproof/data/services/mock_api_service.dart';
import 'package:shiftproof/widgets/buttons/filter_chip_widget.dart';
import 'package:shiftproof/widgets/buttons/notification_bell_button.dart';
import 'package:shiftproof/widgets/cards/progress_row_widget.dart';
import 'package:shiftproof/widgets/cards/tenant_payment_row.dart';

class CollectionsScreen extends StatelessWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customPrimary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    final collections = MockApiService.getPayments();
    final totalCollected = MockApiService.getTotalCollectedThisMonth();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: customPrimary),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: Text(
          'Collections',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          const NotificationBellButton(),
          IconButton(
            icon: Icon(
              Icons.search,
              color: isDark
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.7)
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: isDark
                  ? theme.colorScheme.onSurface.withValues(alpha: 0.7)
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Chips
            const SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  FilterChipWidget(label: 'Select Month'),
                  SizedBox(width: 12),
                  FilterChipWidget(label: 'Select Property'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Summary Hero Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: customPrimary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: customPrimary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MONTHLY SUMMARY',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary.withValues(
                          alpha: 0.8,
                        ),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total Collected',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          totalCollected,
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onPrimary.withValues(
                              alpha: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '+12% vs last month',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Payment Method Summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.payments, color: customPrimary, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Payment Method Summary',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: customPrimary.withValues(alpha: 0.05),
                      border: Border.all(
                        color: customPrimary.withValues(alpha: 0.1),
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        ProgressRowWidget(
                          label: 'UPI',
                          valueLabel: '60%',
                          value: 0.6,
                          color: customPrimary,
                        ),
                        const SizedBox(height: 12),
                        ProgressRowWidget(
                          label: 'Cash',
                          valueLabel: '30%',
                          value: 0.3,
                          color: customPrimary.withValues(alpha: 0.7),
                        ),
                        const SizedBox(height: 12),
                        ProgressRowWidget(
                          label: 'Card',
                          valueLabel: '10%',
                          value: 0.1,
                          color: customPrimary.withValues(alpha: 0.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Breakdown Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.group, color: customPrimary, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Breakdown by Tenant',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'View All',
                        style: TextStyle(
                          color: customPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  ...collections.take(5).map((payment) {
                    final isPaid = payment.status == 'Paid';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TenantPaymentRow(
                        initials: payment.tenantName
                            .substring(0, 2)
                            .toUpperCase(),
                        name: payment.tenantName,
                        subtitle: '${payment.type} • ${payment.date}',
                        amount: CurrencyFormatter.format(payment.amount),
                        status: payment.status,
                        statusColor: isPaid
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFFFC107),
                        customPrimary: customPrimary,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
