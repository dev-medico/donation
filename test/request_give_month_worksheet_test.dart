import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:donation/src/features/services/donation_service.dart';
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
    if (payload['automaticGive'] == true) {
      payload = {...payload, 'revision': expectedRevision + 1};
      return payload;
    }
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
  _FakeRequestGiveService service, {
  Size size = const Size(390, 844),
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [requestGiveServiceProvider.overrideWithValue(service)],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
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
  setUpAll(() async {
    final bytes =
        await File('assets/fonts/MyanUni/pds_regular.ttf').readAsBytes();
    final loader = FontLoader('MyanUni')
      ..addFont(Future.value(ByteData.view(bytes.buffer)));
    await loader.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });
  for (final size in [const Size(390, 844), const Size(320, 568)]) {
    testWidgets('automatic counts preserve draft requests at $size',
        (tester) async {
      final service = _FakeRequestGiveService(payload: {
        'automaticGive': true,
        'today': '2024-02-03',
        'revision': 4,
        'legacyOnly': false,
        'editable': true,
        'rows': [
          {'date': '2024-02-01', 'request': null, 'give': 2},
          {'date': '2024-02-02', 'request': null, 'give': 0},
          {'date': '2024-02-03', 'request': null, 'give': 1},
        ],
      });
      await _pumpWorksheet(tester, service, size: size);
      expect(_fieldFor('give-day-1'), findsNothing);
      expect(find.byKey(const Key('automatic-give-day-1'), skipOffstage: false),
          findsOneWidget);
      expect(find.bySemanticsLabel('မှတ်တမ်းရက်: 0/ 29', skipOffstage: false),
          findsOneWidget);
      expect(
          tester
              .widget<FilledButton>(
                  find.byKey(const Key('save-request-give-month')))
              .onPressed,
          isNull);
      expect(tester.widget<TextField>(_fieldFor('request-day-4')).enabled,
          isFalse);
      if (const bool.fromEnvironment('WORKSHEET_CAPTURE')) {
        await tester.runAsync(() async {
          final image =
              await captureImage(find.byType(MaterialApp).evaluate().single);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          File('design-qa/automatic-donations-${size.width.toInt()}x${size.height.toInt()}.png')
              .writeAsBytesSync(bytes!.buffer.asUint8List());
        });
      }
      await tester.ensureVisible(_fieldFor('request-day-1'));
      await tester.enterText(_fieldFor('request-day-1'), '၄');
      await tester.pump();
      service.payload = {
        ...service.payload,
        'revision': 9,
        'rows': [
          {'date': '2024-02-01', 'request': 99, 'give': 5},
          {'date': '2024-02-02', 'request': null, 'give': 0},
          {'date': '2024-02-03', 'request': null, 'give': 1},
        ]
      };
      final container = ProviderScope.containerOf(
          tester.element(find.byType(RequestGiveListScreen)));
      container.read(donationMutationRevisionProvider.notifier).state++;
      await tester.pumpAndSettle();
      expect(
          tester.widget<TextField>(_fieldFor('request-day-1')).controller!.text,
          '4');
      expect(find.bySemanticsLabel('လှူဒါန်း: 6 ကြိမ်', skipOffstage: false),
          findsOneWidget);
      await tester.tap(find.byKey(const Key('save-request-give-month')));
      await tester.pumpAndSettle();
      expect(service.savedRecords, [
        {'date': '2024-02-01', 'request': 4}
      ]);
      expect(service.savedExpectedRevision, 4);
      expect(tester.takeException(), isNull);
    });
  }

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
        'reconciliation': {
          'recordedGive': 13,
          'donationGive': 11,
          'difference': -2
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

  testWidgets(
      'historical requests retain monthly totals with actual daily donations',
      (tester) async {
    final service = _FakeRequestGiveService(payload: {
      'automaticGive': true,
      'today': '2026-10-02',
      'revision': 0,
      'legacyOnly': true,
      'editable': false,
      'legacySummary': {'id': 2, 'request': 267, 'give': 3},
      'rows': [
        {'date': '2024-02-01', 'request': null, 'give': 3},
        {'date': '2024-02-02', 'request': null, 'give': 0},
      ],
    });
    await _pumpWorksheet(tester, service);
    expect(
        find.descendant(
            of: find.byKey(const Key('request-total')),
            matching: find.textContaining('267')),
        findsOneWidget);
    expect(
        find.descendant(
            of: find.byKey(const Key('give-total')),
            matching: find.textContaining('3')),
        findsOneWidget);
    expect(
        tester.widget<TextField>(_fieldFor('request-day-1')).enabled, isFalse);
    expect(_fieldFor('give-day-1'), findsNothing);
    expect(
        tester
            .widget<TextButton>(find.byKey(const Key('automatic-give-day-1'),
                skipOffstage: false))
            .onPressed,
        isNotNull);
    expect(find.byKey(const Key('save-request-give-month')), findsNothing);
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
