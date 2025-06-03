import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:donation/responsive.dart';
import 'package:donation/utils/Colors.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/src/features/services/report_service.dart';

final diseaseStatsProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  try {
    log('Fetching disease stats...');
    final reportService = ref.read(reportServiceProvider);
    final result = await reportService.getDiseaseStats();
    log('Disease stats result: $result');
    return result;
  } catch (e, stack) {
    log('Error in diseaseStatsProvider: $e');
    log('Stack trace: $stack');
    throw Exception('Failed to load disease stats: $e');
  }
});

class DonationChartByDisease extends ConsumerWidget {
  const DonationChartByDisease({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log('DonationChartByDisease: build() called');
    final diseaseStats = ref.watch(diseaseStatsProvider);

    // Simple colored container to verify widget is being rendered
    return Container(
      height: 400,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: diseaseStats.when(
        data: (data) {
          log('Disease stats data received: ${data.length} items');
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "ဖြစ်ပွားသည့်ရောဂါ အလိုက် မှတ်တမ်း",
                  style: TextStyle(
                    fontSize: 16,
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (data.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text('No data available'),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final item = data[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item['name'] ?? '',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${item['count'] ?? 0}',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () {
          log('Disease chart: Loading state');
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stack) {
          log('Disease chart error: $error');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(height: 8),
                Text('Error: ${error.toString()}'),
                ElevatedButton(
                  onPressed: () => ref.invalidate(diseaseStatsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}