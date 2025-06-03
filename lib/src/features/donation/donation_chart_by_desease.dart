import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:donation/responsive.dart';
import 'package:donation/utils/Colors.dart';
import 'package:donation/utils/tool_widgets.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
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
    final diseaseStats = ref.watch(diseaseStatsProvider);

    return Container(
      height: Responsive.isMobile(context)
          ? MediaQuery.of(context).size.height * 0.65
          : MediaQuery.of(context).size.height * 0.52,
      width: Responsive.isMobile(context)
          ? MediaQuery.of(context).size.width * 0.9
          : MediaQuery.of(context).size.width * 0.43,
      child: Material(
        elevation: 4,
        borderRadius:
            BorderRadius.circular(Responsive.isMobile(context) ? 12 : 16),
        color: Colors.white,
        child: diseaseStats.when(
          data: (data) {
            log('Disease chart building with data: ${data.length} items');
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
            data.sort(
                (a, b) => (b['count'] as int).compareTo(a['count'] as int));

            final totalDonations =
                data.fold<int>(0, (sum, item) => sum + (item['count'] as int));

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "ဖြစ်ပွားသည့်ရောဂါ",
                        style: TextStyle(
                          fontSize: Responsive.isMobile(context) ? 15.5 : 16.5,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "အရေအတွက်",
                        style: TextStyle(
                          fontSize: Responsive.isMobile(context) ? 15.5 : 16.5,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: Responsive.isMobile(context)
                          ? const NeverScrollableScrollPhysics()
                          : const BouncingScrollPhysics(),
                      padding:
                          const EdgeInsets.only(top: 12.0, right: 12, left: 8),
                      itemCount: data.length,
                      itemBuilder: (BuildContext context, int index) {
                        final disease = data[index];
                        final diseaseName = disease['name'] as String? ?? '';
                        final count = disease['count'] as int? ?? 0;

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  diseaseName.isEmpty ? "-" : diseaseName,
                                  style: TextStyle(
                                    fontSize:
                                        Responsive.isMobile(context) ? 15 : 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Text(
                                count.toString(),
                                style: TextStyle(
                                  fontSize:
                                      Responsive.isMobile(context) ? 15 : 16,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 12, right: 16),
                    width: double.infinity,
                    height: 1,
                    color: Colors.grey,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 8, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "စုစုပေါင်း အရေအတွက်",
                          style: TextStyle(
                            fontSize:
                                Responsive.isMobile(context) ? 15.5 : 16.5,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          totalDonations.toString(),
                          style: TextStyle(
                            fontSize:
                                Responsive.isMobile(context) ? 15.5 : 16.5,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () {
            log('Disease chart loading...');
            return Center(child: CircularProgressIndicator());
          },
          error: (error, stack) {
            log('Disease chart error: $error');
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'ရောဂါအလိုက် မှတ်တမ်း ရယူ၍မရပါ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      error.toString().replaceAll('Exception: ', ''),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
