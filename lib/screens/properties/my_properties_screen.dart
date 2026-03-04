import 'package:flutter/material.dart';
import '../../widgets/buttons/notification_bell_button.dart';
import '../../widgets/cards/property_card.dart';
import '../../data/services/mock_api_service.dart';
import 'property_details_screen.dart';

class MyPropertiesScreen extends StatelessWidget {
  const MyPropertiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final properties = MockApiService.getProperties();
    final activeProps = properties.where((p) => p.availableRooms > 0).toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
            onPressed: () {
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
          ),
          title: Text(
            'My Properties',
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
              icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurface),
              onPressed: () {},
            ),
          ],
          bottom: TabBar(
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
              Tab(text: 'All (${properties.length})'),
              Tab(text: 'Active (${activeProps.length})'),
              const Tab(text: 'Maintenance'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // All Tab
            GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                mainAxisExtent: 360,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: properties.length,
              itemBuilder: (context, index) {
                final p = properties[index];
                final isFullyOccupied = p.availableRooms == 0;
                return PropertyCard(
                  title: p.title,
                  location: p.location,
                  price: p.price,
                  imageUrl: p.imageUrl,
                  typeTag: p.type,
                  statusTag: isFullyOccupied ? 'Full' : 'Active',
                  statusColor: isFullyOccupied
                      ? const Color(0xFFFFC107)
                      : const Color(0xFF4CAF50),
                  tenants: p.occupiedRooms,
                  units: p.totalRooms,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PropertyDetailsScreen(property: p),
                      ),
                    );
                  },
                );
              },
            ),
            // Active Tab
            GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                mainAxisExtent: 360,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: activeProps.length,
              itemBuilder: (context, index) {
                final p = activeProps[index];
                return PropertyCard(
                  title: p.title,
                  location: p.location,
                  price: p.price,
                  imageUrl: p.imageUrl,
                  typeTag: p.type,
                  statusTag: 'Active',
                  statusColor: const Color(0xFF4CAF50),
                  tenants: p.occupiedRooms,
                  units: p.totalRooms,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PropertyDetailsScreen(property: p),
                      ),
                    );
                  },
                );
              },
            ),
            // Maintenance Tab
            const Center(child: Text('No properties under maintenance')),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'my_properties_fab',
          onPressed: () {},
          backgroundColor: colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
