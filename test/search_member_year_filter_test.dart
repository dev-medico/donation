import 'package:donation/src/features/donation_member/data/search_member_repository.dart';
import 'package:donation/src/features/donation_member/domain/last_donation_filter.dart';
import 'package:donation/src/features/donation_member/domain/member.dart';
import 'package:donation/src/features/donation_member/presentation/controller/member_provider.dart';
import 'package:donation/src/features/donation_member/presentation/search_member.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Records what the screen asked the server for. The filter is resolved on the
/// backend against the effective last donation date, so the only thing the app
/// can be tested on is the request it sends.
class _RecordingRepository extends SearchMemberRepository {
  final lastDonationRequests = <String?>[];

  @override
  Future<SearchMemberPage> searchMembers({
    String? query,
    String? bloodType,
    String? availability,
    String? lastDonation,
    int page = 0,
    int limit = 50,
  }) async {
    lastDonationRequests.add(lastDonation);
    final members = [
      Member(
        id: 1,
        memberId: 'A-0001',
        name: 'အေးအေး',
        bloodType: 'O (Rh +)',
        phone: '091111111',
        status: 'available',
      ),
    ];
    return SearchMemberPage(
      members: members,
      total: members.length,
      analysis: const SearchMemberAnalysis(
        total: 1,
        green: 1,
        yellow: 0,
        red: 0,
      ),
      page: page,
      limit: limit,
    );
  }
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required Size size,
  required SearchMemberRepository repository,
}) async {
  // Find Blood picks its phone/desktop layout from MediaQuery.size, which
  // setSurfaceSize does not move — only the view's own metrics do.
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(
    ProviderScope(
      overrides: [searchMemberRepositoryProvider.overrideWithValue(repository)],
      child: const MaterialApp(home: SearchMemberListScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _selectFromYearMenu(WidgetTester tester, String label) async {
  await tester.tap(find.byKey(const ValueKey('last-donation-filter-all')));
  await tester.pumpAndSettle();

  final option = find.text(label);
  for (var attempt = 0; attempt < 10 && option.evaluate().isEmpty; attempt++) {
    await tester.drag(
      find.byType(Scrollable).last,
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
  }
  expect(option, findsWidgets);
  await tester.tap(option.last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('picking a year asks the server for that exact year', (
    tester,
  ) async {
    final repository = _RecordingRepository();
    await _pumpScreen(
      tester,
      size: const Size(390, 844),
      repository: repository,
    );

    expect(repository.lastDonationRequests, [null]);

    final year = LastDonationFilter.menuYears(DateTime.now()).first;
    await _selectFromYearMenu(tester, '$year');

    expect(repository.lastDonationRequests, [null, '$year']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the oldest ledger year remains selectable', (tester) async {
    final repository = _RecordingRepository();
    await _pumpScreen(
      tester,
      size: const Size(390, 844),
      repository: repository,
    );

    await _selectFromYearMenu(
      tester,
      '${LastDonationFilter.firstRecordedYear}',
    );

    expect(
      repository.lastDonationRequests,
      [null, '${LastDonationFilter.firstRecordedYear}'],
    );
  });

  testWidgets('never-donated members can be requested on their own', (
    tester,
  ) async {
    final repository = _RecordingRepository();
    await _pumpScreen(
      tester,
      size: const Size(390, 844),
      repository: repository,
    );

    await _selectFromYearMenu(tester, 'မလှူရသေးပါ');

    expect(repository.lastDonationRequests, [null, 'never']);
  });

  testWidgets('clearing the filters drops the year again', (tester) async {
    final repository = _RecordingRepository();
    await _pumpScreen(
      tester,
      size: const Size(390, 844),
      repository: repository,
    );

    final year = LastDonationFilter.menuYears(DateTime.now()).first;
    await _selectFromYearMenu(tester, '$year');
    expect(repository.lastDonationRequests.last, '$year');

    // The year alone is enough to offer "clear all filters".
    await tester.tap(find.byKey(const ValueKey('clear-member-filters')));
    await tester.pumpAndSettle();

    expect(repository.lastDonationRequests, [null, '$year', null]);
    expect(
      find.byKey(const ValueKey('last-donation-filter-all')),
      findsOneWidget,
    );
  });

  testWidgets('the desktop layout offers the same filter', (tester) async {
    final repository = _RecordingRepository();
    await _pumpScreen(
      tester,
      size: const Size(1280, 800),
      repository: repository,
    );

    await _selectFromYearMenu(tester, 'မလှူရသေးပါ');

    expect(repository.lastDonationRequests, [null, 'never']);
  });
}
