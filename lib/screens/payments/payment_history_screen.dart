import 'package:flutter/material.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
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
          IconButton(
            icon: Icon(
              Icons.search,
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert,
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
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Paid'),
                Tab(text: 'Pending'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // All Tab
                  ListView(
                    children: [
                      _buildHistoryItem(
                        context,
                        month: 'October 2023',
                        amount: '\$17,000.00',
                        status: 'Paid',
                        statusColor: Colors.green,
                        iconColor: colorScheme.primary,
                        icon: Icons.calendar_today,
                      ),
                      _buildHistoryItem(
                        context,
                        month: 'September 2023',
                        amount: '\$17,000.00',
                        status: 'Pending',
                        statusColor: Colors.amber,
                        iconColor: Colors.amber,
                        icon: Icons.pending_actions,
                      ),
                      _buildHistoryItem(
                        context,
                        month: 'August 2023',
                        amount: '\$17,000.00',
                        status: 'Paid',
                        statusColor: Colors.green,
                        iconColor: colorScheme.primary,
                        icon: Icons.calendar_today,
                      ),
                      _buildHistoryItem(
                        context,
                        month: 'July 2023',
                        amount: '\$17,000.00',
                        status: 'Paid',
                        statusColor: Colors.green,
                        iconColor: colorScheme.primary,
                        icon: Icons.calendar_today,
                      ),
                      _buildHistoryItem(
                        context,
                        month: 'June 2023',
                        amount: '\$17,000.00',
                        status: 'Paid',
                        statusColor: Colors.green,
                        iconColor: colorScheme.primary,
                        icon: Icons.calendar_today,
                      ),
                    ],
                  ),

                  // Paid Tab
                  const Center(child: Text('Paid Payments')),

                  // Pending Tab
                  const Center(child: Text('Pending Payments')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(
    BuildContext context, {
    required String month,
    required String amount,
    required String status,
    required Color statusColor,
    required Color iconColor,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        month,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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
                          status.toUpperCase(),
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
                  Text(
                    amount,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
