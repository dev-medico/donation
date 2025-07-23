import 'package:flutter/material.dart';
import 'package:donation/responsive.dart';
import 'package:donation/utils/Colors.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/src/features/services/report_service.dart';

final bloodTypeStatsProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  try {
    final reportService = ref.read(reportServiceProvider);
    return await reportService.getBloodTypeStats();
  } catch (e) {
    throw Exception('Failed to load blood type stats: $e');
  }
});

class DonationChartByBlood extends ConsumerStatefulWidget {
  final bool? fromDashboard;

  DonationChartByBlood({
    Key? key,
    this.fromDashboard,
  }) : super(key: key);

  @override
  ConsumerState<DonationChartByBlood> createState() =>
      _DonationChartByBloodState();
}

class _DonationChartByBloodState extends ConsumerState<DonationChartByBlood> {
  final List<String> bloodTypes = [
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
  Widget build(BuildContext context) {
    final bloodStats = ref.watch(bloodTypeStatsProvider);

    return bloodStats.when(
          data: (data) {
            final bloodTypeData = Map<String, int>.from(data['data']);
            final totalDonations = data['totalDonations'] as int? ?? 0;

            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.fromDashboard ?? false
                        ? "သွေးအုပ်စုအလိုက် လှူဒါန်းမှု မှတ်တမ်း"
                        : "သွေးအုပ်စုအလိုက် မှတ်တမ်း",
                    style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 13 : 16.5,
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: Responsive.isMobile(context) ? 10 : 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "သွေးအမျိုးအစား",
                        style: TextStyle(
                          fontSize: Responsive.isMobile(context) ? 12 : 16.5,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            "အရေအတွက်",
                            style: TextStyle(
                              fontSize:
                                  Responsive.isMobile(context) ? 12 : 16.5,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 50),
                          Text(
                            "%",
                            style: TextStyle(
                              fontSize:
                                  Responsive.isMobile(context) ? 12 : 16.5,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  ...bloodTypes.map((bloodType) {
                    final count = bloodTypeData[bloodType] ?? 0;
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 80,
                            child: Text(
                              bloodType,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize:
                                    Responsive.isMobile(context) ? 12 : 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 60,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  count.toString(),
                                  style: TextStyle(
                                    fontSize: Responsive.isMobile(context)
                                        ? 12
                                        : 16,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
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
                                Responsive.isMobile(context) ? 12 : 16.5,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          totalDonations.toString(),
                          style: TextStyle(
                            fontSize:
                                Responsive.isMobile(context) ? 12 : 16.5,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
          },
          loading: () => Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                error.toString().replaceAll('Exception: ', ''),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
  }
}
