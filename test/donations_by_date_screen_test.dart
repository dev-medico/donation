import 'package:donation/src/features/donation/donation_list.dart';
import 'package:donation/src/features/donation/donations_by_date_screen.dart';
import 'package:donation/src/features/services/donation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeDonationService extends DonationService {
  _FakeDonationService({this.empty = false});

  final bool empty;
  final requestedDates = <DateTime>[];

  @override
  Future<List<dynamic>> getDonationsByMonthYear(
    int month,
    int year, {
    int limit = 500,
  }) async =>
      [];

  @override
  Future<List<dynamic>> getDonationsByDate(
    DateTime date, {
    int limit = 100,
  }) async {
    requestedDates.add(date);
    if (empty) return [];

    final dateText = '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')} 09:14:00';
    return [
      {
        'id': 123,
        'donation_date': dateText,
        'patient_name': 'ဦးစိန်လှ',
        'patient_disease': 'သွေးအားနည်း',
        'hospital': 'မော်လမြိုင်ဆေးရုံကြီး',
        'memberObj': {
          'id': 7,
          'member_id': 'A-0007',
          'name': 'ကိုအောင်အောင်',
          'blood_type': 'O (Rh +)',
          'phone': '09123456789',
        },
      },
    ];
  }
}

Future<void> _pump(
  WidgetTester tester,
  Widget home,
  DonationService service,
) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [donationServiceProvider.overrideWithValue(service)],
      child: MaterialApp(home: home),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('date search sits before trophy and opens the exact-date list', (
    tester,
  ) async {
    final service = _FakeDonationService();
    await _pump(
      tester,
      const DonationListScreen(),
      service,
    );

    final dateSearch = find.byKey(const Key('find-donations-by-date'));
    final trophy = find.byIcon(Icons.emoji_events);
    expect(dateSearch, findsOneWidget);
    expect(trophy, findsOneWidget);
    expect(
        tester.getCenter(dateSearch).dx, lessThan(tester.getCenter(trophy).dx));

    await tester.tap(dateSearch);
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);

    await tester.tap(find.text('ရှာမည်'));
    await tester.pumpAndSettle();

    expect(service.requestedDates, hasLength(1));
    final requested = service.requestedDates.single;
    expect(requested.hour, 0);
    expect(requested.minute, 0);
    expect(find.byKey(const Key('donations-by-date-list')), findsOneWidget);
    expect(find.text('ကိုအောင်အောင်'), findsOneWidget);
    expect(find.text('A-0007 · 09123456789'), findsOneWidget);
    expect(find.text('ဦးစိန်လှ'), findsOneWidget);
    expect(find.text('မော်လမြိုင်ဆေးရုံကြီး'), findsOneWidget);
    expect(find.text('သွေးအားနည်း'), findsOneWidget);
    expect(find.text('O+'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an exact date with no donations has a clear empty state', (
    tester,
  ) async {
    final service = _FakeDonationService(empty: true);
    await _pump(
      tester,
      DonationsByDateScreen(initialDate: DateTime(2026, 8, 20)),
      service,
    );

    expect(find.byKey(const Key('donations-by-date-empty')), findsOneWidget);
    expect(find.text('20-08-2026 တွင် လှူဒါန်းမှုမှတ်တမ်း မရှိပါ။'),
        findsOneWidget);
    expect(service.requestedDates, [DateTime(2026, 8, 20)]);
  });
}
