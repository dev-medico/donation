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
    
    // Return data even if empty (let the UI handle empty state)
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
    log('DonationChartByDisease: Building widget');
    final diseaseStats = ref.watch(diseaseStatsProvider);
    log('DonationChartByDisease: Provider state = ${diseaseStats.runtimeType}');

    return Container(
      constraints: BoxConstraints(
        maxHeight: Responsive.isMobile(context)
            ? MediaQuery.of(context).size.height * 0.65
            : MediaQuery.of(context).size.height * 0.52,
        maxWidth: Responsive.isMobile(context)
            ? MediaQuery.of(context).size.width * 0.9
            : MediaQuery.of(context).size.width * 0.43,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red, width: 2), // Debug border
      ),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Responsive.isMobile(context) ? 12 : 16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: diseaseStats.when(
            data: (data) {
              log('Disease chart building with data: ${data.length} items');
              log('First item: ${data.isNotEmpty ? data.first : "no data"}');
              
              if (data.isEmpty) {
                return Center(
                  child: Text(
                    'မှတ်တမ်း မရှိပါ',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                );
              }

              // Sort diseases by count (descending)
              final sortedData = List<Map<String, dynamic>>.from(data)
                ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

              final totalDonations =
                  sortedData.fold<int>(0, (sum, item) => sum + (item['count'] as int));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "ဖြစ်ပွားသည့်ရောဂါ အလိုက် မှတ်တမ်း",
                    style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 15.5 : 16.5,
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: Responsive.isMobile(context) ? 10 : 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            "ဖြစ်ပွားသည့်ရောဂါ",
                            style: TextStyle(
                              fontSize: Responsive.isMobile(context) ? 14 : 15,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          "အရေအတွက်",
                          style: TextStyle(
                            fontSize: Responsive.isMobile(context) ? 14 : 15,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      itemCount: sortedData.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (BuildContext context, int index) {
                        final disease = sortedData[index];
                        final diseaseName = disease['name'] as String? ?? '';
                        final count = disease['count'] as int? ?? 0;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                diseaseName.isEmpty ? "-" : diseaseName,
                                style: TextStyle(
                                  fontSize: Responsive.isMobile(context) ? 14 : 15,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              count.toString(),
                              style: TextStyle(
                                fontSize: Responsive.isMobile(context) ? 14 : 15,
                                color: primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 8, right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "စုစုပေါင်း အရေအတွက်",
                          style: TextStyle(
                            fontSize: Responsive.isMobile(context) ? 14.5 : 15.5,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          totalDonations.toString(),
                          style: TextStyle(
                            fontSize: Responsive.isMobile(context) ? 14.5 : 15.5,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () {
              log('Disease chart loading...');
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('ရောဂါအလိုက် မှတ်တမ်း ရယူနေသည်...'),
                  ],
                ),
              );
            },
            error: (error, stack) {
              log('Disease chart error: $error');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      'ရောဂါအလိုက် မှတ်တမ်း ရယူ၍မရပါ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString().replaceAll('Exception: ', ''),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(diseaseStatsProvider);
                      },
                      child: const Text('ပြန်လည်ကြိုးစားမည်'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}