// Pass --dart-define=EVENT_CAPTURE_DIR=design-qa to also write
// special-event-<tab>-<w>x<h>.png phone captures for visual QA.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:donation/src/features/dashboard/dashboard.dart';
import 'package:donation/src/features/services/report_service.dart';
import 'package:donation/src/features/services/special_event_service.dart';
import 'package:donation/src/features/special_event/providers/special_event_provider.dart';
import 'package:donation/src/features/special_event/special_event_list_screen.dart';
import 'package:donation/src/features/special_event/special_event_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const _captureDir =
    String.fromEnvironment('EVENT_CAPTURE_DIR', defaultValue: '');

/// The app's Burmese font, so text measures as it does on a device.
Future<void> _loadBurmeseFont() async {
  final bytes =
      await File('assets/fonts/MyanUni/pds_regular.ttf').readAsBytes();
  final loader = FontLoader('MyanUni')
    ..addFont(Future.value(ByteData.view(bytes.buffer)));
  await loader.load();
}

Future<void> _capture(WidgetTester tester, String name) async {
  if (_captureDir.isEmpty) return;
  await tester.runAsync(() async {
    final image =
        await captureImage(find.byType(MaterialApp).evaluate().single);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('$_captureDir/$name.png');
    file.writeAsBytesSync(bytes!.buffer.asUint8List());
    // ignore: avoid_print
    print('wrote ${file.path}');
  });
}

typedef _PageHandler = Future<SpecialEventPage> Function(
  int page,
  int limit,
  String query,
);

class _FakeSpecialEventService extends SpecialEventService {
  _FakeSpecialEventService(this.handler);

  final _PageHandler handler;
  final calls = <({int page, int limit, String query})>[];

  @override
  Future<SpecialEventPage> getSpecialEvents({
    int page = 0,
    int limit = 50,
    String? q,
  }) {
    final query = q ?? '';
    calls.add((page: page, limit: limit, query: query));
    return handler(page, limit, query);
  }
}

class _FakeReportService extends ReportService {
  @override
  Future<Map<String, dynamic>> getDashboardStats() async => {
        'totalMember': 10,
        'donations': 20,
        'totalPatient': 30,
        'totalSpecialEvents': 12,
      };

  @override
  Future<List<Map<String, dynamic>>> getRequestGiveStats() async => [];

  @override
  Future<List<Map<String, dynamic>>> getDiseaseStats() async => [];
}

Map<String, dynamic> _event({
  required int id,
  required String lab,
  int hcv = 0,
  int vdrl = 0,
}) {
  return {
    'id': id,
    'date': '2026-08-${id.toString().padLeft(2, '0')}',
    'lab_name': lab,
    'haemoglobin': 0,
    'hbs_ag': 0,
    'hcv_ab': hcv,
    'mp_ict': 0,
    'retro_test': 0,
    'vdrl_test': vdrl,
    'total': hcv + vdrl,
  };
}

SpecialEventPage _page({
  required List<Map<String, dynamic>> events,
  int page = 0,
  int? total,
  bool hasMore = false,
  SpecialEventSummary? summary,
}) {
  return SpecialEventPage(
    events: events,
    page: page,
    limit: SpecialEventListController.pageSize,
    total: total ?? events.length,
    hasMore: hasMore,
    summary: summary,
  );
}

