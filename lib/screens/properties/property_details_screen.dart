import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftproof/data/models/models.dart';
import 'package:shiftproof/providers/service_providers.dart';
import 'package:shiftproof/screens/properties/manage_tenants_screen.dart';
import 'package:shiftproof/screens/tenant/join_pg_screen.dart';
import 'package:shiftproof/widgets/buttons/notification_bell_button.dart';
import 'package:shiftproof/widgets/buttons/primary_button.dart';
import 'package:shiftproof/widgets/cards/facility_item.dart';
import 'package:shiftproof/widgets/cards/room_card.dart';

class PropertyDetailsScreen extends ConsumerWidget {
  const PropertyDetailsScreen({
    super.key,
    this.property,
    this.propertyId = '',
  });

  /// Pre-fetched property. If null, fetches using [propertyId].
  final Property? property;

  /// Used to fetch the property when [property] is not provided.
  final String propertyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (property != null) {
      return _PropertyDetailsView(property: property!);
    }

    final propertyAsync = ref.watch(propertyByIdProvider(propertyId));
    return propertyAsync.when(
      loading: () => Scaffold(
        appBar: _minimalAppBar(context),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => Scaffold(
        appBar: _minimalAppBar(context),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 48, color: Color(0xFFEF4444)),
              const SizedBox(height: 16),
              const Text('Failed to load property'),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    ref.invalidate(propertyByIdProvider(propertyId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (fetched) {
        if (fetched == null) {
          return Scaffold(
            appBar: _minimalAppBar(context),
            body: const Center(child: Text('Property not found')),
          );
        }
        return _PropertyDetailsView(property: fetched);
      },
    );
  }

  AppBar _minimalAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface),
        onPressed: () {
          if (Navigator.canPop(context)) Navigator.pop(context);
        },
      ),
    );
  }
}

// ─── Actual detail view (non-nullable property) ───────────────────────────────

