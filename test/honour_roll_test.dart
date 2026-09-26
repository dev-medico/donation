// Honour roll: the bands the group asked for (10–19, 20–29, 30–39, 40–49,
// then 50+ once someone reaches it), the per-donor breakdown, and a phone
// layout with nothing overflowing at 320 and 390 pixels wide.
//
// Pass --dart-define=HONOUR_CAPTURE_DIR=design-qa to also write
// honour-roll-<band>-<w>x<h>.png captures for visual QA.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:donation/src/features/donation_member/domain/honour_roll.dart';
import 'package:donation/src/features/donation_member/honorable_donors_screen.dart';
import 'package:donation/src/features/services/member_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const _captureDir =
    String.fromEnvironment('HONOUR_CAPTURE_DIR', defaultValue: '');

Map<String, dynamic> _donor(
  int id,
  String cardNo,
  String name,
  String bloodType,
  int previous,
  int recorded,
) =>
    {
      'id': id,
      'member_id': cardNo,
      'name': name,
      'blood_type': bloodType,
      'gender': 'male',
      'profile_url': null,
      'member_count': '$previous',
      'total_count': '${previous + recorded}',
      'donation_counts': {
        'before_joining': previous,
        'in_system': recorded,
        'total': previous + recorded,
      },
    };

// Made-up donors: this repository is public, so no real names or card numbers.
final _fixture = [
  _donor(1, 'T-0001', 'ကိုအောင်အောင်', 'B (Rh +)', 46, 11),
  _donor(2, 'T-0002', 'မသန္တာ', 'O (Rh +)', 50, 7),
  _donor(3, 'T-0003', 'ဦးမောင်မောင်', 'A (Rh +)', 49, 2),
  _donor(4, 'T-0004', 'ကိုဇော်ဇော်', 'O (Rh +)', 36, 14),
  _donor(5, 'T-0005', 'မနီလာ', 'O (Rh +)', 29, 13),
  _donor(6, 'T-0006', 'ကိုမင်းမင်း', 'AB (Rh +)', 28, 12),
  _donor(7, 'T-0007', 'ကိုသန့်', 'B (Rh +)', 23, 13),
  _donor(8, 'T-0008', 'ကိုအောင်မြင့်ထွန်းဦး(ခ)ကိုအောင်မြင့်', 'O (Rh +)', 23,
      12),
  _donor(9, 'T-0009', 'မခင်ခင်', 'A (Rh -)', 15, 9),
  _donor(10, 'T-0010', 'ကိုကျော်ကျော်', 'A (Rh +)', 11, 1),
  _donor(11, 'T-0011', 'ကိုနန္ဒ', 'O (Rh +)', 2, 13),
  _donor(12, 'T-0012', 'ကိုမျိုး', 'B (Rh +)', 3, 12),
  _donor(13, 'T-0013', 'မသီတာ', 'O (Rh +)', 9, 1),
];

class _FakeMemberService extends MemberService {
  _FakeMemberService(this.rows);

  final List<Map<String, dynamic>> rows;
  int? requestedMin;

  @override
  Future<List<dynamic>> getHonorableDonors({int min = 30}) async {
    requestedMin = min;
    return rows;
  }
}

Future<void> _loadFonts() async {
  final bytes =
      await File('assets/fonts/MyanUni/pds_regular.ttf').readAsBytes();
  final loader = FontLoader('MyanUni')
    ..addFont(Future.value(ByteData.view(bytes.buffer)));
  await loader.load();

  // Icons only matter for the captures; without the font they draw as boxes.
  final sdk = Platform.environment['FLUTTER_ROOT'];
  final icons = File('$sdk/bin/cache/artifacts/material_fonts/'
      'MaterialIcons-Regular.otf');
  if (sdk != null && icons.existsSync()) {
    final iconBytes = await icons.readAsBytes();
    final iconLoader = FontLoader('MaterialIcons')
      ..addFont(Future.value(ByteData.view(iconBytes.buffer)));
    await iconLoader.load();
  }
}

