import 'dart:math' as math;

import 'package:donation/src/features/donation_member/data/search_member_repository.dart';
import 'package:donation/src/features/donation_member/domain/donor_eligibility.dart';
import 'package:donation/src/features/donation_member/domain/member.dart';
import 'package:donation/src/features/donation_member/presentation/controller/member_provider.dart';
import 'package:donation/src/features/donation_member/presentation/search_member.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class _ClassificationRepository extends SearchMemberRepository {
  final availabilityRequests = <String?>[];

  List<Member> get _members {
    final recent = DateTime.now().subtract(const Duration(days: 30));
    return [
      Member(
        id: 1,
        memberId: 'A-0001',
        name: 'လှူနိုင်သူ',
        bloodType: 'O (Rh +)',
        phone: '091111111',
        status: 'available',
      ),
      Member(
        id: 2,
        memberId: 'A-0002',
        name: 'မှတ်ချက်ရှိသူ',
        bloodType: 'A (Rh +)',
        phone: '092222222',
        status: 'available',
        note: 'ဆရာဝန်နှင့် တိုင်ပင်ပြီး ဖုန်းဆက်အတည်ပြုမှသာ လှူဒါန်းရန်',
      ),
      Member(
        id: 3,
        memberId: 'A-0003',
        name: 'လေးလမပြည့်သူ',
        bloodType: 'B (Rh +)',
        phone: '093333333',
        status: 'available',
        lastDate: recent.toIso8601String(),
      ),
      Member(
        id: 4,
        memberId: 'A-0004',
        name: 'ပိတ်ထားသူ',
        bloodType: 'AB (Rh -)',
        status: 'not_available',
        note: '-',
      ),
    ];
  }

  @override
  Future<SearchMemberPage> searchMembers({
    String? query,
    String? bloodType,
    String? availability,
    int page = 0,
    int limit = 50,
  }) async {
    availabilityRequests.add(availability);
    final normalizedQuery = (query ?? '').trim().toLowerCase();
    final base = _members.where((member) {
      final matchesQuery = normalizedQuery.isEmpty ||
          (member.name ?? '').toLowerCase().contains(normalizedQuery) ||
          (member.memberId ?? '').toLowerCase().contains(normalizedQuery) ||
          (member.phone ?? '').toLowerCase().contains(normalizedQuery);
      return matchesQuery &&
          (bloodType == null || member.bloodType == bloodType);
    }).toList();
    final analysis = _analysis(base);
    final filtered = availability == null
        ? base
        : base
            .where((member) =>
                DonorEligibility.fromMember(member).level.apiValue ==
                availability)
            .toList();
    final start = page * limit;
    final end = math.min(start + limit, filtered.length);
    return SearchMemberPage(
      members:
          start >= filtered.length ? const [] : filtered.sublist(start, end),
      total: filtered.length,
      analysis: analysis,
      page: page,
      limit: limit,
    );
  }
}

class _ManyMemberRepository extends SearchMemberRepository {
  @override
  Future<SearchMemberPage> searchMembers({
    String? query,
    String? bloodType,
    String? availability,
    int page = 0,
    int limit = 50,
  }) async {
    final members = List.generate(
      25,
      (index) => Member(
        id: index + 1,
        memberId: 'M-${index + 1}',
        name: 'သွေးလှူရှင် ${index + 1}',
        bloodType: 'O (Rh +)',
        phone: '09111${index.toString().padLeft(4, '0')}',
        status: 'available',
      ),
    );
    return SearchMemberPage(
      members: members,
      total: members.length,
      analysis: _analysis(members),
      page: page,
      limit: limit,
    );
  }
}

class _ThousandsRepository extends SearchMemberRepository {
  final availabilityRequests = <String?>[];

  @override
  Future<SearchMemberPage> searchMembers({
    String? query,
    String? bloodType,
    String? availability,
    int page = 0,
    int limit = 50,
  }) async {
    availabilityRequests.add(availability);
    final requestedLevel = switch (availability) {
      'yellow' => DonorEligibilityLevel.caution,
      'red' => DonorEligibilityLevel.disabled,
      _ => DonorEligibilityLevel.eligible,
    };
    final members = List.generate(
      limit,
      (index) => Member(
        id: page * limit + index + 1,
        memberId: 'M-${page * limit + index + 1}',
        name: 'သွေးလှူရှင် ${page * limit + index + 1}',
        bloodType: 'O (Rh +)',
        phone: '09111${index.toString().padLeft(4, '0')}',
        status: requestedLevel == DonorEligibilityLevel.disabled
            ? 'not_available'
            : 'available',
        note: requestedLevel == DonorEligibilityLevel.caution
            ? 'ဖုန်းဆက်အတည်ပြုရန်'
            : null,
      ),
    );
    const analysis = SearchMemberAnalysis(
      total: 12345,
      green: 6000,
      yellow: 5000,
      red: 1345,
    );
    final selectedTotal = switch (availability) {
      'green' => analysis.green,
      'yellow' => analysis.yellow,
      'red' => analysis.red,
      _ => analysis.total,
    };
    return SearchMemberPage(
      members: members,
      total: selectedTotal,
      analysis: analysis,
      page: page,
      limit: limit,
    );
  }
}

SearchMemberAnalysis _analysis(List<Member> members) {
  var green = 0;
  var yellow = 0;
  var red = 0;
  for (final member in members) {
    switch (DonorEligibility.fromMember(member).level) {
      case DonorEligibilityLevel.eligible:
        green += 1;
      case DonorEligibilityLevel.caution:
        yellow += 1;
      case DonorEligibilityLevel.disabled:
        red += 1;
    }
  }
  return SearchMemberAnalysis(
    total: members.length,
    green: green,
    yellow: yellow,
    red: red,
  );
}

