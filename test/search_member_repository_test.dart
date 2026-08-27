import 'dart:async';

import 'package:donation/src/features/donation_member/data/search_member_repository.dart';
import 'package:donation/src/features/donation_member/domain/member.dart';
import 'package:donation/src/features/donation_member/presentation/controller/member_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

Map<String, dynamic> _memberJson(int id) => {
      'id': id,
      'member_id': 'M-$id',
      'name': 'Member $id',
      'blood_type': 'O (Rh +)',
      'phone': '09$id',
      'status': 'available',
      'can_donate': true,
    };

class _PagedRepository extends SearchMemberRepository {
  final requestedPages = <int>[];

  @override
  Future<SearchMemberPage> searchMembers({
    String? query,
    String? bloodType,
    String? availability,
    String? lastDonation,
    int page = 0,
    int limit = 50,
  }) async {
    requestedPages.add(page);
    final remaining = 120 - page * limit;
    final count = remaining.clamp(0, limit);
    final members = List.generate(
      count,
      (index) => Member(
        id: page * limit + index + 1,
        memberId: 'M-${page * limit + index + 1}',
        name: 'Member ${page * limit + index + 1}',
        status: 'available',
      ),
    );
    return SearchMemberPage(
      members: members,
      total: 120,
      analysis: const SearchMemberAnalysis(
        total: 120,
        green: 120,
        yellow: 0,
        red: 0,
      ),
      page: page,
      limit: limit,
    );
  }
}

class _RefreshRaceRepository extends SearchMemberRepository {
  int firstPageCalls = 0;
  final nextPage = Completer<SearchMemberPage>();

  @override
  Future<SearchMemberPage> searchMembers({
    String? query,
    String? bloodType,
    String? availability,
    String? lastDonation,
    int page = 0,
    int limit = 50,
  }) async {
    if (page == 1) return nextPage.future;
    firstPageCalls += 1;
    final refreshed = firstPageCalls > 1;
    return SearchMemberPage(
      members: [
        Member(
          id: refreshed ? 99 : 1,
          memberId: refreshed ? 'M-99' : 'M-1',
          status: 'available',
        ),
      ],
      total: refreshed ? 1 : 2,
      analysis: SearchMemberAnalysis(
        total: refreshed ? 1 : 2,
        green: refreshed ? 1 : 2,
        yellow: 0,
        red: 0,
      ),
      page: 0,
      limit: 1,
    );
  }
}

void main() {
  test('loads one page and preserves global analysis metadata', () async {
    final requests = <Map<String, dynamic>>[];
    final repository = SearchMemberRepository(
      pageLoader: (params) async {
        requests.add(Map<String, dynamic>.from(params));
        return {
          'status': 'ok',
          'data': [51, 52].map(_memberJson).toList(),
          'total': '3210',
          'page': 1,
          'limit': 50,
          'analysis': {
            'total': '4528',
            'green': 3000,
            'yellow': 1200,
            'red': 328,
            'calculated_on': '2026-08-11',
          },
        };
      },
    );

    final result = await repository.searchMembers(
      query: 'a-0001',
      bloodType: 'O (Rh +)',
      availability: 'yellow',
      lastDonation: '2024',
      page: 1,
      limit: 50,
    );

    expect(result.members.map((member) => member.id), [51, 52]);
    expect(result.total, 3210);
    expect(result.analysis?.total, 4528);
    expect(result.analysis?.green, 3000);
    expect(result.analysis?.yellow, 1200);
    expect(result.analysis?.red, 328);
    expect(result.analysis?.calculatedOn, DateTime(2026, 8, 11));
    expect(result.hasMore, isTrue);
    expect(requests, hasLength(1));
    expect(requests.single['q'], 'a-0001');
    expect(requests.single['blood_type'], 'O (Rh +)');
    expect(requests.single['availability'], 'yellow');
    expect(requests.single['last_donation'], '2024');
    expect(requests.single['page'], 1);
    expect(requests.single['limit'], 50);
  });

  test('without total, hasMore follows whether the page is full', () async {
    final requestedPages = <int>[];
    final sentParams = <Map<String, dynamic>>[];
    final repository = SearchMemberRepository(
      pageLoader: (params) async {
        final page = params['page'] as int;
        requestedPages.add(page);
        sentParams.add(Map<String, dynamic>.from(params));
        return {
          'status': 'ok',
          'data': [_memberJson(1), _memberJson(2)],
        };
      },
    );

    final result = await repository.searchMembers(limit: 2);

    expect(result.members.map((member) => member.id), [1, 2]);
    expect(result.hasMore, isTrue);
    expect(requestedPages, [0]);
    // An unset year filter must not narrow the directory server-side.
    expect(sentParams.single.containsKey('last_donation'), isFalse);
  });

  test('directory controller appends pages and stops at the server total',
      () async {
    final repository = _PagedRepository();
    final controller = SearchMemberDirectoryController(
      repository: repository,
      query: null,
      bloodType: null,
      availability: null,
      lastDonation: null,
    );
    addTearDown(controller.dispose);

    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(controller.state.asData!.value.members, hasLength(50));
    expect(controller.state.asData!.value.hasMore, isTrue);

    await controller.loadNextPage();
    expect(controller.state.asData!.value.members, hasLength(100));
    expect(controller.state.asData!.value.hasMore, isTrue);

    await controller.loadNextPage();
    expect(controller.state.asData!.value.members, hasLength(120));
    expect(controller.state.asData!.value.hasMore, isFalse);

    await controller.loadNextPage();
    expect(repository.requestedPages, [0, 1, 2]);
  });

  test('an older append cannot overwrite a refreshed first page', () async {
    final repository = _RefreshRaceRepository();
    final controller = SearchMemberDirectoryController(
      repository: repository,
      query: null,
      bloodType: null,
      availability: null,
      lastDonation: null,
    );
    addTearDown(controller.dispose);

    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
    expect(controller.state.asData!.value.members.single.id, 1);

    final staleAppend = controller.loadNextPage();
    await Future<void>.delayed(Duration.zero);
    await controller.refresh();
    expect(controller.state.asData!.value.members.single.id, 99);

    repository.nextPage.complete(
      SearchMemberPage(
        members: [Member(id: 2, memberId: 'M-2', status: 'available')],
        total: 2,
        analysis: const SearchMemberAnalysis(
          total: 2,
          green: 2,
          yellow: 0,
          red: 0,
        ),
        page: 1,
        limit: 1,
      ),
    );
    await staleAppend;

    expect(controller.state.asData!.value.members.single.id, 99);
  });
}