Future<List<FlutterErrorDetails>> _pumpRoll(
  WidgetTester tester,
  Size phone,
  MemberService service,
) async {
  await tester.binding.setSurfaceSize(phone);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final errors = <FlutterErrorDetails>[];
  final previous = FlutterError.onError;
  FlutterError.onError = errors.add;
  try {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [memberServiceProvider.overrideWithValue(service)],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(fontFamily: 'MyanUni'),
          home: MediaQuery(
            data: MediaQueryData(size: phone, devicePixelRatio: 1),
            child: const HonorableDonorsScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  } finally {
    FlutterError.onError = previous;
  }
  return errors;
}

Future<void> _capture(WidgetTester tester, Size phone, String band) async {
  if (_captureDir.isEmpty) return;
  await tester.runAsync(() async {
    final image =
        await captureImage(find.byType(MaterialApp).evaluate().single);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('$_captureDir/honour-roll-$band-'
        '${phone.width.toInt()}x${phone.height.toInt()}.png');
    file.writeAsBytesSync(bytes!.buffer.asUint8List());
    // ignore: avoid_print
    print('wrote ${file.path}');
  });
}

void main() {
  group('bands', () {
    test('are the four the group asked for until someone reaches 50', () {
      expect(honourTiersFor([10, 19, 42]).map((t) => t.label),
          ['10–19', '20–29', '30–39', '40–49']);
      expect(honourTiersFor([10, 57]).map((t) => t.label),
          ['10–19', '20–29', '30–39', '40–49', '50+']);
    });

    test('include both ends', () {
      const band = HonourTier(10, 19);
      expect([9, 10, 19, 20].map(band.contains), [false, true, true, false]);
      expect(const HonourTier(50).contains(57), isTrue);
    });

    test('rank ties together', () {
      expect(competitionRanks([57, 57, 54, 50, 50, 49]), [1, 1, 3, 4, 4, 6]);
    });
  });

  group('entry', () {
    test('reads the breakdown the server sends', () {
      final e = HonourRollEntry.fromJson(_donor(1, 'T-0001', 'x', '', 3, 1));
      expect([e.total, e.previous, e.recorded], [4, 3, 1]);
      expect(e.hasBreakdown, isTrue);
    });

    test('falls back to total_count from an older server', () {
      final e = HonourRollEntry.fromJson({'id': 1, 'total_count': '31'});
      expect(e.total, 31);
      expect(e.hasBreakdown, isFalse);
    });
  });

  group('screen', () {
    setUpAll(_loadFonts);

    for (final phone in const [Size(390, 844), Size(320, 568)]) {
      final size = '${phone.width.toInt()}x${phone.height.toInt()}';

      testWidgets('lays out every band on a $size phone', (tester) async {
        final service = _FakeMemberService(_fixture);
        final errors = await _pumpRoll(tester, phone, service);
        expect(errors, isEmpty, reason: errors.join('\n'));
        expect(service.requestedMin, 10);

        // All five bands fit side by side, with their donor counts.
        for (final label in ['10–19', '20–29', '30–39', '40–49', '50+']) {
          final tab = find.byKey(ValueKey('honour-tier-$label'));
          expect(tab, findsOneWidget);
          expect(tester.getRect(tab).right, lessThanOrEqualTo(phone.width));
        }
        expect(
            find.bySemanticsLabel('10 မှ 19 ကြိမ် 4 ဦး'), findsOneWidget);
        expect(find.bySemanticsLabel('50 ကြိမ်နှင့်အထက် 4 ဦး'),
            findsOneWidget);

        // The first band opens by default, most first, with the breakdown;
        // a total of exactly 10 belongs to it.
        expect(find.text('ကိုနန္ဒ'), findsOneWidget);
        expect(find.text('ယခင် 2 + အဖွဲ့နှင့် 13'), findsOneWidget);
        expect(find.text('မသီတာ'), findsOneWidget);
        expect(find.text('ကိုအောင်အောင်'), findsNothing);
        await _capture(tester, phone, '10-19');

        for (final band in ['20–29', '30–39', '40–49', '50+']) {
          final errors = <FlutterErrorDetails>[];
          final previous = FlutterError.onError;
          FlutterError.onError = errors.add;
          await tester.tap(find.byKey(ValueKey('honour-tier-$band')));
          await tester.pumpAndSettle();
          FlutterError.onError = previous;
          expect(errors, isEmpty, reason: '$band: ${errors.join('\n')}');
          if (band == '30–39') {
            await _capture(tester, phone, '30-39');
          }
        }

        // 50+: the two donors tied at 57 share first place.
        expect(find.text('ကိုအောင်အောင်'), findsOneWidget);
        expect(find.text('မသန္တာ'), findsOneWidget);
        expect(find.bySemanticsLabel('57 ကြိမ်'), findsNWidgets(2));
        expect(find.text('ယခင် 46 + အဖွဲ့နှင့် 11'), findsOneWidget);
        await _capture(tester, phone, '50-plus');
      });
    }

    testWidgets('an empty band says so', (tester) async {
      final errors = await _pumpRoll(
        tester,
        const Size(390, 844),
        _FakeMemberService([_donor(1, 'T-0001', 'x', 'A (Rh +)', 11, 1)]),
      );
      expect(errors, isEmpty);
      await tester.tap(find.byKey(const ValueKey('honour-tier-40–49')));
      await tester.pumpAndSettle();
      expect(find.text('40–49 ကြိမ် လှူဒါန်းထားသူ မရှိသေးပါ'), findsOneWidget);
      expect(find.byKey(const ValueKey('honour-tier-50+')), findsNothing);
    });
  });
}
