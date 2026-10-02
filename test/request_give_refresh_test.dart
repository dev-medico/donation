import 'package:donation/src/features/donation/blood_request_give_chart.dart';
import 'package:donation/src/features/finder/request_give_detail_screen_new.dart';
import 'package:donation/src/features/services/donation_service.dart';
import 'package:donation/src/features/services/report_service.dart';
import 'package:donation/src/features/services/request_give_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class _Worksheet extends RequestGiveService {
  int count = 2;
  @override
  Future<Map<String, dynamic>> getDetailedReport(
          {int? year, int? month}) async =>
      {
        'summary': {'totalGive': count}
      };
}

class _Report extends ReportService {
  int count = 2;
  @override
  Future<List<Map<String, dynamic>>> getRequestGiveStats() async => [
        {'year': 2026, 'month': 10, 'give': count, 'request': 5}
      ];
}

void main() {
  test('donation mutations refresh already cached monthly reports and charts',
      () async {
    final worksheet = _Worksheet();
    final report = _Report();
    final container = ProviderContainer(overrides: [
      requestGiveServiceProvider.overrideWithValue(worksheet),
      reportServiceProvider.overrideWithValue(report),
    ]);
    addTearDown(container.dispose);
    final month = requestGiveReportProvider('2026-10');
    container.listen(month, (_, __) {});
    container.listen(requestGiveStatsProvider, (_, __) {});
    expect((await container.read(month.future))['summary']['totalGive'], 2);
    expect(
        (await container.read(requestGiveStatsProvider.future)).single['give'],
        2);
    worksheet.count = report.count = 1;
    container.read(donationMutationRevisionProvider.notifier).state++;
    expect((await container.read(month.future))['summary']['totalGive'], 1);
    expect(
        (await container.read(requestGiveStatsProvider.future)).single['give'],
        1);
  });
}
