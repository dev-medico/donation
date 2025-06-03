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
        child: bloodStats.when(
          data: (data) {
            final bloodTypeData = Map<String, int>.from(data['data']);
            final totalDonations = data['totalDonations'] as int? ?? 0;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.fromDashboard ?? false
                        ? "သွေးအုပ်စုအလိုက် လှူဒါန်းမှု မှတ်တမ်း"
                        : "သွေးအုပ်စုအလိုက် မှတ်တမ်း",
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
                        "သွေးအမျိုးအစား",
                        style: TextStyle(
                          fontSize: Responsive.isMobile(context) ? 15.5 : 16.5,
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
                                  Responsive.isMobile(context) ? 15.5 : 16.5,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 50),
                          Text(
                            "%",
                            style: TextStyle(
                              fontSize:
                                  Responsive.isMobile(context) ? 15.5 : 16.5,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
                      itemCount: bloodTypes.length,
                      itemBuilder: (BuildContext context, int index) {
                        final bloodType = bloodTypes[index];
                        final count = bloodTypeData[bloodType] ?? 0;
                        // final percentage = totalDonations > 0
                        //     ? (count / totalDonations * 100).toStringAsFixed(1)
                        //     : '0.0';

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
                                        Responsive.isMobile(context) ? 15 : 16,
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
                                            ? 15
                                            : 16,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                                  // Container(
                                  //   width: 50,
                                  //   alignment: Alignment.centerRight,
                                  //   child: Text(
                                  //     percentage,
                                  //     style: TextStyle(
                                  //       fontSize: Responsive.isMobile(context)
                                  //           ? 15
                                  //           : 16,
                                  //       color: Colors.grey,
                                  //     ),
                                  //   ),
                                  // ),
                                ],
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
        ),
      ),
    );
  }
}
