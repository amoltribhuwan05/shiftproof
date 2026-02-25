import 'package:flutter/material.dart';
import '../../widgets/cards/property_card.dart';

class MyPropertiesScreen extends StatelessWidget {
  const MyPropertiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: theme.scaffoldBackgroundColor.withValues(
            alpha: 0.95,
          ),
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
            'My Properties',
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
          bottom: TabBar(
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
              Tab(text: 'All (12)'),
              Tab(text: 'Active'),
              Tab(text: 'Maintenance'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // All Tab
            ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 3,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return PropertyCard(
                    title: 'Greenwood Residency',
                    location: 'HSR Layout, Bangalore',
                    price: '₹45,000',
                    imageUrl:
                        'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?q=80&w=2000&auto=format&fit=crop',
                    typeTag: 'Medium PG',
                    statusTag: 'Active',
                    statusColor: Colors.green,
                    tenants: 12,
                    units: 15,
                    onTap: () {},
                  );
                } else if (index == 1) {
                  return PropertyCard(
                    title: 'Skyline Heights',
                    location: 'Koramangala, Bangalore',
                    price: '₹32,000',
                    imageUrl:
                        'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?q=80&w=2070&auto=format&fit=crop',
                    typeTag: 'Small PG',
                    statusTag: 'Maintenance',
                    statusColor: Colors.amber,
                    tenants: 8,
                    units: 10,
                    onTap: () {},
                  );
                } else {
                  return PropertyCard(
                    title: 'The Urban Nest',
                    location: 'Whitefield, Bangalore',
                    price: '₹68,000',
                    imageUrl:
                        'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?q=80&w=2070&auto=format&fit=crop',
                    typeTag: 'Premium PG',
                    statusTag: 'Active',
                    statusColor: Colors.green,
                    tenants: 24,
                    units: 30,
                    onTap: () {},
                  );
                }
              },
            ),

            // Active Tab Placeholder
            const Center(child: Text('Active Properties')),

            // Maintenance Tab Placeholder
            const Center(child: Text('Properties Under Maintenance')),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'my_properties_fab',
          onPressed: () {},
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