class _PropertyDetailsView extends StatelessWidget {
  const _PropertyDetailsView({required this.property});
  final Property property;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final heroImage =
        property.imageUrl ??
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?q=80&w=2070&auto=format&fit=crop';
    final propTitle = property.title ?? 'Unnamed Property';
    final propLocation = property.location ?? '';
    final propRating = property.rating ?? 0.0;
    final propAmenities = property.amenities ?? [];
    final propTenants = property.occupiedRooms ?? 0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
            onPressed: () {
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
          ),
        ),
        actions: [
          const NotificationBellButton(),
          Padding(
            padding: const EdgeInsets.all(8),
            child: IconButton(
              icon: Icon(Icons.share, color: theme.colorScheme.onSurface),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image Section
            SizedBox(
              height: (MediaQuery.of(context).size.height * 0.32)
                  .clamp(220.0, 340.0),
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: heroImage,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => ColoredBox(
                      color: Colors.grey.shade200,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => ColoredBox(
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.8),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 24,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                colorScheme.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: colorScheme.primary
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified,
                                color: colorScheme.primary,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Verified Property',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    propTitle,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 2,
                                          color: Colors.black54,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (propLocation.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on,
                                          color: Colors.grey.shade300,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            propLocation,
                                            style: TextStyle(
                                              color: Colors.grey.shade300,
                                              fontSize: 12,
                                            ),
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (propRating > 0)
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.white
                                        .withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          propRating.toStringAsFixed(1),
                                          style: const TextStyle(
                                            color: Colors.amber,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        Icon(
                                          Icons.star,
                                          color: Colors.amber.shade400,
                                          size: 14,
                                        ),
                                      ],
                                    ),
                                    const Text(
                                      '128 reviews',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Room Types
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Room Types',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: (MediaQuery.of(context).size.height * 0.17)
                        .clamp(120.0, 150.0),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      primary: false,
                      shrinkWrap: true,
                      children: [
                        const RoomCard(
                          title: 'Single Private',
                          icon: Icons.single_bed,
                          tag: '2 Left',
                          tagColor: Color(0xFF4CAF50),
                          desc: 'Ideally for students needing privacy.',
                          price: '₹12,000',
                        ),
                        const SizedBox(width: 12),
                        RoomCard(
                          title: 'Double Sharing',
                          icon: Icons.bed,
                          tag: 'Popular',
                          tagColor: colorScheme.primary,
                          desc: 'Spacious room with attached balcony.',
                          price: '₹8,500',
                          isPopular: true,
                        ),
                        const SizedBox(width: 12),
                        Opacity(
                          opacity: 0.6,
                          child: RoomCard(
                            title: 'Triple Sharing',
                            icon: Icons.bed,
                            tag: 'Sold Out',
                            tagColor: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                            desc: 'Budget friendly option for groups.',
                            price: '₹6,000',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Facilities
            if (propAmenities.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Facilities & Amenities',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount:
                          MediaQuery.of(context).size.width > 900
                              ? 8
                              : (MediaQuery.of(context).size.width > 600
                                  ? 6
                                  : 4),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        ...propAmenities.take(7).map((amenity) {
                          return FacilityItem(
                            title: amenity,
                            icon: _getIconForAmenity(amenity),
                          );
                        }),
                        if (propAmenities.length > 7)
                          const FacilityItem(title: 'More', isMore: true),
                      ],
                    ),
                  ],
                ),
              ),

            // Current Tenants Snippet
            if (propTenants > 0)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? colorScheme.surface.withValues(alpha: 0.5)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 60,
                            height: 32,
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 0,
                                  child: CircleAvatar(
                                    radius: 16,
                                    backgroundImage:
                                        const CachedNetworkImageProvider(
                                          'https://i.pravatar.cc/100?img=1',
                                        ),
                                    onBackgroundImageError:
                                        (exception, stackTrace) {},
                                  ),
                                ),
                                Positioned(
                                  left: 14,
                                  child: CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.white,
                                    child: CircleAvatar(
                                      radius: 14,
                                      backgroundImage:
                                          const CachedNetworkImageProvider(
                                            'https://i.pravatar.cc/100?img=2',
                                          ),
                                      onBackgroundImageError:
                                          (exception, stackTrace) {},
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 28,
                                  child: CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.white,
                                    child: CircleAvatar(
                                      radius: 14,
                                      backgroundImage:
                                          const CachedNetworkImageProvider(
                                            'https://i.pravatar.cc/100?img=3',
                                          ),
                                      onBackgroundImageError:
                                          (exception, stackTrace) {},
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Tenants',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                              Text(
                                '$propTenants people currently living here',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
              ),

            // Map placeholder
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: (MediaQuery.of(context).size.height * 0.18)
                        .clamp(130.0, 180.0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CachedNetworkImage(
                            imageUrl:
                                'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=2074&auto=format&fit=crop',
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Container(color: Colors.grey.shade200),
                            errorWidget: (context, url, error) => ColoredBox(
                              color: Colors.grey.shade300,
                              child: const Center(
                                child: Icon(Icons.map, color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  colorScheme.primary.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.near_me,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'View on Map',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(
              color:
                  isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 56,
                child: PrimaryButton(
                  text: 'Join this PG / Flat',
                  icon: Icons.login,
                  onPressed: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const JoinPgScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark
                        ? Colors.grey.shade300
                        : Colors.grey.shade700,
                    side: BorderSide(
                      color: isDark
                          ? Colors.grey.shade600
                          : Colors.grey.shade300,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => ManageTenantsScreen(
                          propertyId: property.id ?? '',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.admin_panel_settings, size: 18),
                  label: const Text(
                    'I manage this property',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData? _getIconForAmenity(String amenity) {
    switch (amenity.toLowerCase()) {
      case 'fast wifi':
        return Icons.wifi;
      case 'food':
        return Icons.restaurant;
      case 'laundry':
        return Icons.local_laundry_service;
      case 'security':
        return Icons.security;
      case 'backup':
        return Icons.bolt;
      case 'cleaning':
        return Icons.cleaning_services;
      case 'gym':
        return Icons.fitness_center;
      default:
        return Icons.check_circle_outline;
    }
  }
}
