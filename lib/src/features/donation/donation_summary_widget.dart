import 'package:flutter/material.dart';
import 'package:donation/responsive.dart';
import 'package:donation/utils/Colors.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/src/features/services/report_service.dart';

final donationSummaryProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, Map<String, int?>>((ref, params) async {
  try {
    final reportService = ref.read(reportServiceProvider);
    final result = await reportService.getDonationSummary(
      year: params['year'],
      month: params['month'],
    );
    return result;
  } catch (e) {
    throw Exception('Failed to load donation summary: $e');
  }
});

class DonationSummaryWidget extends ConsumerWidget {
  final int? year;
  final int? month;
  final bool isYearly;

  const DonationSummaryWidget({
    Key? key,
    this.year,
    this.month,
    required this.isYearly,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryData = ref.watch(donationSummaryProvider({
      'year': year,
      'month': month,
    }));

    return summaryData.when(
      data: (data) {
        final totalDonations = data['totalDonations'] as int? ?? 0;
        final diseases = List<Map<String, dynamic>>.from(data['diseases'] ?? []);
        final bloodTypes = Map<String, dynamic>.from(data['bloodTypes'] ?? {});
        final hospitals = List<Map<String, dynamic>>.from(data['hospitals'] ?? []);

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Responsive.isMobile(context)
              ? Column(
                  children: [
                    _buildSummaryCard(context, totalDonations),
                    const SizedBox(height: 20),
                    _buildDiseaseChart(context, diseases, totalDonations),
                    const SizedBox(height: 20),
                    _buildBloodTypeChart(context, bloodTypes, totalDonations),
                    const SizedBox(height: 20),
                    _buildHospitalChart(context, hospitals, totalDonations),
                  ],
                )
              : Column(
                  children: [
                    _buildSummaryCard(context, totalDonations),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildDiseaseChart(context, diseases, totalDonations)),
                        const SizedBox(width: 20),
                        Expanded(child: _buildBloodTypeChart(context, bloodTypes, totalDonations)),
                        const SizedBox(width: 20),
                        Expanded(child: _buildHospitalChart(context, hospitals, totalDonations)),
                      ],
                    ),
                  ],
                ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
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

  Widget _buildSummaryCard(BuildContext context, int totalDonations) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            isYearly
                ? "${year ?? ''} ခုနှစ် သွေးလှူဒါန်းမှု"
                : "${year ?? ''} ခုနှစ် ${_getMonthName(month ?? 0)} လ သွေးလှူဒါန်းမှု",
            style: TextStyle(
              fontSize: Responsive.isMobile(context) ? 18 : 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "စုစုပေါင်း အရေအတွက်",
            style: TextStyle(
              fontSize: Responsive.isMobile(context) ? 14 : 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            totalDonations.toString(),
            style: TextStyle(
              fontSize: Responsive.isMobile(context) ? 32 : 36,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiseaseChart(BuildContext context, List<Map<String, dynamic>> diseases, int totalDonations) {
    return Container(
      height: Responsive.isMobile(context) ? 400 : 450,
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
      child: Padding(
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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "ဖြစ်ပွားသည့်ရောဂါ",
                  style: TextStyle(
                    fontSize: Responsive.isMobile(context) ? 14 : 15,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
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
            const Divider(height: 16),
            Expanded(
              child: diseases.isEmpty
                  ? Center(
                      child: Text(
                        "မှတ်တမ်း မရှိပါ",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: diseases.length,
                      itemBuilder: (context, index) {
                        final disease = diseases[index];
                        final name = disease['name'] as String? ?? '';
                        final count = disease['count'] as int? ?? 0;
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  name.isEmpty ? "-" : name,
                                  style: TextStyle(
                                    fontSize: Responsive.isMobile(context) ? 14 : 15,
                                    color: Colors.black,
                                  ),
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
                          ),
                        );
                      },
                    ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "စုစုပေါင်း အရေအတွက်",
                    style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 14 : 15,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    totalDonations.toString(),
                    style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 14 : 15,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBloodTypeChart(BuildContext context, Map<String, dynamic> bloodTypes, int totalDonations) {
    final bloodTypesList = [
      "A (Rh +)",
      "B (Rh +)",
      "AB (Rh +)",
      "O (Rh +)",
      "A (Rh -)",
      "B (Rh -)",
      "AB (Rh -)",
      "O (Rh -)",
    ];

    return Container(
      height: Responsive.isMobile(context) ? 400 : 450,
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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "သွေးအုပ်စုအလိုက် မှတ်တမ်း",
              style: TextStyle(
                fontSize: Responsive.isMobile(context) ? 15.5 : 16.5,
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "သွေးအမျိုးအစား",
                  style: TextStyle(
                    fontSize: Responsive.isMobile(context) ? 14 : 15,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
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
            const Divider(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: bloodTypesList.length,
                itemBuilder: (context, index) {
                  final bloodType = bloodTypesList[index];
                  final typeData = bloodTypes[bloodType] as Map<String, dynamic>?;
                  final count = typeData?['quantity'] as int? ?? 0;
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          bloodType,
                          style: TextStyle(
                            fontSize: Responsive.isMobile(context) ? 14 : 15,
                            color: Colors.black,
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
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "စုစုပေါင်း အရေအတွက်",
                    style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 14 : 15,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    totalDonations.toString(),
                    style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 14 : 15,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalChart(BuildContext context, List<Map<String, dynamic>> hospitals, int totalDonations) {
    return Container(
      height: Responsive.isMobile(context) ? 400 : 450,
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
      child: Padding(
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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "လှူဒါန်းသည့်နေရာ",
                  style: TextStyle(
                    fontSize: Responsive.isMobile(context) ? 14 : 15,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
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
            const Divider(height: 16),
            Expanded(
              child: hospitals.isEmpty
                  ? Center(
                      child: Text(
                        "မှတ်တမ်း မရှိပါ",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: hospitals.length,
                      itemBuilder: (context, index) {
                        final hospital = hospitals[index];
                        final name = hospital['hospital'] as String? ?? '';
                        final count = hospital['quantity'] as int? ?? 0;
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  name.isEmpty ? "-" : name,
                                  style: TextStyle(
                                    fontSize: Responsive.isMobile(context) ? 14 : 15,
                                    color: Colors.black,
                                  ),
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
                          ),
                        );
                      },
                    ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "စုစုပေါင်း အရေအတွက်",
                    style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 14 : 15,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    totalDonations.toString(),
                    style: TextStyle(
                      fontSize: Responsive.isMobile(context) ? 14 : 15,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return month >= 1 && month <= 12 ? months[month - 1] : '';
  }
}