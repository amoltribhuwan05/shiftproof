import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftproof/data/models/models.dart';
import 'package:shiftproof/providers/service_providers.dart';
import 'package:shiftproof/services/property_service.dart';

// ---------------------------------------------------------------------------
// Filters model
// ---------------------------------------------------------------------------

class PropertyFilters {
  const PropertyFilters({
    this.type,
    this.location,
    this.minPrice,
    this.maxPrice,
    this.sortBy,
  });

  final String? type;      // 'PG' | 'Flat' | 'Shared Room' | 'Private Room'
  final String? location;  // free-form area/city string
  final int? minPrice;     // rupees
  final int? maxPrice;     // rupees
  final String? sortBy;    // 'price_asc' | 'price_desc' | 'rating'

  bool get isActive =>
      type != null ||
      location != null ||
      minPrice != null ||
      maxPrice != null ||
      sortBy != null;

  int get activeCount =>
      [type, location, minPrice, maxPrice, sortBy]
          .where((e) => e != null)
          .length;

  PropertyFilters copyWith({
    Object? type = _s,
    Object? location = _s,
    Object? minPrice = _s,
    Object? maxPrice = _s,
    Object? sortBy = _s,
  }) {
    return PropertyFilters(
      type: type == _s ? this.type : type as String?,
      location: location == _s ? this.location : location as String?,
      minPrice: minPrice == _s ? this.minPrice : minPrice as int?,
      maxPrice: maxPrice == _s ? this.maxPrice : maxPrice as int?,
      sortBy: sortBy == _s ? this.sortBy : sortBy as String?,
    );
  }
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class FindPgState {
  const FindPgState({
    this.properties = const [],
    this.isLoading = true,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.query = '',
    this.filters = const PropertyFilters(),
    this.error,
  });

  final List<Property> properties;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String query;
  final PropertyFilters filters;
  final String? error;

  FindPgState copyWith({
    List<Property>? properties,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? query,
    PropertyFilters? filters,
    String? error,
    bool clearError = false,
  }) {
    return FindPgState(
      properties: properties ?? this.properties,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      query: query ?? this.query,
      filters: filters ?? this.filters,
      error: clearError ? null : error ?? this.error,
    );
  }
}

// Sentinel for nullable copyWith params
const Object _s = Object();

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class FindPgNotifier extends StateNotifier<FindPgState> {
  FindPgNotifier(this._service) : super(const FindPgState()) {
    _load(0);
  }

  final PropertyService _service;
  int _page = 0;

  Future<void> _load(int page) async {
    if (page == 0) {
      state = FindPgState(query: state.query, filters: state.filters);
    } else {
      if (state.isLoadingMore) return;
      state = state.copyWith(isLoadingMore: true);
    }

    try {
      final result = await _service.listProperties(
        page: page,
        query: state.query.isEmpty ? null : state.query,
        type: state.filters.type,
        location: state.filters.location,
        minPrice: state.filters.minPrice,
        maxPrice: state.filters.maxPrice,
        sortBy: state.filters.sortBy,
      );
      final totalPages = result.meta?.totalPages ?? 1;
      _page = page;
      state = state.copyWith(
        properties: [...state.properties, ...result.data],
        isLoading: false,
        isLoadingMore: false,
        hasMore: page < totalPages - 1,
        clearError: true,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) return;
    await _load(_page + 1);
  }

  Future<void> search(String query) async {
    state = state.copyWith(query: query);
    await _load(0);
  }

  Future<void> applyFilters(PropertyFilters filters) async {
    state = state.copyWith(filters: filters);
    await _load(0);
  }

  Future<void> clearAll() async {
    state = const FindPgState();
    await _load(0);
  }

  Future<void> refresh() => _load(0);
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final findPgProvider =
    StateNotifierProvider.autoDispose<FindPgNotifier, FindPgState>((ref) {
  return FindPgNotifier(ref.read(propertyServiceProvider));
});
