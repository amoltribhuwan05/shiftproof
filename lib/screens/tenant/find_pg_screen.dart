import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftproof/core/utils/currency_formatter.dart';
import 'package:shiftproof/providers/find_pg_provider.dart';
import 'package:shiftproof/screens/properties/property_details_screen.dart';
import 'package:shiftproof/widgets/buttons/notification_bell_button.dart';
import 'package:shiftproof/widgets/cards/property_card.dart';
import 'package:shiftproof/widgets/cards/property_card_skeleton.dart';
import 'package:shiftproof/widgets/sheets/property_filter_sheet.dart';
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

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 300) {
      ref.read(findPgProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(findPgProvider.notifier).search(value.trim());
    });
  }

  Future<void> _openFilters(PropertyFilters current) async {
    final result = await showModalBottomSheet<PropertyFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PropertyFilterSheet(initial: current),
    );
    if (result != null && mounted) {
      await ref.read(findPgProvider.notifier).applyFilters(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(findPgProvider);
    final activeCount = state.filters.activeCount;

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
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: const [NotificationBellButton()],
      ),
      body: Column(
        children: [
          // Search bar + filter button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
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
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                        suffixIcon: state.query.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: colorScheme.onSurface,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  ref
                                      .read(findPgProvider.notifier)
                                      .search('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Filter icon with active badge
                GestureDetector(
                  onTap: () => _openFilters(state.filters),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: state.filters.isActive
                              ? colorScheme.primary
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.tune,
                          color: state.filters.isActive
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                        ),
                      ),
                      if (activeCount > 0)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.scaffoldBackgroundColor,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '$activeCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildBody(context, theme, state)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, ThemeData theme, FindPgState state) {
    if (state.isLoading) return _buildSkeletonGrid(context);

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

    if (state.properties.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 56,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No properties found',
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            if (state.filters.isActive || state.query.isNotEmpty) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  ref.read(findPgProvider.notifier).clearAll();
                },
                child: const Text('Clear filters'),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(findPgProvider.notifier).refresh(),
      child: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          // Result count / active filter summary
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Popular Rentals',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (state.filters.isActive)
                  GestureDetector(
                    onTap: () =>
                        ref.read(findPgProvider.notifier).applyFilters(
                              const PropertyFilters(),
                            ),
                    child: Text(
                      'Clear filters',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              mainAxisExtent: 255,
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
              mainAxisExtent: 255,
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
          mainAxisExtent: 255,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 2,
        itemBuilder: (_, __) => const PropertyCardSkeleton(),
      ),
    );
  }
}
