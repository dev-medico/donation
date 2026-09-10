import 'package:donation/src/features/donation/widgets/donation_stats_table.dart';
import 'package:donation/src/features/services/report_service.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final hospitalStatsProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  try {
    final reportService = ref.read(reportServiceProvider);
    return await reportService.getHospitalStats();
  } catch (e) {
    throw Exception('Failed to load hospital stats: $e');
  }
});

class DonationChartByHospital extends ConsumerWidget {
  const DonationChartByHospital({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hospitalStats = ref.watch(hospitalStatsProvider);

    return hospitalStats.when(
      data: (data) {
        final hospitals = Map<String, int>.from(data['data']).entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        return DonationStatsTable(
          title: "လှူဒါန်းသည့်နေရာအလိုက် မှတ်တမ်း",
          labelHeader: "လှူဒါန်းသည့်နေရာ",
          rows: [
            for (final hospital in hospitals)
              StatsRow(
                hospital.key.isEmpty ? "-" : hospital.key,
                hospital.value,
              ),
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
