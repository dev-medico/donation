import 'package:donation/src/features/donation_member/domain/member.dart';
import 'package:donation/src/features/smart_search/domain/smart_search_models.dart';
import 'package:donation/src/features/smart_search/presentation/widget/compact_donor_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The default density used to throw the ranking explanation away: the reasons
/// only reached the screen as a tooltip on the tier chip, and that chip is
/// absent when the donor has no location tier. Both compact rows now carry the
/// reasons as a visible one-line caption.
RankedDonor _donor({
  String locationTier = 'ward',
  List<String> reasons = const ['လှူနိုင်', 'ရပ်ကွက်တူ', '5 ကြိမ်လှူပြီး'],
}) {
  return RankedDonor(
    member: Member(
      id: 7,
      memberId: 'A-0007',
      name: 'မတင်တင်',
      bloodType: 'B (Rh +)',
      phone: '09777000111',
      totalCount: '5',
    ),
    rankScore: 137,
    rankReasons: reasons,
    availabilityState: 'green',
    townshipLabel: 'မော်လမြိုင်',
    wardKey: 'ဇေယျာသီရိရပ်ကွက်',
    locationTier: locationTier,
    bloodGroup: 'B+',
    lastDonationDate: '2026-03-01 00:00:00',
    lastHospital: 'ငွေမိုးဆေးရုံ',
  );
}

Future<void> _pump(WidgetTester tester, Widget child, double width) async {
  await tester.binding.setSurfaceSize(Size(width, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(width: width, child: child),
      ),
    ),
  );
}

void main() {
  const caption = 'လှူနိုင် · ရပ်ကွက်တူ · 5 ကြိမ်လှူပြီး';

  group('phone row', () {
    testWidgets('shows the reasons on their own line', (tester) async {
      await _pump(
        tester,
        CompactDonorRow(rank: 1, donor: _donor(), onTap: () {}),
        320,
      );

      expect(find.text(caption), findsOneWidget);
    });

    testWidgets('still shows them when the donor has no location tier',
        (tester) async {
      await _pump(
        tester,
        CompactDonorRow(
          rank: 1,
          donor: _donor(locationTier: ''),
          onTap: () {},
        ),
        320,
      );

      expect(find.byType(TierChip), findsNothing);
      expect(find.text(caption), findsOneWidget);
    });

    testWidgets('a donor with no reasons gets no empty line', (tester) async {
      await _pump(
        tester,
        CompactDonorRow(
          rank: 1,
          donor: _donor(reasons: const []),
          onTap: () {},
        ),
        320,
      );

      expect(find.byType(ReasonCaption), findsNothing);
    });
  });

  group('table row', () {
    testWidgets('shows the reasons and keeps its 46px density at 640',
        (tester) async {
      const width = 640.0;
      await _pump(
        tester,
        DonorTableRow(
          rank: 1,
          donor: _donor(),
          layout: const DonorTableLayout(width: width - 24),
          onTap: () {},
        ),
        width,
      );

      expect(find.text(caption), findsOneWidget);
      expect(tester.getSize(find.byType(DonorTableRow)).height, 46);
    });

    testWidgets('keeps its density on a laptop-width table', (tester) async {
      const width = 1280.0;
      await _pump(
        tester,
        DonorTableRow(
          rank: 1,
          donor: _donor(),
          layout: const DonorTableLayout(width: width - 24),
          onTap: () {},
        ),
        width,
      );

      expect(find.text(caption), findsOneWidget);
      expect(tester.getSize(find.byType(DonorTableRow)).height, 46);
    });

    testWidgets('the header still lines up with the rows', (tester) async {
      const width = 640.0;
      const layout = DonorTableLayout(width: width - 24);
      await _pump(
        tester,
        Column(
          children: [
            const DonorTableHeader(layout: layout),
            DonorTableRow(
              rank: 1,
              donor: _donor(),
              layout: layout,
              onTap: () {},
            ),
          ],
        ),
        width,
      );

      // The name column header and the donor name start at the same x.
      final header = tester.getTopLeft(find.text('အမည် · သွေးအုပ်စု'));
      final name = tester.getTopLeft(find.text('မတင်တင်'));
      expect(name.dx, closeTo(header.dx, 0.5));
    });
  });
}
