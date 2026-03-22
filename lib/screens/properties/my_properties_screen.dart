import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftproof/core/utils/currency_formatter.dart';
import 'package:shiftproof/data/models/models.dart';
import 'package:shiftproof/providers/service_providers.dart';
import 'package:shiftproof/screens/properties/add_property_screen.dart';
import 'package:shiftproof/screens/properties/property_details_screen.dart';
import 'package:shiftproof/widgets/buttons/notification_bell_button.dart';
import 'package:shiftproof/widgets/cards/property_card.dart';

class MyPropertiesScreen extends ConsumerWidget {
  const MyPropertiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final propertiesAsync = ref.watch(propertiesProvider);

    return propertiesAsync.when(
      loading: () => _scaffold(
        context: context,
        theme: theme,
        colorScheme: colorScheme,
        allCount: 0,
        activeCount: 0,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => _scaffold(
        context: context,
        theme: theme,
        colorScheme: colorScheme,
        allCount: 0,
        activeCount: 0,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
              const SizedBox(height: 16),
              const Text('Failed to load properties'),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(propertiesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (properties) {
        final activeProps = properties
            .where((p) => (p.totalRooms ?? 0) - (p.occupiedRooms ?? 0) > 0)
            .toList();

        return _scaffold(
          context: context,
          theme: theme,
          colorScheme: colorScheme,
          allCount: properties.length,
          activeCount: activeProps.length,
          body: TabBarView(
            children: [
              _propertyGrid(context, properties),
              _propertyGrid(context, activeProps),
              const Center(child: Text('No properties under maintenance')),
            ],
          ),
        );
      },
    );
  }

  Widget _scaffold({
    required BuildContext context,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required int allCount,
    required int activeCount,
    required Widget body,
  }) {
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
              Tab(text: allCount > 0 ? 'All ($allCount)' : 'All'),
              Tab(text: activeCount > 0 ? 'Active ($activeCount)' : 'Active'),
              const Tab(text: 'Maintenance'),
            ],
          ),
        ),
        body: body,
        floatingActionButton: FloatingActionButton(
          heroTag: 'my_properties_fab',
          onPressed: () {
            Navigator.push<void>(
              context,
              MaterialPageRoute(builder: (context) => const AddPropertyScreen()),
            );
          },
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

  Widget _propertyGrid(BuildContext context, List<Property> properties) {
    if (properties.isEmpty) {
      return const Center(child: Text('No properties found'));
    }
    return GridView.builder(
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
        final availableRooms = (p.totalRooms ?? 0) - (p.occupiedRooms ?? 0);
        final isFullyOccupied = availableRooms <= 0;
        return PropertyCard(
          title: p.title ?? 'Unnamed Property',
          location: p.location ?? '',
          price: '${CurrencyFormatter.format(p.price ?? 0)}/mo',
          imageUrl: p.imageUrl ?? '',
          typeTag: p.type ?? 'PG',
          statusTag: isFullyOccupied ? 'Full' : 'Active',
          statusColor: isFullyOccupied
              ? const Color(0xFFFFC107)
              : const Color(0xFF4CAF50),
          tenants: p.occupiedRooms ?? 0,
          units: p.totalRooms ?? 0,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => PropertyDetailsScreen(property: p),
              ),
            );
          },
        );
      },
    );
  }
}
