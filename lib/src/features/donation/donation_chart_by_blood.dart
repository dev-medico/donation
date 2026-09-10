import 'package:donation/src/features/donation/widgets/donation_stats_table.dart';
import 'package:donation/src/features/services/report_service.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final bloodTypeStatsProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  try {
    final reportService = ref.read(reportServiceProvider);
    return await reportService.getBloodTypeStats();
  } catch (e) {
    throw Exception('Failed to load blood type stats: $e');
  }
});

class DonationChartByBlood extends ConsumerWidget {
  const DonationChartByBlood({
    Key? key,
    this.fromDashboard,
  }) : super(key: key);

  final bool? fromDashboard;

  static const List<String> bloodTypes = [
    "A (Rh +)",
    "B (Rh +)",
    "AB (Rh +)",
    "O (Rh +)",
    "A (Rh -)",
    "B (Rh -)",
    "AB (Rh -)",
    "O (Rh -)",
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bloodStats = ref.watch(bloodTypeStatsProvider);

    return bloodStats.when(
      data: (data) {
        final counts = Map<String, int>.from(data['data']);
        return DonationStatsTable(
          title: fromDashboard ?? false
              ? "သွေးအုပ်စုအလိုက် လှူဒါန်းမှု မှတ်တမ်း"
              : "သွေးအုပ်စုအလိုက် မှတ်တမ်း",
          labelHeader: "သွေးအမျိုးအစား",
          rows: [
            for (final type in bloodTypes) StatsRow(type, counts[type] ?? 0),
          ],
          total: data['totalDonations'] as int? ?? 0,
        );
      },
      loading: () => const StatsTablePlaceholder(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => StatsTablePlaceholder(
        child: Text(
          error.toString().replaceAll('Exception: ', ''),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
