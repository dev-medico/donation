// Phone-viewport fixture test for the mobile report page: the blood-group and
// hospital tables and the age chart must lay out completely on 320- and
// 390-pixel-wide phones — nothing clipped, nothing overflowing, columns
// aligned under their headers.
//
// Pass --dart-define=REPORT_CAPTURE_DIR=design-qa to also write
// report-<w>x<h>.png captures of the whole page for visual QA.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:donation/src/features/donation/blood_request_give_chart.dart';
import 'package:donation/src/features/donation/donation_chart_by_blood.dart';
import 'package:donation/src/features/donation/donation_chart_by_hospital.dart';
import 'package:donation/src/features/finder/blood_donation_gender_pie_chart.dart';
import 'package:donation/src/features/finder/blood_donation_pie_chart.dart'
    as disease;
import 'package:donation/src/features/finder/report_mobile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _captureDir =
    String.fromEnvironment('REPORT_CAPTURE_DIR', defaultValue: '');

/// The app's Burmese font, so text measures as it does on a device.
Future<void> _loadBurmeseFont() async {
  final bytes =
      await File('assets/fonts/MyanUni/pds_regular.ttf').readAsBytes();
  final loader = FontLoader('MyanUni')
    ..addFont(Future.value(ByteData.view(bytes.buffer)));
  await loader.load();
}

const _hospitals = <String, int>{
  'ငွေမိုးဆေးရုံ': 4851,
  'မော်လမြိုင်ပြည်သူ့ဆေးရုံကြီး': 3665,
  'ဇာနည်ဘွားဆေးရုံ': 2126,
  'တော်ဝင်ဆေးရုံ': 1496,
  'ရတနာမွန်ဆေးရုံ': 978,
  'မေတ္တာရိပ်ဆေးခန်း': 957,
  'ရွှေလမင်းဆေးရုံ': 800,
  'အမေရိကန်ဆေးရုံ': 183,
  'ချမ်းမြေ့ဂုဏ်ဆေးခန်း': 87,
  'ကျိုက်မရောဆေးရုံ': 61,
  'မုဒုံဆေးရုံ': 58,
  'သံဖြူဇရပ်ဆေးရုံ': 42,
};

List<Override> _fixtureOverrides() => [
      bloodTypeStatsProvider.overrideWith((ref) async => {
            'data': {
              'A (Rh +)': 3590,
              'B (Rh +)': 4706,
              'AB (Rh +)': 1203,
              'O (Rh +)': 5880,
              'A (Rh -)': 24,
              'B (Rh -)': 39,
              'AB (Rh -)': 10,
              'O (Rh -)': 52,
            },
            'totalDonations': 15504,
          }),
      hospitalStatsProvider.overrideWith((ref) async => {
            'data': _hospitals,
            'totalDonations': 15504,
          }),
      genderStatsProvider.overrideWith((ref) async => {
            'genderStats': [
              {'patient_gender': 'male', 'quantity': 8890, 'percentage': 57},
              {'patient_gender': 'female', 'quantity': 6614, 'percentage': 43},
            ],
            'averageAge': 29,
            'ageRanges': {
              '18-25': 1806,
              '26-35': 1839,
              '36-45': 618,
              '46+': 196,
            },
            'totalDonations': 15504,
            'totalMembers': 4459,
          }),
      disease.diseaseStatsProvider.overrideWith((ref) async => [
            disease.DonationModel(disease: 'သွေးအားနည်း', quantity: 4200),
            disease.DonationModel(disease: 'ခွဲစိတ်', quantity: 3100),
            disease.DonationModel(disease: 'မီးဖွား', quantity: 2600),
            disease.DonationModel(disease: 'သလက်စီးမီးယား', quantity: 1900),
            disease.DonationModel(disease: 'အခြား', quantity: 3704),
          ]),
      requestGiveStatsProvider.overrideWith((ref) async => [
            {'month': 4, 'year': 2026, 'request': 120, 'give': 110},
            {'month': 5, 'year': 2026, 'request': 140, 'give': 132},
            {'month': 6, 'year': 2026, 'request': 133, 'give': 128},
            {'month': 7, 'year': 2026, 'request': 151, 'give': 149},
            {'month': 8, 'year': 2026, 'request': 160, 'give': 154},
            {'month': 9, 'year': 2026, 'request': 48, 'give': 45},
          ]),
    ];