Future<void> _pumpSpecialEventScreen(
  WidgetTester tester,
  SpecialEventService service, {
  Size size = const Size(390, 844),
  ThemeData? theme,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(() {
    tester.view.resetDevicePixelRatio();
    tester.view.resetPhysicalSize();
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [specialEventServiceProvider.overrideWithValue(service)],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: const SpecialEventListScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  final allTimeSummary = SpecialEventSummary.fromJson({
    'recordCount': '124',
    'haemoglobin': '48',
    'hbs_ag': 96,
    'hcv_ab': 37,
    'mp_ict': null,
    'retro_test': 9,
    'vdrl_test': 24,
  });

  test('summary survives pagination and updates when the list refreshes',
      () async {
    var summary = allTimeSummary;
    final service =
        _FakeSpecialEventService((page, limit, query) async => _page(
              events: [_event(id: page + 1, lab: 'Example Lab')],
              page: page,
              total: 2,
              hasMore: page == 0,
              summary: page == 0 ? summary : null,
            ));
    final controller =
        SpecialEventListController(service, loadImmediately: false);
    addTearDown(controller.dispose);
    await controller.refresh();
    await controller.loadMore();
    expect(controller.state.asData!.value.summary!.recordCount, 124);
    summary = SpecialEventSummary.fromJson({'recordCount': 125, 'hbs_ag': 100});
    await controller.search('Example');
    expect(controller.state.asData!.value.summary!.recordCount, 125);
    expect(controller.state.asData!.value.summary!.totalFindings, 100);
  });

  for (final size in [
    const Size(320, 568),
    const Size(390, 844),
    const Size(1280, 800)
  ]) {
    testWidgets('all-time summary is distinct from visible rows at $size',
        (tester) async {
      final service =
          _FakeSpecialEventService((page, limit, query) async => _page(
                events: [_event(id: 1, lab: 'Example Lab', hcv: 2)],
                summary: allTimeSummary,
              ));
      await _pumpSpecialEventScreen(tester, service, size: size);
      await tester.tap(find.byKey(const ValueKey('special-event-summary-tab')));
      await tester.pumpAndSettle();
      expect(find.text('ကာလအားလုံး၊ ဓာတ်ခွဲခန်းအားလုံး'), findsOneWidget);
      expect(find.text('မှတ်တမ်း 124 ခုမှ'), findsOneWidget);
      expect(find.text('214'), findsOneWidget);
      final vdrl = find.byKey(const ValueKey('special-event-total-vdrl_test'));
      await tester.ensureVisible(vdrl);
      expect(tester.widget<Text>(vdrl).data, '24');
      expect(tester.takeException(), isNull);
    });
  }

  group('in the app font', () {
    setUpAll(_loadBurmeseFont);

    for (final phone in const [Size(320, 568), Size(390, 844)]) {
      final size = '${phone.width.toInt()}x${phone.height.toInt()}';
      testWidgets('both tabs lay out on a $size phone', (tester) async {
        // Captures show real elevation shadows rather than the test
        // renderer's outlines; the flag must be reset before the body ends.
        if (_captureDir.isNotEmpty) debugDisableShadows = false;
        try {
          final service =
              _FakeSpecialEventService((page, limit, query) async => _page(
                    events: [
                      for (var id = 12; id > 0; id--)
                        _event(
                          id: id,
                          lab: 'နမူနာ ဓာတ်ခွဲခန်း (${id.isEven ? '၁' : '၂'})',
                          hcv: id % 3 == 0 ? 1 : 0,
                          vdrl: 1,
                        ),
                    ],
                    summary: allTimeSummary,
                  ));
          await _pumpSpecialEventScreen(tester, service,
              size: phone, theme: ThemeData(fontFamily: 'MyanUni'));
          await _capture(tester, 'special-event-records-$size');

          await tester
              .tap(find.byKey(const ValueKey('special-event-summary-tab')));
          await tester.pumpAndSettle();
          expect(find.byKey(const ValueKey('special-event-findings-total')),
              findsOneWidget);
          await _capture(tester, 'special-event-summary-$size');
        } finally {
          debugDisableShadows = true;
        }
      });
    }
  });

  testWidgets('missing summary offers retry instead of a misleading zero',
      (tester) async {
    final service = _FakeSpecialEventService(
        (page, limit, query) async => _page(events: []));
    await _pumpSpecialEventScreen(tester, service);
    await tester.tap(find.byKey(const ValueKey('special-event-summary-tab')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('special-event-findings-total')),
        findsNothing);
    await tester.tap(find.text('ပြန်ယူမည်'));
    await tester.pumpAndSettle();
    expect(service.calls.length, 2);
  });

  test('list controller appends pages once and refresh replaces stale rows',
      () async {
    var firstPage = _page(
      events: [_event(id: 3, lab: 'Newest Lab')],
      total: 2,
      hasMore: true,
    );
    final service = _FakeSpecialEventService((page, limit, query) async {
      if (page == 0) return firstPage;
      return _page(
        events: [
          _event(id: 3, lab: 'Duplicate Newest Lab'),
          _event(id: 2, lab: 'Older Lab'),
        ],
        page: 1,
        total: 2,
      );
    });
    final controller = SpecialEventListController(
      service,
      loadImmediately: false,
    );
    addTearDown(controller.dispose);

    await controller.refresh();
    await controller.loadMore();

    expect(
      controller.state.asData!.value.events.map((event) => event['id']),
      [3, 2],
    );
    expect(service.calls.map((call) => call.page), [0, 1]);

    firstPage = _page(events: [_event(id: 4, lab: 'Replacement Lab')]);
    await controller.refresh();

    expect(
      controller.state.asData!.value.events.single['lab_name'],
      'Replacement Lab',
    );
    expect(controller.state.asData!.value.events, hasLength(1));
  });

  testWidgets('mobile list shows summary and only non-zero findings',
      (tester) async {
    final service = _FakeSpecialEventService((page, limit, query) async {
      return _page(events: [
        _event(id: 29, lab: 'Mawlamyine Lab', hcv: 2, vdrl: 1),
      ]);
    });

    await _pumpSpecialEventScreen(tester, service);

    expect(find.byKey(const ValueKey('special-event-list')), findsOneWidget);
    expect(find.text('စုစုပေါင်း 1 မှတ်တမ်း'), findsOneWidget);
    expect(find.text('Mawlamyine Lab'), findsOneWidget);
    expect(find.text('HCV Ab 2'), findsOneWidget);
    expect(find.text('VDRL 1'), findsOneWidget);
    expect(find.textContaining('MP ICT 0'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty state has add and retry actions', (tester) async {
    final service = _FakeSpecialEventService((page, limit, query) async {
      return _page(events: []);
    });

    await _pumpSpecialEventScreen(tester, service);

    expect(find.byKey(const ValueKey('special-event-empty')), findsOneWidget);
    expect(
        find.byKey(const ValueKey('special-event-empty-add')), findsOneWidget);
    expect(find.byKey(const ValueKey('special-event-empty-retry')),
        findsOneWidget);
  });

  testWidgets('error retry can recover into a populated list', (tester) async {
    var callCount = 0;
    final service = _FakeSpecialEventService((page, limit, query) async {
      callCount += 1;
      if (callCount == 1) throw Exception('temporary failure');
      return _page(events: [_event(id: 29, lab: 'Recovered Lab', hcv: 1)]);
    });

    await _pumpSpecialEventScreen(tester, service);
    expect(find.byKey(const ValueKey('special-event-error')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('special-event-retry')));
    await tester.pumpAndSettle();

    expect(find.text('Recovered Lab'), findsOneWidget);
    expect(callCount, 2);
  });

  testWidgets('search uses the canonical controller query', (tester) async {
    final service = _FakeSpecialEventService((page, limit, query) async {
      return _page(
        events: query.isEmpty
            ? [_event(id: 29, lab: 'All Labs')]
            : [_event(id: 28, lab: 'Searched Lab')],
      );
    });

    await _pumpSpecialEventScreen(tester, service);
    await tester.enterText(
      find.byKey(const ValueKey('special-event-search')),
      'Searched',
    );
    await tester.pump(const Duration(milliseconds: 351));
    await tester.pumpAndSettle();

    expect(service.calls.last.query, 'Searched');
    expect(find.text('Searched Lab'), findsOneWidget);
  });

  testWidgets('compact mobile add form is a full-screen route', (tester) async {
    final semantics = tester.ensureSemantics();
    final service = _FakeSpecialEventService((page, limit, query) async {
      return _page(events: [_event(id: 29, lab: 'Mawlamyine Lab')]);
    });

    await _pumpSpecialEventScreen(
      tester,
      service,
      size: const Size(320, 568),
    );
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(
        find.byKey(const ValueKey('special-event-add-page')), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byKey(const ValueKey('special-event-add-lab-name')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('special-event-add-haemoglobin')),
        findsOneWidget);
    expect(
        find.byKey(const ValueKey('special-event-add-vdrl')), findsOneWidget);

    final haemoglobin =
        find.byKey(const ValueKey('special-event-add-haemoglobin'));
    await tester.enterText(haemoglobin, '၅');
    expect(
      tester.widget<TextFormField>(haemoglobin).controller!.text,
      '5',
    );

    final save = find.byKey(const ValueKey('special-event-add-save'));
    expect(save, findsOneWidget);
    expect(tester.getRect(save).bottom, lessThanOrEqualTo(568));

    final dateSemantics = tester.getSemantics(
      find.byKey(const ValueKey('special-event-add-date')),
    );
    expect(dateSemantics.label, contains('ရက်စွဲ'));

    await tester.tap(save);
    await tester.pump();
    expect(find.text('Lab Name ဖြည့်သွင်းပါ'), findsOneWidget);
    expect(
        find.byKey(const ValueKey('special-event-add-page')), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('mobile edit form also uses the full-screen route',
      (tester) async {
    final service = _FakeSpecialEventService((page, limit, query) async {
      return _page(events: [
        _event(id: 29, lab: 'Mawlamyine Lab', hcv: 2, vdrl: 1),
      ]);
    });

    await _pumpSpecialEventScreen(tester, service);
    await tester.tap(find.text('Mawlamyine Lab'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ပြင်မည်'));
    await tester.pumpAndSettle();

    expect(
        find.byKey(const ValueKey('special-event-edit-page')), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byKey(const ValueKey('special-event-edit-lab-name')),
        findsOneWidget);
    expect(
        find.byKey(const ValueKey('special-event-edit-save')), findsOneWidget);
  });

  testWidgets('desktop add form remains an AlertDialog', (tester) async {
    final service = _FakeSpecialEventService((page, limit, query) async {
      return _page(events: []);
    });

    await _pumpSpecialEventScreen(
      tester,
      service,
      size: const Size(1024, 768),
    );
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.byKey(const ValueKey('special-event-add-page')), findsNothing);
  });

  testWidgets('dashboard renders the Special Event total', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          reportServiceProvider.overrideWithValue(_FakeReportService()),
        ],
        child: const MaterialApp(home: DashBoardScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final card = find.byKey(const ValueKey('dashboard-special-event-card'));
    expect(card, findsOneWidget);
    expect(find.descendant(of: card, matching: find.text('12 ခု')),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
