import 'dart:async';

import 'package:donation/src/features/services/special_event_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const _unsetLoadMoreError = Object();

class SpecialEventListState {
  const SpecialEventListState({
    required this.events,
    required this.query,
    required this.page,
    required this.total,
    required this.hasMore,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  final List<Map<String, dynamic>> events;
  final String query;
  final int page;
  final int total;
  final bool hasMore;
  final bool isRefreshing;
  final bool isLoadingMore;
  final String? loadMoreError;

  SpecialEventListState copyWith({
    List<Map<String, dynamic>>? events,
    String? query,
    int? page,
    int? total,
    bool? hasMore,
    bool? isRefreshing,
    bool? isLoadingMore,
    Object? loadMoreError = _unsetLoadMoreError,
  }) {
    return SpecialEventListState(
      events: events ?? this.events,
      query: query ?? this.query,
      page: page ?? this.page,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError: identical(loadMoreError, _unsetLoadMoreError)
          ? this.loadMoreError
          : loadMoreError as String?,
    );
  }
}

final specialEventListProvider = StateNotifierProvider.autoDispose<
    SpecialEventListController, AsyncValue<SpecialEventListState>>((ref) {
  return SpecialEventListController(ref.read(specialEventServiceProvider));
});

class SpecialEventListController
    extends StateNotifier<AsyncValue<SpecialEventListState>> {
  SpecialEventListController(
    this._service, {
    bool loadImmediately = true,
  }) : super(const AsyncValue<SpecialEventListState>.loading()) {
    if (loadImmediately) {
      unawaited(refresh());
    }
  }

  static const int pageSize = 50;

  final SpecialEventService _service;
  int _requestGeneration = 0;

  Future<void> refresh({String? query}) async {
    final previous = state.asData?.value;
    final normalizedQuery = (query ?? previous?.query ?? '').trim();
    final generation = ++_requestGeneration;

    if (previous == null) {
      state = const AsyncValue<SpecialEventListState>.loading();
    } else {
      state = AsyncValue.data(previous.copyWith(
        query: normalizedQuery,
        isRefreshing: true,
        isLoadingMore: false,
        loadMoreError: null,
      ));
    }

    try {
      final result = await _service.getSpecialEvents(
        page: 0,
        limit: pageSize,
        q: normalizedQuery,
      );
      if (generation != _requestGeneration) return;

      state = AsyncValue.data(SpecialEventListState(
        events: List.unmodifiable(result.events),
        query: normalizedQuery,
        page: result.page,
        total: result.total,
        hasMore: result.hasMore,
      ));
    } catch (error, stackTrace) {
      if (generation != _requestGeneration) return;
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> search(String query) => refresh(query: query);

  Future<void> loadMore() async {
    final current = state.asData?.value;
    if (current == null ||
        current.isRefreshing ||
        current.isLoadingMore ||
        !current.hasMore) {
      return;
    }

    final generation = _requestGeneration;
    state = AsyncValue.data(current.copyWith(
      isLoadingMore: true,
      loadMoreError: null,
    ));

    try {
      final result = await _service.getSpecialEvents(
        page: current.page + 1,
        limit: pageSize,
        q: current.query,
      );
      if (generation != _requestGeneration) return;

      final ids = current.events
          .map((event) => event['id']?.toString())
          .whereType<String>()
          .toSet();
      final combined = <Map<String, dynamic>>[
        ...current.events,
        ...result.events.where((event) {
          final id = event['id']?.toString();
          return id == null || ids.add(id);
        }),
      ];

      state = AsyncValue.data(current.copyWith(
        events: List.unmodifiable(combined),
        page: result.page,
        total: result.total,
        hasMore: result.hasMore,
        isLoadingMore: false,
        loadMoreError: null,
      ));
    } catch (error) {
      if (generation != _requestGeneration) return;
      state = AsyncValue.data(current.copyWith(
        isLoadingMore: false,
        loadMoreError: error.toString(),
      ));
    }
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final event = await _service.createSpecialEvent(data);
    await refresh();
    return event;
  }

  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> data,
  ) async {
    final event = await _service.updateSpecialEvent(id, data);
    await refresh();
    return event;
  }

  Future<void> delete(String id) async {
    await _service.deleteSpecialEvent(id);
    await refresh();
  }
}
