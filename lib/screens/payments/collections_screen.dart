import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftproof/core/utils/currency_formatter.dart';
import 'package:shiftproof/providers/service_providers.dart';
import 'package:shiftproof/widgets/buttons/filter_chip_widget.dart';
import 'package:shiftproof/widgets/buttons/notification_bell_button.dart';
import 'package:shiftproof/widgets/cards/progress_row_widget.dart';
import 'package:shiftproof/widgets/cards/tenant_payment_row.dart';

class CollectionsScreen extends ConsumerWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final collectionsAsync = ref.watch(collectionsProvider);
    final summaryAsync = ref.watch(paymentSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primary),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: Text(
          'Collections',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          const NotificationBellButton(),
          IconButton(
            icon: Icon(Icons.search, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            onPressed: () {},
          ),
        ],
      ),
      body: collectionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
              const SizedBox(height: 16),
              const Text('Failed to load collections'),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  ref
                    ..invalidate(collectionsProvider)
                    ..invalidate(paymentSummaryProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (collections) {
          final totalCollected = summaryAsync.valueOrNull?.totalCollectedThisMonth ?? 0;

          // Compute payment method breakdown from real data
          final upiCount = collections.where((p) => p.type?.toLowerCase() == 'upi').length;
          final cashCount = collections.where((p) => p.type?.toLowerCase() == 'cash').length;
          final total = collections.length;
          final upiRatio = total > 0 ? upiCount / total : 0.6;
          final cashRatio = total > 0 ? cashCount / total : 0.3;
          final cardRatio = total > 0 ? (total - upiCount - cashCount) / total : 0.1;

          return SingleChildScrollView(
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
                      color: primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.3),
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
                            color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
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
                              CurrencyFormatter.format(totalCollected),
                              style: TextStyle(
                                color: theme.colorScheme.onPrimary,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${collections.length} payments',
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
                          Icon(Icons.payments, color: primary, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Payment Method Summary',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.05),
                          border: Border.all(color: primary.withValues(alpha: 0.1)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            ProgressRowWidget(
                              label: 'UPI',
                              valueLabel: '${(upiRatio * 100).round()}%',
                              value: upiRatio,
                              color: primary,
                            ),
                            const SizedBox(height: 12),
                            ProgressRowWidget(
                              label: 'Cash',
                              valueLabel: '${(cashRatio * 100).round()}%',
                              value: cashRatio,
                              color: primary.withValues(alpha: 0.7),
                            ),
                            const SizedBox(height: 12),
                            ProgressRowWidget(
                              label: 'Card',
                              valueLabel: '${(cardRatio * 100).round()}%',
                              value: cardRatio,
                              color: primary.withValues(alpha: 0.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Breakdown by Tenant
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.group, color: primary, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Breakdown by Tenant',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Text(
                            'View All',
                            style: TextStyle(
                              color: primary,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (collections.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(child: Text('No collections this month')),
                        )
                      else
                        ...collections.take(5).map((payment) {
                          final isPaid = payment.status?.toLowerCase() == 'paid';
                          final initials = (payment.tenantName ?? 'UN')
                              .substring(0, (payment.tenantName?.length ?? 0) >= 2 ? 2 : 1)
                              .toUpperCase();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TenantPaymentRow(
                              initials: initials,
                              name: payment.tenantName ?? 'Unknown',
                              subtitle: '${payment.type ?? 'Payment'} • ${payment.date ?? ''}',
                              amount: CurrencyFormatter.format(payment.amount ?? 0),
                              status: payment.status ?? 'pending',
                              statusColor: isPaid
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF59E0B),
                              customPrimary: primary,
                            ),
                          );
                        }),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}
