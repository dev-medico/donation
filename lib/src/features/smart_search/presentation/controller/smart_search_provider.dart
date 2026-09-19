import 'dart:async';

import 'package:donation/src/features/donation_member/domain/member.dart';
import 'package:donation/src/features/smart_search/data/smart_search_repository.dart';
import 'package:donation/src/features/smart_search/domain/smart_search_models.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const _pageSize = 50;
const _requestTimeout = Duration(seconds: 40);

final smartSearchRepositoryProvider =
    Provider<SmartSearchRepository>((ref) => SmartSearchRepository());

final smartSearchTownshipsProvider =
    FutureProvider<List<TownshipOption>>((ref) async {
  return ref.read(smartSearchRepositoryProvider).townships();
});

/// What the screen is currently asking the server for.
class SmartSearchRequest {
  const SmartSearchRequest.smart(this.query)
      : filters = null,
        availability = null;

  const SmartSearchRequest.rank(this.filters, {this.availability})
      : query = '';

  const SmartSearchRequest._({
    required this.query,
    required this.filters,
    required this.availability,
  });

  /// Free text for the server to parse (smart mode).
  final String query;

  /// Explicit filters (rank mode); null means smart mode.
  final SmartFilters? filters;

  /// green / yellow / red, applied to the visible page only.
  final String? availability;

  bool get isSmart => filters == null;

  SmartSearchRequest withAvailability(String? level) => SmartSearchRequest._(
        query: query,
        filters: filters,
        availability: level,
      );
}

class SmartSearchState {
  const SmartSearchState({
    required this.request,
    required this.page,
    required this.donors,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  final SmartSearchRequest request;
  final SmartSearchPage page;

  /// All loaded rows across pages, in server rank order.
  final List<RankedDonor> donors;
  final bool isLoadingMore;
  final String? loadMoreError;

  bool get hasMore => page.hasMore;

  SmartSearchState copyWith({
    SmartSearchRequest? request,
    SmartSearchPage? page,
    List<RankedDonor>? donors,
    bool? isLoadingMore,
    String? loadMoreError,
    bool clearLoadMoreError = false,
  }) {
    return SmartSearchState(
      request: request ?? this.request,
      page: page ?? this.page,
      donors: donors ?? this.donors,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError:
          clearLoadMoreError ? null : (loadMoreError ?? this.loadMoreError),
    );
  }
}

/// Drives the smart search screen. Smart mode sends the typed text; once the
/// user corrects a chip the controller switches to rank mode with explicit
/// filters, so the model is bypassed after the user has spoken.
class SmartSearchController
    extends StateNotifier<AsyncValue<SmartSearchState?>> {
  SmartSearchController(this._repository) : super(const AsyncData(null));

  final SmartSearchRepository _repository;
  int _generation = 0;

  Future<void> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      state = const AsyncData(null);
      return;
    }
    await _run(SmartSearchRequest.smart(q));
  }

  /// Re-query with explicit filters derived from the current result plus one change.
  Future<void> applyOverride({
    String? bloodGroup,
    bool clearBloodGroup = false,
    String? township,
    bool clearTownship = false,
    String? gender,
    bool clearGender = false,
    bool? urgent,
  }) async {
    final current = state.asData?.value;
    final base = current?.page.filters ?? const SmartFilters();
    final keepQuery = current?.page.mode == 'fallback' ? base.q : '';
    final filters = SmartFilters(
      q: keepQuery,
      bloodGroups: clearBloodGroup
          ? const []
          : (bloodGroup != null ? [bloodGroup] : base.bloodGroups),
      township: clearTownship ? null : (township ?? base.township),
      gender: clearGender ? null : (gender ?? base.gender),
      urgent: urgent ?? base.urgent,
    );
    await _run(SmartSearchRequest.rank(
      filters,
      availability: current?.request.availability,
    ));
  }

  Future<void> setAvailability(String? level) async {
    final current = state.asData?.value;
    if (current == null) return;
    await _run(current.request.withAvailability(level));
  }

  Future<void> refresh() async {
    final current = state.asData?.value;
    if (current == null) return;
    await _run(current.request);
  }

  Future<void> loadNextPage() async {
    final current = state.asData?.value;
    if (current == null || current.isLoadingMore || !current.hasMore) return;
    final generation = _generation;
    state = AsyncData(
      current.copyWith(isLoadingMore: true, clearLoadMoreError: true),
    );
    try {
      final next = await _fetch(current.request, current.page.page + 1);
      if (!mounted || generation != _generation) return;
      state = AsyncData(
        current.copyWith(
          page: next,
          donors: [...current.donors, ...next.donors],
          isLoadingMore: false,
        ),
      );
    } catch (error) {
      if (!mounted || generation != _generation) return;
      state = AsyncData(
        current.copyWith(isLoadingMore: false, loadMoreError: '$error'),
      );
    }
  }

  /// Keeps a saved remark or availability edit in place without reloading,
  /// mirroring the existing Find Blood behaviour.
  void applyAvailabilityEdit(Member saved) {
    final current = state.asData?.value;
    if (current == null) return;
    final identity = saved.id?.toString() ?? saved.memberId ?? '';
    if (identity.isEmpty) return;
    List<RankedDonor> patch(List<RankedDonor> rows) => rows
        .map((row) => row.identity == identity
            ? row.withMember(row.member.withAvailability(
                status: saved.status,
                note: saved.note,
                canDonateValue: saved.canDonateValue,
              ))
            : row)
        .toList(growable: false);
    state = AsyncData(current.copyWith(donors: patch(current.donors)));
  }

  Future<void> _run(SmartSearchRequest request) async {
    final generation = ++_generation;
    state = const AsyncLoading();
    try {
      final page = await _fetch(request, 0);
      if (!mounted || generation != _generation) return;
      state = AsyncData(SmartSearchState(
        request: request,
        page: page,
        donors: page.donors,
      ));
    } catch (error, stackTrace) {
      if (!mounted || generation != _generation) return;
      state = AsyncError(error, stackTrace);
    }
  }

  Future<SmartSearchPage> _fetch(SmartSearchRequest request, int page) {
    final future = request.isSmart
        ? _repository.search(
            query: request.query,
            page: page,
            limit: _pageSize,
            availability: request.availability,
          )
        : _repository.rank(
            query: request.filters!.q,
            bloodGroup: request.filters!.bloodGroupParam,
            township: request.filters!.township,
            gender: request.filters!.gender,
            urgent: request.filters!.urgent,
            page: page,
            limit: _pageSize,
            availability: request.availability,
          );
    return future.timeout(_requestTimeout);
  }
}

final smartSearchControllerProvider = StateNotifierProvider.autoDispose<
    SmartSearchController, AsyncValue<SmartSearchState?>>(
  (ref) => SmartSearchController(ref.watch(smartSearchRepositoryProvider)),
);
