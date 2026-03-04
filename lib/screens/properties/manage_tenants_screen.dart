import 'package:flutter/material.dart';
import '../../widgets/buttons/notification_bell_button.dart';
import '../../data/services/mock_api_service.dart';
import '../../data/models/tenant_model.dart';
import '../../widgets/cards/tenant_card.dart';

class ManageTenantsScreen extends StatelessWidget {
  const ManageTenantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Use tenants from prop_001 (Sunnyvale PG) as the default property view
    final allTenants = MockApiService.getTenantsByProperty('prop_001');
    final paidTenants = allTenants.where((t) => t.isPaid).toList();
    final overdueTenants = allTenants
        .where((t) => t.status == 'overdue')
        .toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
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
            icon: Icon(Icons.search, color: theme.colorScheme.onSurface),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.filter_list, color: theme.colorScheme.onSurface),
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
              unselectedLabelColor: theme.colorScheme.onSurface.withValues(
                alpha: 0.6,
              ),
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
        foregroundColor: theme.colorScheme.onPrimary,
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
      itemBuilder: (context, index) => TenantCard(tenant: tenants[index]),
    );
  }
}
