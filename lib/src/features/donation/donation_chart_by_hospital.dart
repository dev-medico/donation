import 'package:flutter/material.dart';
import 'package:donation/responsive.dart';
import 'package:donation/utils/Colors.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/src/features/services/report_service.dart';

final hospitalStatsProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  try {
    final reportService = ref.read(reportServiceProvider);
    return await reportService.getHospitalStats();
  } catch (e) {
    throw Exception('Failed to load hospital stats: $e');
  }
});

class DonationChartByHospital extends ConsumerStatefulWidget {
  DonationChartByHospital({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<DonationChartByHospital> createState() =>
      _DonationChartByHospitalState();
}

class _DonationChartByHospitalState
    extends ConsumerState<DonationChartByHospital> {
  @override
  Widget build(BuildContext context) {
    final hospitalStats = ref.watch(hospitalStatsProvider);

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
        child: hospitalStats.when(
          data: (data) {
            final hospitalData = Map<String, int>.from(data['data']);
            final totalDonations = data['totalDonations'] as int? ?? 0;
            final sortedHospitals = hospitalData.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "လှူဒါန်းသည့်နေရာအလိုက် မှတ်တမ်း",
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
                        "လှူဒါန်းသည့်နေရာ",
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
                      itemCount: sortedHospitals.length,
                      itemBuilder: (BuildContext context, int index) {
                        final hospital = sortedHospitals[index];
                        final count = hospital.value;
                        // final percentage = totalDonations > 0
                        //     ? (count / totalDonations * 100).toStringAsFixed(1)
                        //     : '0.0';

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  hospital.key.isEmpty ? "-" : hospital.key,
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
