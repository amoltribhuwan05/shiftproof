import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiftproof/data/models/models.dart';
import 'package:shiftproof/providers/service_providers.dart';
import 'package:shiftproof/services/property_service.dart';

class FindPgState {
  const FindPgState({
    this.properties = const [],
    this.isLoading = true,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  final List<Property> properties;
  final bool isLoading;      // true only during initial page 0 fetch
  final bool isLoadingMore;  // true when fetching subsequent pages
  final bool hasMore;
  final String? error;

  FindPgState copyWith({
    List<Property>? properties,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return FindPgState(
      properties: properties ?? this.properties,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class FindPgNotifier extends StateNotifier<FindPgState> {
  FindPgNotifier(this._service) : super(const FindPgState()) {
    _load(0);
  }

  final PropertyService _service;
  int _page = 0;

  Future<void> _load(int page) async {
    if (page == 0) {
      state = const FindPgState();
    } else {
      if (state.isLoadingMore) return;
      state = state.copyWith(isLoadingMore: true);
    }

    try {
      final result = await _service.listProperties(page: page);
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

  Future<void> refresh() => _load(0);
}

final findPgProvider =
    StateNotifierProvider.autoDispose<FindPgNotifier, FindPgState>((ref) {
  return FindPgNotifier(ref.read(propertyServiceProvider));
});
