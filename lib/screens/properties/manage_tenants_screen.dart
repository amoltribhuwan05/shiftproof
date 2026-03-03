import 'package:flutter/material.dart';
import '../../widgets/buttons/notification_bell_button.dart';
import '../../data/services/mock_api_service.dart';
import '../../data/models/tenant_model.dart';

class ManageTenantsScreen extends StatelessWidget {
  const ManageTenantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    // Use tenants from prop_001 (Sunnyvale PG) as the default property view
    final allTenants = MockApiService.getTenantsByProperty('prop_001');
    final paidTenants = allTenants.where((t) => t.isPaid).toList();
    final overdueTenants = allTenants
        .where((t) => t.status == 'overdue')
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
          'Manage Tenants',
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
          IconButton(
            icon: Icon(
              Icons.filter_list,
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
                Tab(text: 'All (${allTenants.length})'),
                Tab(text: 'Paid (${paidTenants.length})'),
                Tab(text: 'Overdue (${overdueTenants.length})'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildTenantList(context, allTenants),
                  _buildTenantList(context, paidTenants),
                  _buildTenantList(context, overdueTenants),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'manage_tenants_fab',
        onPressed: () {},
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildTenantList(BuildContext context, List<Tenant> tenants) {
    if (tenants.isEmpty) {
      return const Center(child: Text('No tenants found'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tenants.length,
      itemBuilder: (context, index) =>
          _buildTenantCard(context, tenants[index]),
    );
  }

  Widget _buildTenantCard(BuildContext context, Tenant tenant) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    Color statusColor;
    switch (tenant.status) {
      case 'active':
        statusColor = Colors.green;
        break;
      case 'overdue':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.amber;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surface.withValues(alpha: 0.5)
            : Colors.white,
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(tenant.avatarUrl),
                    onBackgroundImageError: (_, _) {},
                    child: const Icon(Icons.person, color: Colors.grey),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tenant.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        tenant.room,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tenant.status.toUpperCase(),
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
          const SizedBox(height: 12),
          Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoChip(
                context,
                Icons.currency_rupee,
                tenant.rentAmount,
                isDark,
              ),
              _infoChip(
                context,
                Icons.calendar_today,
                'Due ${tenant.dueDate}',
                isDark,
              ),
              _infoChip(context, Icons.phone, tenant.phone, isDark),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? Colors.white : Colors.black87,
                    side: BorderSide(
                      color: isDark
                          ? Colors.grey.shade700
                          : Colors.grey.shade300,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble_outline, size: 16),
                  label: const Text('Message'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.receipt_long, size: 16),
                  label: const Text('Collect Rent'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(
    BuildContext context,
    IconData icon,
    String label,
    bool isDark,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 13,
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
