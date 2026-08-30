import 'package:donation/src/features/donation_member/data/member_repository.dart';
import 'package:donation/src/features/donation_member/data/search_member_repository.dart';
import 'package:donation/src/features/donation_member/domain/member.dart';
import 'package:donation/src/features/donation_member/presentation/controller/member_provider.dart';
import 'package:donation/src/features/donation_member/presentation/search_member.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Serves one fixed directory page and counts how many times the screen asks
/// for it. Saving a remark must never trigger a second request.
class _DirectoryRepository extends SearchMemberRepository {
  int requestCount = 0;

  @override
  Future<SearchMemberPage> searchMembers({
    String? query,
    String? bloodType,
    String? availability,
    String? lastDonation,
    int page = 0,
    int limit = 50,
  }) async {
    requestCount += 1;
    return SearchMemberPage(
      members: [
        Member(
          id: 1,
          memberId: 'A-0001',
          name: 'ကိုအောင်မြင့်',
          bloodType: 'O (Rh +)',
          phone: '0911111111',
          status: 'available',
        ),
        Member(
          id: 2,
          memberId: 'A-0002',
          name: 'ကိုစည်သူ',
          bloodType: 'A (Rh +)',
          phone: '0922222222',
          status: 'available',
        ),
        Member(
          id: 3,
          memberId: 'A-0003',
          name: 'မမေသဇင်',
          bloodType: 'B (Rh +)',
          phone: '0933333333',
          status: 'available',
        ),
      ],
      total: 3,
      analysis: const SearchMemberAnalysis(
        total: 3,
        green: 3,
        yellow: 0,
        red: 0,
      ),
      page: 0,
      limit: 50,
    );
  }
}

class _RecordingMemberRepository extends MemberRepository {
  final updates = <({String id, bool canDonate, String note})>[];

  @override
  Future<Member> updateMemberAvailability(
    String id, {
    required bool canDonate,
    required String note,
  }) async {
    updates.add((id: id, canDonate: canDonate, note: note));
    // The real endpoint returns the raw member record without derived fields.
    return Member(
      id: int.parse(id),
      memberId: 'A-000$id',
      name: 'ကိုစည်သူ',
      status: canDonate ? 'available' : 'not_available',
      note: note,
    );
  }
}

void main() {
  testWidgets(
      'saving a remark updates the row in place: no refetch, no reorder',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final directoryRepository = _DirectoryRepository();
    final memberRepository = _RecordingMemberRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          searchMemberRepositoryProvider.overrideWithValue(
            directoryRepository,
          ),
          memberRepositoryProvider.overrideWithValue(memberRepository),
        ],
        child: const MaterialApp(home: SearchMemberListScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(directoryRepository.requestCount, 1);
    expect(find.byKey(const ValueKey('donor-card-1')), findsOneWidget);
    final firstCardTop = tester.getTopLeft(
      find.byKey(const ValueKey('donor-card-1')),
    );

    // Open the middle donor's edit dialog. It must say who is being edited.
    await tester.tap(find.byKey(const ValueKey('edit-donor-2')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('remark-member-identity')),
        matching: find.text('ကိုစည်သူ'),
      ),
      findsOneWidget,
    );

    // One tap on a quick remark fills the note field.
    await tester.ensureVisible(
      find.byKey(const ValueKey('quick-remark-ဖုန်းစက်ပိတ်ထား')),
    );
    await tester.tap(
      find.byKey(const ValueKey('quick-remark-ဖုန်းစက်ပိတ်ထား')),
    );
    await tester.pump();
    expect(find.widgetWithText(TextFormField, 'ဖုန်းစက်ပိတ်ထား'),
        findsOneWidget);

    await tester.ensureVisible(find.text('အချက်အလက် သိမ်းမည်'));
    await tester.tap(find.text('အချက်အလက် သိမ်းမည်'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // The save is confirmed by name, and the dialog is gone.
    expect(find.text('ကိုစည်သူ — သိမ်းဆည်းပြီးပါပြီ'), findsOneWidget);
    expect(
      memberRepository.updates,
      [(id: '2', canDonate: true, note: 'ဖုန်းစက်ပိတ်ထား')],
    );

    await tester.pumpAndSettle();

    // The directory was not re-fetched and the rows kept their order, so the
    // admin continues from the same place in the list.
    expect(directoryRepository.requestCount, 1);
    final tops = [1, 2, 3]
        .map((id) =>
            tester.getTopLeft(find.byKey(ValueKey('donor-card-$id'))).dy)
        .toList();
    expect(tops[0], lessThan(tops[1]));
    expect(tops[1], lessThan(tops[2]));
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('donor-card-1'))),
      firstCardTop,
    );

    // The edited row now shows the saved remark, and the availability
    // counters moved one donor from green to yellow without a round trip.
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('donor-card-2')),
        matching: find.text('ဖုန်းစက်ပိတ်ထား'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('eligibility-count-eligible')),
        matching: find.text('လှူနိုင် 2'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('eligibility-count-caution')),
        matching: find.text('စစ်ဆေးရန် 1'),
      ),
      findsOneWidget,
    );
  });
}
