import 'package:flutter/material.dart';
import '../../widgets/buttons/notification_bell_button.dart';
import '../../data/services/mock_api_service.dart';

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
          icon: Icon(Icons.menu, color: isDark ? Colors.white : Colors.black87),
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
              color: isDark ? Colors.white : Colors.black87,
            ),
            onPressed: () {},
          ),
          const NotificationBellButton(
            hasUnread: true,
            dotColor: Colors.redAccent,
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
                  _buildSectionTitle(context, 'OVERVIEW'),
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
                  _buildStatCard(
                    context,
                    title: 'Total Tenants',
                    value: '$totalTenants',
                    icon: Icons.group_outlined,
                    trendIcon: Icons.trending_up,
                    trendValue: '12%',
                    isTrendPositive: true,
                  ),
                  _buildStatCard(
                    context,
                    title: 'Properties',
                    value: '$totalProperties',
                    icon: Icons.bed_outlined,
                    trendIcon: Icons.trending_up,
                    trendValue: '5%',
                    isTrendPositive: true,
                  ),
                  _buildStatCard(
                    context,
                    title: 'Collected (Mar)',
                    value: collected,
                    icon: Icons.payments_outlined,
                    trendIcon: Icons.trending_up,
                    trendValue: '8%',
                    isTrendPositive: true,
                  ),
                  _buildStatCard(
                    context,
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
              _buildSectionTitle(context, 'QUICK ACTIONS'),
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
                children: [
                  _buildActionCard(
                    context,
                    title: 'Manage Tenants',
                    subtitle: 'Active & waitlist',
                    icon: Icons.person_add_outlined,
                    isPrimary: true,
                  ),
                  _buildActionCard(
                    context,
                    title: 'View Payments',
                    subtitle: 'Transaction history',
                    icon: Icons.receipt_long_outlined,
                    isPrimary: false,
                  ),
                  _buildActionCard(
                    context,
                    title: 'View Reports',
                    subtitle: 'Financial insights',
                    icon: Icons.analytics_outlined,
                    isPrimary: false,
                  ),
                  _buildActionCard(
                    context,
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
                  _buildSectionTitle(context, 'RECENT ACTIVITY'),
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
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? colorScheme.primary.withValues(alpha: 0.1)
                        : Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  children: [
                    _buildActivityItem(
                      context,
                      title: 'Payment Received from Unit 402',
                      subtitle: '10 minutes ago • \$1,250.00',
                      icon: Icons.check_circle_outline,
                      iconColor: Colors.green,
                      iconBgColor: Colors.green.withValues(alpha: 0.1),
                    ),
                    _buildDivider(context),
                    _buildActivityItem(
                      context,
                      title: 'New Move-in: Jane Cooper',
                      subtitle: '2 hours ago • Unit 105',
                      icon: Icons.login_outlined,
                      iconColor: colorScheme.primary,
                      iconBgColor: colorScheme.primary.withValues(alpha: 0.1),
                    ),
                    _buildDivider(context),
                    _buildActivityItem(
                      context,
                      title: 'Maintenance Request: Leak in Kitchen',
                      subtitle: 'Yesterday • Unit 203',
                      icon: Icons.report_problem_outlined,
                      iconColor: Colors.orange,
                      iconBgColor: Colors.orange.withValues(alpha: 0.1),
                    ),
                    _buildDivider(context),
                    _buildActivityItem(
                      context,
                      title: 'Move-out Record: Robert Fox',
                      subtitle: 'Oct 24, 2023 • Unit 312',
                      icon: Icons.logout_outlined,
                      iconColor: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                      iconBgColor: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
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
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade400
            : Colors.grey.shade500,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
          : Colors.grey.shade200,
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required IconData trendIcon,
    required String trendValue,
    required bool isTrendPositive,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final trendColor = isTrendPositive ? Colors.green : Colors.red;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surface.withValues(alpha: 0.5)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            ),
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(trendIcon, color: trendColor, size: 12),
                  const SizedBox(width: 2),
                  Text(
                    trendValue,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: trendColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isPrimary,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isPrimary
        ? theme.colorScheme.primary
        : (isDark
              ? theme.colorScheme.surface.withValues(alpha: 0.5)
              : Colors.white);
    final textColor = isPrimary
        ? Colors.white
        : (isDark ? Colors.white : Colors.black87);
    final subtitleColor = isPrimary
        ? Colors.white.withValues(alpha: 0.8)
        : (isDark ? Colors.grey.shade400 : Colors.grey.shade500);
    final iconBgColor = isPrimary
        ? Colors.white.withValues(alpha: 0.2)
        : (isDark ? Colors.grey.shade800 : Colors.grey.shade100);
    final iconColor = isPrimary ? Colors.white : theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPrimary
              ? Colors.transparent
              : (isDark
                    ? theme.colorScheme.primary.withValues(alpha: 0.1)
                    : Colors.grey.shade200),
        ),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 10, color: subtitleColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade400
                        : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade400
                : Colors.grey.shade300,
          ),
        ],
      ),
    );
  }
}
