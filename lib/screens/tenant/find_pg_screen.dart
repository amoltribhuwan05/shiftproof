import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftproof/core/utils/currency_formatter.dart';
import 'package:shiftproof/providers/find_pg_provider.dart';
import 'package:shiftproof/screens/properties/property_details_screen.dart';
import 'package:shiftproof/widgets/buttons/notification_bell_button.dart';
import 'package:shiftproof/widgets/cards/property_card.dart';
import 'package:shiftproof/widgets/cards/property_card_skeleton.dart';
import 'package:shimmer/shimmer.dart';

class FindPgScreen extends ConsumerStatefulWidget {
  const FindPgScreen({super.key});

  @override
  ConsumerState<FindPgScreen> createState() => _FindPgScreenState();
}

class _FindPgScreenState extends ConsumerState<FindPgScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(findPgProvider.notifier).search(value.trim());
    });
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 300) {
      ref.read(findPgProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(findPgProvider);

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.real_estate_agent,
              color: colorScheme.primary,
              size: 22,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ShiftProof',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Find your next home',
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: const [NotificationBellButton()],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search area, PG name, or landmark',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  suffixIcon: state.query.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close,
                            color: theme.colorScheme.onSurface,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(findPgProvider.notifier).search('');
                          },
                        )
                      : IconButton(
                          icon: Icon(
                            Icons.tune,
                            color: theme.colorScheme.onSurface,
                          ),
                          onPressed: () {},
                        ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip(
                  context,
                  'PG',
                  Icons.home,
                  state: state,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  'Flat',
                  Icons.apartment,
                  state: state,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  'Shared Room',
                  Icons.group,
                  state: state,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context,
                  'Private Room',
                  Icons.single_bed,
                  state: state,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(child: _buildBody(context, theme, state)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, ThemeData theme, FindPgState state) {
    // Initial load — full skeleton grid
    if (state.isLoading) {
      return _buildSkeletonGrid(context);
    }

    // Error with no data
    if (state.error != null && state.properties.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
            const SizedBox(height: 16),
            const Text('Failed to load listings'),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.read(findPgProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (state.properties.isEmpty) {
      return const Center(child: Text('No properties found'));
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(findPgProvider.notifier).refresh(),
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Popular Rentals',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              mainAxisExtent: 360,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: state.properties.length,
            itemBuilder: (context, index) {
              final p = state.properties[index];
              return PropertyCard(
                title: p.title ?? 'Unnamed Property',
                location: p.location ?? '',
                price: '${CurrencyFormatter.format(p.price ?? 0)}/mo',
                imageUrl: p.imageUrl ?? '',
                typeTag: p.type ?? 'PG',
                statusTag: 'Verified',
                statusColor: const Color(0xFF4CAF50),
                tenants: p.occupiedRooms ?? 0,
                units: p.totalRooms ?? 0,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => PropertyDetailsScreen(property: p),
                    ),
                  );
                },
              );
            },
          ),
          if (state.isLoadingMore) ...[
            const SizedBox(height: 16),
            _buildLoadMoreSkeletons(context),
          ],
          if (!state.hasMore)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  "You've seen all properties",
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSkeletonGrid(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Title placeholder
          Container(
            width: 160,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              mainAxisExtent: 360,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: 4,
            itemBuilder: (_, __) => const PropertyCardSkeleton(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreSkeletons(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
      highlightColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 400,
          mainAxisExtent: 360,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 2,
        itemBuilder: (_, __) => const PropertyCardSkeleton(),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    IconData icon, {
    required FindPgState state,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = state.selectedType == label;

    return GestureDetector(
      onTap: () => ref.read(findPgProvider.notifier).filterByType(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : theme.colorScheme.surface,
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : theme.colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.2),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
