import 'package:donation/src/features/donation/donation_detail.dart';
import 'package:donation/src/features/donation/models/donation.dart';
import 'package:donation/src/features/donation_member/domain/member.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

Donation _fixture() => Donation(
      id: 15233,
      member: '4007',
      donationDate: DateTime(2026, 8, 1),
      hospital: 'ငွေမိုးဆေးရုံ',
      patientName: '',
      memberId: '4007',
      memberObj: Member(
        id: 4007,
        memberId: 'E-0007',
        name: 'ကိုသက်အောင်လင်း',
        fatherName: 'ဦးမျိုးမင်းဦး',
        bloodType: 'B (Rh +)',
        birthDate: '07 May 2001',
        bloodBankCard: '07-',
      ),
    );

void main() {
  testWidgets('mobile donor metadata uses one left-aligned definition grid',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: DonationDetailScreen(data: _fixture(), isPreview: true),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('07-'),
      260,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    const labels = [
      'အဖွဲ့ဝင်အမှတ်',
      'အမည်',
      'အဖအမည်',
      'သွေးအုပ်စု',
      'မွေးသက္ကရာဇ်',
      'သွေးဘဏ်ကတ်',
    ];
    const values = [
      'E-0007',
      'ကိုသက်အောင်လင်း',
      'ဦးမျိုးမင်းဦး',
      'B (Rh +)',
      '07 May 2001',
      '07-',
    ];

    final labelX =
        labels.map((label) => tester.getTopLeft(find.text(label)).dx).toList();
    final valueX =
        values.map((value) => tester.getTopLeft(find.text(value)).dx).toList();

    for (final x in labelX.skip(1)) {
      expect(x, closeTo(labelX.first, 0.5));
    }
    for (final x in valueX.skip(1)) {
      expect(x, closeTo(valueX.first, 0.5));
    }
    expect(labelX.first, lessThan(60));
    expect(valueX.first, greaterThan(labelX.first + 100));
    expect(find.byTooltip('အဖွဲ့ဝင်အချက်အလက် ကြည့်ရန်'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
