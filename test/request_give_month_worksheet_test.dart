import 'package:donation/src/features/finder/request_give_list_screen.dart';
import 'package:donation/src/features/services/request_give_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class _FakeRequestGiveService extends RequestGiveService {
  _FakeRequestGiveService({required this.payload});

  Map<String, dynamic> payload;
  List<Map<String, dynamic>>? savedRecords;
  int? savedExpectedRevision;

  @override
  Future<Map<String, dynamic>> getMonthEntry({
    required int year,
    required int month,
  }) async {
    return Map<String, dynamic>.from(payload);
  }

  @override
  Future<Map<String, dynamic>> saveMonth({
    required int year,
    required int month,
    required List<Map<String, dynamic>> records,
    required int expectedRevision,
  }) async {
    savedRecords = records.map(Map<String, dynamic>.from).toList();
    savedExpectedRevision = expectedRevision;
    final requestTotal = records.fold<int>(
      0,
      (sum, row) => sum + ((row['request'] as int?) ?? 0),
    );
    final giveTotal = records.fold<int>(
      0,
      (sum, row) => sum + ((row['give'] as int?) ?? 0),
    );
    payload = {
      'year': year,
      'month': month,
      'daysInMonth': DateTime(year, month + 1, 0).day,
      'rows': [
        for (var index = 0; index < records.length; index++)
          {'id': index + 1, ...records[index]},
      ],
      'totals': {'request': requestTotal, 'give': giveTotal},
      'recordedDays': records.length,
      'revision': expectedRevision + 1,
      'legacySummary': null,
      'legacyOnly': false,
      'editable': true,
    };
    return Map<String, dynamic>.from(payload);
  }
}

Future<void> _pumpWorksheet(
  WidgetTester tester,
  _FakeRequestGiveService service,
) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(390, 844);
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [requestGiveServiceProvider.overrideWithValue(service)],
      child: MaterialApp(
        theme: ThemeData(fontFamily: 'MyanUni'),
        home: RequestGiveListScreen(
          initialMonth: DateTime(2024, 2),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _fieldFor(String key) => find.descendant(
      of: find.byKey(Key(key), skipOffstage: false),
      matching: find.byType(TextField, skipOffstage: false),
      skipOffstage: false,
    );

void main() {
  testWidgets(
    'shows every day and saves Myanmar-digit daily entries as integers',
    (tester) async {
      final service = _FakeRequestGiveService(
        payload: {
          'year': 2024,
          'month': 2,
          'daysInMonth': 29,
          'rows': [
            {
              'id': 9,
              'date': '2024-02-03',
              'request': 2,
              'give': 0,
            },
          ],
          'totals': {'request': 2, 'give': 0},
          'recordedDays': 1,
          'revision': 4,
          'legacySummary': null,
          'legacyOnly': false,
          'editable': true,
        },
      );

      await _pumpWorksheet(tester, service);

      expect(
        find.byKey(const Key('request-give-month-worksheet')),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const Key('request-give-day-29'),
          skipOffstage: false,
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.inbox_outlined), findsNothing);
      expect(
        find.bySemanticsLabel('တောင်းခံ: 2 ကြိမ်', skipOffstage: false),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('လှူဒါန်း: 0 ကြိမ်', skipOffstage: false),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('မှတ်တမ်းရက်: 1/ 29', skipOffstage: false),
        findsOneWidget,
      );

      await tester.enterText(_fieldFor('request-day-1'), '၄');
      await tester.enterText(_fieldFor('give-day-1'), '၂');
      await tester.pump();

      expect(
        tester.widget<TextField>(_fieldFor('request-day-1')).controller!.text,
        '4',
      );
      expect(
        find.bySemanticsLabel('တောင်းခံ: 6 ကြိမ်', skipOffstage: false),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('လှူဒါန်း: 2 ကြိမ်', skipOffstage: false),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('မှတ်တမ်းရက်: 2/ 29', skipOffstage: false),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('save-request-give-month')));
      await tester.pumpAndSettle();

      expect(service.savedRecords, [
        {'date': '2024-02-01', 'request': 4, 'give': 2},
        {'date': '2024-02-03', 'request': 2, 'give': 0},
      ]);
      expect(service.savedExpectedRevision, 4);
      expect(find.textContaining('မှတ်တမ်းကို သိမ်းဆည်းပြီးပါပြီ'),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('legacy monthly totals stay visible and cannot be overwritten',
      (tester) async {
    final service = _FakeRequestGiveService(
      payload: {
        'year': 2024,
        'month': 2,
        'daysInMonth': 29,
        'rows': <Map<String, dynamic>>[],
        'totals': {'request': 0, 'give': 0},
        'recordedDays': 0,
        'revision': 0,
        'legacySummary': {
          'id': 21,
          'date': '2024-02-01',
          'request': 18,
          'give': 13,
          'recordCount': 1,
        },
        'legacyOnly': true,
        'editable': false,
      },
    );

    await _pumpWorksheet(tester, service);

    expect(
      find.byKey(const Key('legacy-month-banner'), skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('တောင်းခံ: 18 ကြိမ်', skipOffstage: false),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('လှူဒါန်း: 13 ကြိမ်', skipOffstage: false),
      findsOneWidget,
    );
    expect(find.byKey(const Key('save-request-give-month')), findsNothing);
    expect(_fieldFor('request-day-1'), findsNothing);
    expect(service.savedRecords, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('clears a worksheet-owned month and disables save when clean',
      (tester) async {
    final service = _FakeRequestGiveService(
      payload: {
        'year': 2024,
        'month': 2,
        'daysInMonth': 29,
        'rows': [
          {
            'id': 1,
            'date': '2024-02-01',
            'request': 3,
            'give': 2,
          },
        ],
        'totals': {'request': 3, 'give': 2},
        'recordedDays': 1,
        'revision': 7,
        'legacySummary': null,
        'legacyOnly': false,
        'editable': true,
      },
    );

    await _pumpWorksheet(tester, service);

    final saveButton = find.byKey(const Key('save-request-give-month'));
    expect(tester.widget<FilledButton>(saveButton).onPressed, isNull);

    await tester.enterText(_fieldFor('request-day-1'), '');
    await tester.enterText(_fieldFor('give-day-1'), '');
    await tester.pump();
    expect(tester.widget<FilledButton>(saveButton).onPressed, isNotNull);

    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(service.savedRecords, isEmpty);
    expect(service.savedExpectedRevision, 7);
    expect(tester.widget<FilledButton>(saveButton).onPressed, isNull);
    expect(tester.takeException(), isNull);
  });
}
