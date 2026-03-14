import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftproof/core/constants/colors.dart';
import 'package:shiftproof/providers/dashboard_provider.dart';
import 'package:shiftproof/screens/properties/manage_tenants_screen.dart';
import 'package:shiftproof/widgets/buttons/notification_bell_button.dart';
import 'package:shiftproof/widgets/cards/action_card.dart';
import 'package:shiftproof/widgets/cards/activity_item.dart';
import 'package:shiftproof/widgets/cards/custom_divider.dart';
import 'package:shiftproof/widgets/cards/section_title.dart';
import 'package:shiftproof/widgets/cards/stat_card.dart';

class PropertyDashboardScreen extends ConsumerWidget {
  const PropertyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final stats = ref.watch(dashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu, color: colorScheme.onSurface),
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
            icon: Icon(Icons.search, color: colorScheme.onSurface),
            onPressed: () {},
          ),
          const NotificationBellButton(dotColor: Colors.redAccent),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 8),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: colorScheme.primary,
              backgroundImage: const CachedNetworkImageProvider(
                'https://i.pravatar.cc/150?img=11',
              ),
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Summary Stats Title
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
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 250,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.4,
              ),
              delegate: SliverChildListDelegate([
                StatCard(
                  title: 'Total Tenants',
                  value: '${stats.totalTenants}',
                  icon: Icons.group_outlined,
                  trendIcon: Icons.trending_up,
                  trendValue: '12%',
                  isTrendPositive: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const ManageTenantsScreen(),
                      ),
                    );
                  },
                ),
                StatCard(
                  title: 'Properties',
                  value: '${stats.totalProperties}',
                  icon: Icons.bed_outlined,
                  trendIcon: Icons.trending_up,
                  trendValue: '5%',
                  isTrendPositive: true,
                ),
                StatCard(
                  title: 'Collected (Mar)',
                  value: stats.collected,
                  icon: Icons.payments_outlined,
                  trendIcon: Icons.trending_up,
                  trendValue: '8%',
                  isTrendPositive: true,
                ),
                StatCard(
                  title: 'Pending',
                  value: stats.pending,
                  icon: Icons.pending_actions_outlined,
                  trendIcon: Icons.trending_down,
                  trendValue: '15%',
                  isTrendPositive: false,
                ),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SectionTitle(title: 'QUICK ACTIONS'),
                const SizedBox(height: 16),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 250,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.2,
              ),
              delegate: SliverChildListDelegate(const [
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
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 32,
              bottom: 8,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
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
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Container(
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
                child: const Column(
                  children: [
                    ActivityItem(
                      title: 'Payment Received from Unit 402',
                      subtitle: r'10 minutes ago • $1,250.00',
                      icon: Icons.check_circle_outline,
                      iconColor: Color(0xFF4CAF50),
                      iconBgColor: Color(0x1A4CAF50),
                    ),
                    CustomDivider(),
                    ActivityItem(
                      title: 'New Move-in: Jane Cooper',
                      subtitle: '2 hours ago • Unit 105',
                      icon: Icons.login_outlined,
                      iconColor: AppColors
                          .lightPrimary, // Using color constant where possible
                      iconBgColor: Color(0x1A007AFF),
                    ),
                    CustomDivider(),
                    ActivityItem(
                      title: 'Maintenance Request: Leak in Kitchen',
                      subtitle: 'Yesterday • Unit 203',
                      icon: Icons.report_problem_outlined,
                      iconColor: Colors.orange,
                      iconBgColor: Color(0x1AFF9800),
                    ),
                    CustomDivider(),
                    ActivityItem(
                      title: 'Move-out Record: Robert Fox',
                      subtitle: 'Oct 24, 2023 • Unit 312',
                      icon: Icons.logout_outlined,
                      iconColor: Colors.grey,
                      iconBgColor: Color(0x1A9E9E9E),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
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
