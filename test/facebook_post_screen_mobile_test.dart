import 'package:donation/src/features/donation/facebook_post_screen.dart';
import 'package:donation/src/features/services/donation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<Map<String, dynamic>> _rowsFor(DateTime day) {
  final date = '${day.year.toString().padLeft(4, '0')}-'
      '${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')} 09:14:00';
  return [
    {
      'donation_date': date,
      'patient_name': 'ဒေါ်ခင်မြင့်',
      'patient_address': 'ရွှေတောင်ရပ်ကွက်၊မော်လမြိုင်မြို့၊မော်လမြိုင်မြို့နယ်',
      'hospital': 'မော်လမြိုင်ဆေးရုံကြီး',
      'memberObj': {'name': 'ကိုအောင်အောင်', 'blood_type': 'O (Rh +)'},
    },
    {
      'donation_date': date,
      'patient_name': 'ဒေါ်ခင်မြင့်',
      'patient_address': 'ရွှေတောင်ရပ်ကွက်၊မော်လမြိုင်မြို့၊မော်လမြိုင်မြို့နယ်',
      'hospital': 'မော်လမြိုင်ဆေးရုံကြီး',
      'memberObj': {'name': 'ကိုမျိုးမင်း', 'blood_type': 'O (Rh +)'},
    },
    {
      'donation_date': date,
      'patient_name': 'ဦးစိန်လှ',
      'patient_address': 'ဖာသိမ်ကျေးရွာ၊ကျိုက်မရောမြို့နယ်',
      'hospital': 'ကျိုက်မရောဆေးရုံ',
      'memberObj': {'name': 'မခင်သီတာ', 'blood_type': 'B (Rh +)'},
    },
  ];
}

class _FakeDonationService extends DonationService {
  @override
  Future<List<dynamic>> getDonationsByMonthYear(
    int month,
    int year, {
    int limit = 500,
  }) async =>
      _rowsFor(DateTime.now());
}

Future<void> _pumpScreen(WidgetTester tester, Size size) async {
  // The layout switches on MediaQuery.size, which setSurfaceSize does not
  // move — only the view's own metrics do.
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        donationServiceProvider.overrideWithValue(_FakeDonationService()),
      ],
      child: const MaterialApp(home: FacebookPostScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('the copy button stays reachable without scrolling on a phone',
      (tester) async {
    await _pumpScreen(tester, const Size(390, 844));

    final copy = find.byKey(const ValueKey('copy-facebook-post'));
    expect(copy, findsOneWidget);

    // Reachable means on screen, not merely in the tree: the bar is pinned
    // below the tabs rather than sitting under every patient card.
    final barRect = tester.getRect(copy);
    expect(barRect.bottom, lessThanOrEqualTo(844));
    expect(barRect.top, greaterThan(0));

    // Both tabs keep the same one copy action.
    await tester.tap(find.text('ပို့စ်စာသား'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('copy-facebook-post')), findsOneWidget);
    expect(tester.getRect(copy).bottom, lessThanOrEqualTo(844));
  });

  testWidgets('each tab shows its own half of the screen', (tester) async {
    await _pumpScreen(tester, const Size(390, 844));

    // Editing tab: the day's paragraphs, ready to reorder and time.
    expect(find.textContaining('ဒေါ်ခင်မြင့်'), findsWidgets);
    expect(find.textContaining('အပိုဒ်အစီအစဉ်ကို ဆွဲ၍'), findsOneWidget);

    await tester.tap(find.text('ပို့စ်စာသား'));
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(
      find.byType(TextField).last,
    );
    expect(field.controller?.text, contains('ဒေါ်ခင်မြင့်'));
    expect(field.controller?.text, contains('ကိုအောင်အောင်'));
    // The tally travels with the copy bar, so the text tab still says what is
    // about to be copied.
    expect(find.textContaining('လူနာ'), findsWidgets);
  });

  testWidgets('time dropdown shows the requested complete phrases',
      (tester) async {
    await _pumpScreen(tester, const Size(390, 844));

    await tester.tap(find.text('ဒီနေ့နေ့လယ်').first);
    await tester.pumpAndSettle();

    expect(find.text('မနက်စောစော'), findsOneWidget);
    expect(find.text('ဒီနေ့မနက်'), findsOneWidget);
    expect(find.text('ညနေစောင်း'), findsOneWidget);
    expect(find.text('ည(--:--)'), findsOneWidget);
    expect(find.text('ဒီနေ့မနက်စောစော'), findsNothing);
  });

  testWidgets('night-time placeholder opens a clock and updates the post',
      (tester) async {
    await _pumpScreen(tester, const Size(390, 844));

    await tester.tap(find.text('ဒီနေ့နေ့လယ်').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('ည(--:--)'));
    await tester.pumpAndSettle();

    expect(find.text('ညအချိန် ရွေးပါ'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('ပို့စ်စာသား'));
    await tester.pumpAndSettle();
    final field = tester.widget<TextField>(find.byType(TextField).last);
    expect(field.controller?.text, matches(RegExp(r'ည\([၀-၉]+:[၀-၉]{2}\)မှာ')));
  });

  testWidgets('copying puts the generated post on the clipboard',
      (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));

    await _pumpScreen(tester, const Size(390, 844));
    await tester.tap(find.byKey(const ValueKey('copy-facebook-post')));
    await tester.pumpAndSettle();

    expect(copied, isNotNull);
    expect(copied, contains('ဒေါ်ခင်မြင့်'));
    expect(copied, contains('မခင်သီတာ'));
    expect(find.text('ပို့စ်စာသား ကူးယူပြီးပါပြီ'), findsOneWidget);
  });

  testWidgets('the narrowest phone lays out without overflow', (tester) async {
    await _pumpScreen(tester, const Size(320, 568));

    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('copy-facebook-post')), findsOneWidget);

    await tester.tap(find.text('ပို့စ်စာသား'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('the desktop layout keeps its side-by-side copy button',
      (tester) async {
    await _pumpScreen(tester, const Size(1280, 800));

    // No tabs, no bottom bar — one copy button, in the preview card.
    expect(find.text('ပြင်ဆင်ရန်'), findsNothing);
    expect(find.byKey(const ValueKey('copy-facebook-post')), findsOneWidget);
    expect(find.textContaining('ဒေါ်ခင်မြင့်'), findsWidgets);
  });
}