Future<void> _pumpScreen(
  WidgetTester tester, {
  required Size size,
  required SearchMemberRepository repository,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        searchMemberRepositoryProvider.overrideWithValue(repository),
      ],
      child: const MaterialApp(home: SearchMemberListScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _revealAndTapAvailabilityChip(
  WidgetTester tester,
  ValueKey<String> key,
) async {
  await tester.drag(
    find.byType(SingleChildScrollView).first,
    const Offset(-320, 0),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(key));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('mobile shows all classifications, full remark, and direct edit',
      (tester) async {
    final repository = _ClassificationRepository();
    await _pumpScreen(
      tester,
      size: const Size(390, 844),
      repository: repository,
    );

    expect(find.text('အားလုံး 4'), findsOneWidget);
    expect(find.byKey(const ValueKey('donor-card-1')), findsOneWidget);
    expect(find.text('လှူနိုင်သူ'), findsOneWidget);
    expect(find.byKey(const ValueKey('donor-card-3')), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('donor-card-2')),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(
      find.text('ဆရာဝန်နှင့် တိုင်ပင်ပြီး ဖုန်းဆက်အတည်ပြုမှသာ လှူဒါန်းရန်'),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('donor-card-3')),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('၄ လ မပြည့်သေး'), findsWidgets);
    expect(find.textContaining('၄ လပြည့်ရန်'), findsWidgets);
    expect(find.textContaining('တွင် လှူနိုင်'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('donor-card-4')),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('ပိတ်ထားသူ'), findsOneWidget);
    expect(find.text('ပိတ်ထားသည်'), findsOneWidget);
    expect(find.byKey(const ValueKey('edit-donor-4')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('availability chips filter the complete result set',
      (tester) async {
    final repository = _ClassificationRepository();
    await _pumpScreen(
      tester,
      size: const Size(390, 844),
      repository: repository,
    );

    var list = tester.widget<ListView>(
      find.byKey(const ValueKey('all-donor-results')),
    );
    expect(list.semanticChildCount, 4);

    await _revealAndTapAvailabilityChip(
      tester,
      const ValueKey('eligibility-filter-caution'),
    );
    list = tester.widget<ListView>(
      find.byKey(const ValueKey('all-donor-results')),
    );
    expect(list.semanticChildCount, 2);
    expect(find.byKey(const ValueKey('donor-card-1')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('eligibility-filter-all')));
    await tester.pumpAndSettle();
    list = tester.widget<ListView>(
      find.byKey(const ValueKey('all-donor-results')),
    );
    expect(list.semanticChildCount, 4);
  });

  testWidgets('global analysis stays correct while only one page is loaded',
      (tester) async {
    final repository = _ThousandsRepository();
    await _pumpScreen(
      tester,
      size: const Size(390, 844),
      repository: repository,
    );

    expect(find.text('အားလုံး 12,345'), findsOneWidget);
    expect(find.text('လှူနိုင် 6,000'), findsOneWidget);
    expect(find.text('စစ်ဆေးရန် 5,000'), findsOneWidget);
    expect(find.text('ပိတ်ထား 1,345'), findsOneWidget);
    expect(
      find.text('ကိုက်ညီသူ 12,345 ယောက်အနက် 50 ယောက် ပြထားသည်'),
      findsOneWidget,
    );
    expect(repository.availabilityRequests.last, isNull);

    await _revealAndTapAvailabilityChip(
      tester,
      const ValueKey('eligibility-filter-caution'),
    );

    expect(repository.availabilityRequests.last, 'yellow');
    expect(find.text('အားလုံး 12,345'), findsOneWidget);
    expect(
      find.text('စစ်ဆေးရန် 5,000 ယောက်အနက် 50 ယောက် ပြထားသည်'),
      findsOneWidget,
    );
    expect(find.text('မှတ်ချက်ရှိ'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mobile keeps all returned members scrollable', (tester) async {
    final repository = _ManyMemberRepository();
    await _pumpScreen(
      tester,
      size: const Size(390, 844),
      repository: repository,
    );

    expect(find.text('အားလုံး 25'), findsOneWidget);
    final list = tester.widget<ListView>(
      find.byKey(const ValueKey('all-donor-results')),
    );
    expect(list.semanticChildCount, 25);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('donor-card-25')),
      500,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.byKey(const ValueKey('donor-card-25')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('narrow mobile keeps compact actions without overflow',
      (tester) async {
    await _pumpScreen(
      tester,
      size: const Size(320, 568),
      repository: _ClassificationRepository(),
    );

    expect(find.byKey(const ValueKey('donor-card-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('edit-donor-1')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('desktop uses readable rows and keeps every donor available',
      (tester) async {
    final repository = _ClassificationRepository();
    await _pumpScreen(
      tester,
      size: const Size(1440, 900),
      repository: repository,
    );

    expect(find.text('အားလုံး 4'), findsOneWidget);
    expect(find.text('အခြေအနေ / မှတ်ချက်'), findsOneWidget);
    for (var id = 1; id <= 4; id += 1) {
      expect(find.byKey(ValueKey('donor-row-$id')), findsOneWidget);
    }
    expect(find.byKey(const ValueKey('eligibility-count-eligible')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('eligibility-count-caution')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('eligibility-count-disabled')),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
