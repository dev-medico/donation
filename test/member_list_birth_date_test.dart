import 'package:donation/src/features/donation_member/data/member_repository.dart';
import 'package:donation/src/features/donation_member/domain/member.dart';
import 'package:donation/src/features/donation_member/domain/member_range.dart';
import 'package:donation/src/features/donation_member/presentation/controller/member_provider.dart';
import 'package:donation/src/features/donation_member/presentation/member_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Two members who share a name and a father's name — the case the phone rows
/// have to disambiguate.
final _namesakes = <Member>[
  Member(
    id: 1,
    memberId: 'A-0278',
    name: 'ကိုပြည့်ဖြိုးအောင်',
    fatherName: 'ဦးငွေးအောင်',
    bloodType: 'A (Rh +)',
    birthDate: '12 Mar 1995',
    totalCount: '10',
    status: 'available',
  ),
  Member(
    id: 2,
    memberId: 'A-0333',
    name: 'ကိုပြည့်ဖြိုးအောင်',
    fatherName: 'ဦးငွေးအောင်',
    bloodType: 'B (Rh +)',
    birthDate: '4 Jan 2001',
    totalCount: '6',
    status: 'available',
  ),
  Member(
    id: 3,
    memberId: 'A-0393',
    name: 'ကိုပြည့်ဖြိုးအောင်',
    fatherName: 'ဦးစိုးအောင်',
    bloodType: 'A (Rh +)',
    totalCount: '2',
    status: 'available',
  ),
];

class _FakeMemberRepository extends MemberRepository {
  @override
  Future<Map<String, dynamic>> getMembersPaginated({
    int page = 0,
    int limit = 50,
    String? query,
    String? bloodType,
    String? phone,
    String? fatherName,
    String? bloodBankCard,
    String? memberIdSearch,
    String? birthDate,
  }) async {
    return {
      'members': _namesakes,
      'hasMore': false,
      'total': _namesakes.length,
    };
  }

  @override
  Future<List<MemberRange>> getMemberRanges({String? bloodType}) async =>
      const <MemberRange>[];

  @override
  Future<List<Member>> getAllMembers({bool forceRefresh = false}) async =>
      _namesakes;
}

void main() {
  testWidgets('phone rows show the birth date so namesakes can be told apart',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          memberRepositoryProvider.overrideWithValue(_FakeMemberRepository()),
        ],
        child: const MaterialApp(home: MemberListScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('12 Mar 1995'), findsOneWidget);
    expect(find.text('4 Jan 2001'), findsOneWidget);
    expect(find.byKey(const ValueKey('member-birth-date-1')), findsOneWidget);
    expect(find.byKey(const ValueKey('member-birth-date-2')), findsOneWidget);

    // A member without a stored birth date keeps the shorter two-line row.
    expect(find.byKey(const ValueKey('member-birth-date-3')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
