import 'package:flutter/material.dart';
import 'package:shiftproof/core/utils/currency_formatter.dart';
import 'package:shiftproof/data/services/mock_api_service.dart';
import 'package:shiftproof/widgets/buttons/notification_bell_button.dart';
import 'package:shiftproof/widgets/cards/payout_item.dart';

class PayoutsScreen extends StatelessWidget {
  const PayoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Note: The design uses a specific primary color (orange: #ec5b13) for this owner screen.
    // We will apply this specific styling here.
    final theme = Theme.of(context);
    final customPrimary = theme.colorScheme.primary;

    final payouts = MockApiService.getPayouts();
    final totalSettled = MockApiService.getTotalSettled();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: Text(
          'Payouts',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          const NotificationBellButton(),
          IconButton(
            icon: Icon(Icons.filter_list, color: theme.colorScheme.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: customPrimary.withValues(alpha: 0.1),
                    border: Border.all(
                      color: customPrimary.withValues(alpha: 0.2),
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL SETTLED (30 DAYS)',
                        style: TextStyle(
                          color: customPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            totalSettled,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Row(
                            children: [
                              Icon(
                                Icons.trending_up,
                                color: Color(0xFF4CAF50), // semantic green
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '12%',
                                style: TextStyle(
                                  color: Color(0xFF4CAF50),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Section Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Payouts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Showing last 10 transactions',
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                ...payouts.take(10).map((payout) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Opacity(
                      opacity:
                          payout.status.toLowerCase() == 'completed' ||
                              payout.status.toLowerCase() == 'success'
                          ? 1.0
                          : 0.8,
                      child: PayoutItem(
                        ref: payout.id,
                        amount: CurrencyFormatter.format(payout.amount),
                        date: payout.date,
                        status: payout.status,
                        statusColor:
                            payout.status.toLowerCase() == 'completed' ||
                                payout.status.toLowerCase() == 'success'
                            ? const Color(0xFF4CAF50) // semantic green
                            : theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 100), // padding for bottom button
              ],
            ),
          ),

          // Bottom CTA
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: theme.scaffoldBackgroundColor,
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: customPrimary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      shadowColor: customPrimary.withValues(alpha: 0.4),
                    ),
                    onPressed: () {},
                    icon: const Icon(Icons.download),
                    label: const Text(
                      'Download Report',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