/// Pumps the mobile report page for a [phone]-sized MediaQuery on a canvas
/// tall enough to lay out every section at once, and returns any framework
/// errors (overflows and the like) raised while doing so.
Future<List<FlutterErrorDetails>> _pumpReport(
    WidgetTester tester, Size phone) async {
  await tester.binding.setSurfaceSize(Size(phone.width, 2600));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final errors = <FlutterErrorDetails>[];
  final previous = FlutterError.onError;
  FlutterError.onError = errors.add;
  try {
    await tester.pumpWidget(
      ProviderScope(
        overrides: _fixtureOverrides(),
        child: MaterialApp(
          theme: ThemeData(fontFamily: 'MyanUni'),
          home: MediaQuery(
            data: MediaQueryData(size: phone, devicePixelRatio: 1),
            child: const Scaffold(
              backgroundColor: Color(0xfff2f2f2),
              body: ReportMobileScreen(),
            ),
          ),
        ),
      ),
    );
    // Fixed pumps rather than pumpAndSettle: the charts' entrance animations
    // finish well within 3s of fake time, and an endlessly animating widget
    // cannot hang the test.
    for (var i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  } finally {
    FlutterError.onError = previous;
  }
  return errors;
}

/// Unmounts the page. The chart library marks an already-disposed render
/// object dirty while its elements unmount, which the test binding would
/// otherwise report as a failure; that one known library assertion is
/// swallowed here and anything else is rethrown.
Future<void> _unmount(WidgetTester tester) async {
  final previous = FlutterError.onError;
  final unexpected = <FlutterErrorDetails>[];
  FlutterError.onError = (details) {
    if (!details.exceptionAsString().contains('disposed RenderObject')) {
      unexpected.add(details);
    }
  };
  try {
    await tester.pumpWidget(const SizedBox());
  } finally {
    FlutterError.onError = previous;
  }
  for (final details in unexpected) {
    previous!(details);
  }
}

Future<void> _capture(WidgetTester tester, Size phone) async {
  if (_captureDir.isEmpty) return;
  await tester.runAsync(() async {
    final image =
        await captureImage(find.byType(MaterialApp).evaluate().single);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('$_captureDir/report-${phone.width.toInt()}x'
        '${phone.height.toInt()}.png');
    file.writeAsBytesSync(bytes!.buffer.asUint8List());
    // ignore: avoid_print
    print('wrote ${file.path}');
  });
}

/// A single-line Text renders no taller than one and a half times its font.
void _expectSingleLine(WidgetTester tester, Finder finder, String what) {
  final paragraph = tester.renderObject<RenderParagraph>(finder);
  final fontSize = paragraph.text.style?.fontSize ?? 14;
  expect(tester.getSize(finder).height, lessThan(fontSize * 1.9),
      reason: '$what should fit on one line');
}

void _checkTables(WidgetTester tester, Size phone) {
  final headers = find.text('အရေအတွက်');
  expect(headers, findsNWidgets(2));
  for (final header in headers.evaluate()) {
    _expectSingleLine(tester, find.byWidget(header.widget), 'count header');
  }

  // Every hospital row is on the page, with its share of the total.
  for (final entry in _hospitals.entries) {
    expect(find.text(entry.key), findsOneWidget);
    expect(find.text(entry.value.toString()), findsOneWidget);
  }
  expect(find.text('31.3'), findsOneWidget); // 4851 / 15504
  expect(find.text('23.2'), findsOneWidget); // 3590 / 15504
  expect(find.text('100.0'), findsNWidgets(2));

  // Values sit under their headers: right edges of the count column agree.
  final hospitalHeader = tester.getRect(headers.last);
  final topCount = tester.getRect(find.text('4851'));
  final lastCount = tester.getRect(find.text('42'));
  expect((topCount.right - hospitalHeader.right).abs(), lessThan(1.0));
  expect((lastCount.right - hospitalHeader.right).abs(), lessThan(1.0));

  // Nothing pokes past the phone's width.
  for (final text in ['31.3', '0.3', '%']) {
    for (final element in find.text(text).evaluate()) {
      expect(tester.getRect(find.byWidget(element.widget)).right,
          lessThanOrEqualTo(phone.width));
    }
  }

  // The two tables keep their 20px gap instead of touching.
  final blood = tester.getRect(find.byType(DonationChartByBlood));
  final hospital = tester.getRect(find.byType(DonationChartByHospital));
  expect(hospital.top - blood.bottom, greaterThanOrEqualTo(20));
}

void _checkAgeChart(WidgetTester tester, Size phone) {
  expect(find.text('ပျမ်းမျှ အသက်'), findsOneWidget);
  expect(find.text('29 နှစ်'), findsOneWidget);
  expect(find.text('ကျား - 8890'), findsOneWidget);
  expect(find.text('မ - 6614'), findsOneWidget);

  // All four legend entries are visible and inside the screen.
  for (final label in ['18-25 - 1806', '26-35 - 1839', '36-45 - 618', '46+ - 196']) {
    final entry = find.text(label);
    expect(entry, findsOneWidget);
    final rect = tester.getRect(entry);
    expect(rect.right, lessThanOrEqualTo(phone.width));
    expect(rect.left, greaterThanOrEqualTo(0));
  }
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await _loadBurmeseFont();
  });

  for (final phone in const [Size(320, 568), Size(390, 844)]) {
    testWidgets(
        'report tables and age chart lay out on a '
        '${phone.width.toInt()}x${phone.height.toInt()} phone', (tester) async {
      // Captures show real elevation shadows rather than the test renderer's
      // black outlines. The flag must be back to its default before the test
      // body returns, or the binding reports it as a leaked debug setting.
      if (_captureDir.isNotEmpty) debugDisableShadows = false;
      try {
        final errors = await _pumpReport(tester, phone);
        expect(errors.map((e) => e.exceptionAsString()), isEmpty);

        _checkTables(tester, phone);
        _checkAgeChart(tester, phone);

        await _capture(tester, phone);
        await _unmount(tester);
      } finally {
        debugDisableShadows = true;
      }
    });
  }
}
