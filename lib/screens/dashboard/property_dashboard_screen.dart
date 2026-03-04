import 'package:flutter/material.dart';
import '../../widgets/buttons/notification_bell_button.dart';
import '../../data/services/mock_api_service.dart';

import '../properties/manage_tenants_screen.dart';
import '../../widgets/cards/stat_card.dart';
import '../../widgets/cards/action_card.dart';
import '../../widgets/cards/activity_item.dart';
import '../../widgets/cards/section_title.dart';
import '../../widgets/cards/custom_divider.dart';

class PropertyDashboardScreen extends StatelessWidget {
  const PropertyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final totalTenants = MockApiService.getTotalTenants();
    final totalProperties = MockApiService.getProperties().length;
    final collected = MockApiService.getTotalCollectedThisMonth();
    final pending = MockApiService.getPendingAmount();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            color: isDark ? colorScheme.onSurface : colorScheme.onSurface,
          ),
          onPressed: () {},
        ),
        title: Text(
          'Property Dashboard',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: isDark ? colorScheme.onSurface : colorScheme.onSurface,
            ),
            onPressed: () {},
          ),
          const NotificationBellButton(
            hasUnread: true,
            dotColor:
                Colors.redAccent, // Keep semantic red for alert specifically
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 8.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: colorScheme.primary,
              backgroundImage: const NetworkImage(
                'https://i.pravatar.cc/150?img=11',
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Stats Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SectionTitle(title: 'OVERVIEW'),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'View All',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 900
                    ? 4
                    : (MediaQuery.of(context).size.width > 600 ? 3 : 2),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  StatCard(
                    title: 'Total Tenants',
                    value: '$totalTenants',
                    icon: Icons.group_outlined,
                    trendIcon: Icons.trending_up,
                    trendValue: '12%',
                    isTrendPositive: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManageTenantsScreen(),
                        ),
                      );
                    },
                  ),
                  StatCard(
                    title: 'Properties',
                    value: '$totalProperties',
                    icon: Icons.bed_outlined,
                    trendIcon: Icons.trending_up,
                    trendValue: '5%',
                    isTrendPositive: true,
                  ),
                  StatCard(
                    title: 'Collected (Mar)',
                    value: collected,
                    icon: Icons.payments_outlined,
                    trendIcon: Icons.trending_up,
                    trendValue: '8%',
                    isTrendPositive: true,
                  ),
                  StatCard(
                    title: 'Pending',
                    value: pending,
                    icon: Icons.pending_actions_outlined,
                    trendIcon: Icons.trending_down,
                    trendValue: '15%',
                    isTrendPositive: false,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Quick Actions Section
              const SectionTitle(title: 'QUICK ACTIONS'),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 900
                    ? 4
                    : (MediaQuery.of(context).size.width > 600 ? 3 : 2),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  ActionCard(
                    title: 'Manage Tenants',
                    subtitle: 'Active & waitlist',
                    icon: Icons.person_add_outlined,
                    isPrimary: true,
                  ),
                  ActionCard(
                    title: 'View Payments',
                    subtitle: 'Transaction history',
                    icon: Icons.receipt_long_outlined,
                    isPrimary: false,
                  ),
                  ActionCard(
                    title: 'View Reports',
                    subtitle: 'Financial insights',
                    icon: Icons.analytics_outlined,
                    isPrimary: false,
                  ),
                  ActionCard(
                    title: 'Move-in/out',
                    subtitle: 'Create records',
                    icon: Icons.swap_horiz_outlined,
                    isPrimary: false,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Recent Activity Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SectionTitle(title: 'RECENT ACTIVITY'),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'View History',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? colorScheme.surface.withValues(alpha: 0.5)
                      : colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? colorScheme.primary.withValues(alpha: 0.1)
                        : colorScheme.onSurface.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  children: [
                    ActivityItem(
                      title: 'Payment Received from Unit 402',
                      subtitle: '10 minutes ago • \$1,250.00',
                      icon: Icons.check_circle_outline,
                      iconColor: const Color(0xFF4CAF50),
                      iconBgColor: const Color(
                        0xFF4CAF50,
                      ).withValues(alpha: 0.1),
                    ),
                    const CustomDivider(),
                    ActivityItem(
                      title: 'New Move-in: Jane Cooper',
                      subtitle: '2 hours ago • Unit 105',
                      icon: Icons.login_outlined,
                      iconColor: colorScheme.primary,
                      iconBgColor: colorScheme.primary.withValues(alpha: 0.1),
                    ),
                    const CustomDivider(),
                    ActivityItem(
                      title: 'Maintenance Request: Leak in Kitchen',
                      subtitle: 'Yesterday • Unit 203',
                      icon: Icons.report_problem_outlined,
                      iconColor: Colors.orange, // Semantic color for warning
                      iconBgColor: Colors.orange.withValues(alpha: 0.1),
                    ),
                    const CustomDivider(),
                    ActivityItem(
                      title: 'Move-out Record: Robert Fox',
                      subtitle: 'Oct 24, 2023 • Unit 312',
                      icon: Icons.logout_outlined,
                      iconColor: theme.colorScheme.onSurface.withValues(
                        alpha: 0.5,
                      ),
                      iconBgColor: theme.colorScheme.onSurface.withValues(
                        alpha: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80), // Padding for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'property_dashboard_fab',
        onPressed: () {},
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add),
      ),
    );
  }
}
