import 'package:donation/src/features/donation/new_blood_donation.dart';
import 'package:donation/src/features/donation_member/data/member_repository.dart';
import 'package:donation/src/features/donation_member/domain/member.dart';
import 'package:donation/src/features/donation_member/presentation/controller/member_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class _TrackingMemberRepository extends MemberRepository {
  int initialLoadRequestCount = 0;
  int requestCount = 0;
  String? lastQuery;

  @override
  Future<List<Member>> getAllMembers({bool forceRefresh = false}) async {
    initialLoadRequestCount += 1;
    return const <Member>[];
  }

  @override
  Future<List<Member>> getInitialMembers({
    int limit = 50,
    String? query,
    String? bloodType,
    String? phone,
    String? fatherName,
    String? bloodBankCard,
    String? memberIdSearch,
    String? birthDate,
  }) async {
    requestCount += 1;
    lastQuery = query;
    return [
      Member(
        id: 1,
        memberId: 'B-0001',
        name: 'Test donor',
        bloodType: 'O (Rh +)',
      ),
    ];
  }
}

void main() {
  testWidgets('donation form renders before donors are searched',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final repository = _TrackingMemberRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          memberRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(home: NewBloodDonationScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('သွေးလှူဒါန်းသူ ရွေးချယ်ရန်'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(repository.initialLoadRequestCount, 0);
    expect(repository.requestCount, 0);

    final donorField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.labelText == 'သွေးလှူဒါန်းသူ အမည်',
    );
    expect(donorField, findsOneWidget);

    await tester.enterText(donorField, 'A');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(repository.requestCount, 0);

    await tester.enterText(donorField, 'AB');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(repository.requestCount, 1);
    expect(repository.lastQuery, 'AB');
    expect(find.text('Test donor'), findsOneWidget);
  });
}
