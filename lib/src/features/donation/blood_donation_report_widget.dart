import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:donation/responsive.dart';
import 'package:donation/utils/Colors.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/src/features/services/report_service.dart';

// Create a key class for the provider parameters
class BloodDonationReportParams {
  final int? year;
  final int? month;
  
  const BloodDonationReportParams({this.year, this.month});
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BloodDonationReportParams &&
          runtimeType == other.runtimeType &&
          year == other.year &&
          month == other.month;

  @override
  int get hashCode => year.hashCode ^ month.hashCode;
}

// Cache provider to prevent unnecessary API calls
final _bloodDonationReportCache = <BloodDonationReportParams, Map<String, dynamic>>{};

final bloodDonationReportProvider = FutureProvider
    .family<Map<String, dynamic>, BloodDonationReportParams>((ref, params) async {
  // Check cache first
  if (_bloodDonationReportCache.containsKey(params)) {
    log('Returning cached data for year=${params.year}, month=${params.month}');
    return _bloodDonationReportCache[params]!;
  }
  
  try {
    log('Blood donation report params: year=${params.year}, month=${params.month}');
    final reportService = ref.read(reportServiceProvider);
    
    // Use blood donation report endpoint directly
    final result = await reportService.getBloodDonationReport(
      year: params.year,
      month: params.month,
    );
    log('Blood donation report result received');
    
    // Cache the result
    _bloodDonationReportCache[params] = result;
    
    return result;
  } catch (e, stack) {
    log('Error in bloodDonationReportProvider: $e');
    log('Stack trace: $stack');
    
    // Return mock data for testing if API fails
    if (e.toString().contains('404') || e.toString().contains('Not Found')) {
      log('API endpoint not found, returning mock data');
      return {
        'totalDonations': 0,
        'bloodTypes': [],
        'diseases': [],
        'hospitals': [],
        'monthlyBreakdown': [],
      };
    }
    
    throw Exception('Failed to load blood donation report: $e');
  }
});

class BloodDonationReportWidget extends ConsumerWidget {
  final int? year;
  final int? month;
  final bool isYearly;

  const BloodDonationReportWidget({
    Key? key,
    this.year,
    this.month,
    required this.isYearly,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = BloodDonationReportParams(year: year, month: month);
    final reportData = ref.watch(bloodDonationReportProvider(params));

    return reportData.when(
      data: (data) {
        log('Building UI with data');
        
        // Simple data extraction
        final totalDonations = data['totalDonations'] ?? 0;
        final bloodTypes = data['bloodTypes'] ?? [];
        final diseases = data['diseases'] ?? [];
        final hospitals = data['hospitals'] ?? [];
        final monthlyBreakdown = data['monthlyBreakdown'] ?? [];

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Responsive.isMobile(context)
              ? Column(
                  children: [
                    _buildSummaryCard(context, totalDonations),
                    const SizedBox(height: 20),
                    if (isYearly && monthlyBreakdown.isNotEmpty) ...[
                      _buildMonthlyBreakdown(context, monthlyBreakdown),
                      const SizedBox(height: 20),
                    ],
                    _buildBloodTypeChart(context, bloodTypes, totalDonations),
                    const SizedBox(height: 20),
                    _buildDiseaseChart(context, diseases, totalDonations),
                    const SizedBox(height: 20),
                    _buildHospitalChart(context, hospitals, totalDonations),
                  ],
                )
              : Column(
                  children: [
                    _buildSummaryCard(context, totalDonations),
                    const SizedBox(height: 20),
                    if (isYearly && monthlyBreakdown.isNotEmpty) ...[
                      _buildMonthlyBreakdown(context, monthlyBreakdown),
                      const SizedBox(height: 20),
                    ],
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: _buildBloodTypeChart(
                                context, bloodTypes, totalDonations)),
                        const SizedBox(width: 20),
                        Expanded(
                            child: _buildDiseaseChart(
                                context, diseases, totalDonations)),
                        const SizedBox(width: 20),
                        Expanded(
                            child: _buildHospitalChart(
                                context, hospitals, totalDonations)),
                      ],
                    ),
                  ],
                ),
        );
      },
      loading: () {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('မှတ်တမ်းများ ရယူနေသည်...'),
            ],
          ),
        );
      },
      error: (error, stack) {
        log('Error in blood donation report: $error');
        log('Stack trace: $stack');
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'မှတ်တမ်းများ ရယူ၍မရပါ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString().replaceAll('Exception: ', ''),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(bloodDonationReportProvider);
                  },
                  child: Text('ပြန်လည်ကြိုးစားမည်'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(BuildContext context, int totalDonations) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [primaryColor, primaryDark],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            isYearly
                ? "${year ?? ''} ခုနှစ် သွေးလှူဒါန်းမှု မှတ်တမ်း"
                : "${year ?? ''} ခုနှစ် ${_getMonthName(month ?? 0)} လ သွေးလှူဒါန်းမှု မှတ်တမ်း",
            style: TextStyle(
              fontSize: Responsive.isMobile(context) ? 18 : 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            "စုစုပေါင်း သွေးလှူဒါန်းမှု အရေအတွက်",
            style: TextStyle(
              fontSize: Responsive.isMobile(context) ? 14 : 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            totalDonations.toString(),
            style: TextStyle(
              fontSize: Responsive.isMobile(context) ? 36 : 42,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "အကြিམ်",
            style: TextStyle(
              fontSize: Responsive.isMobile(context) ? 14 : 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyBreakdown(
      BuildContext context, List<Map<String, dynamic>> monthlyData) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "လစဉ် သွေးလှူဒါန်းမှု ပမာဏ",
            style: TextStyle(
              fontSize: Responsive.isMobile(context) ? 16 : 18,
              color: primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: monthlyData.map((data) {
              final month = (data['month'] as num?)?.toInt() ?? 0;
              final count = (data['count'] as num?)?.toInt() ?? 0;
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      _getMonthName(month),
                      style: TextStyle(
                        fontSize: 12,
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBloodTypeChart(BuildContext context,
      List<Map<String, dynamic>> bloodTypes, int totalDonations) {
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
                Row(
                  children: [
                    Text(
                      "အရေအတွက်",
                      style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 14 : 15,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 20),
                    Text(
                      "%",
                      style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 14 : 15,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 16),
            Expanded(
              child: bloodTypes.isEmpty
                  ? Center(
                      child: Text(
                        "မှတ်တမ်း မရှိပါ",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: bloodTypes.length,
                      itemBuilder: (context, index) {
                        final bloodType = bloodTypes[index];
                        final type = bloodType['blood_type'] as String? ?? '';
                        final count = (bloodType['count'] ??
                                bloodType['quantity']) as int? ??
                            0;
                        final percentage =
                            (bloodType['percentage'] as num?)?.toDouble() ??
                                0.0;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  type.isEmpty ? "-" : type,
                                  style: TextStyle(
                                    fontSize:
                                        Responsive.isMobile(context) ? 14 : 15,
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
                                            ? 14
                                            : 15,
                                        color: primaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 40,
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "${percentage.toStringAsFixed(1)}%",
                                      style: TextStyle(
                                        fontSize: Responsive.isMobile(context)
                                            ? 12
                                            : 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ],
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

  Widget _buildDiseaseChart(BuildContext context,
      List<Map<String, dynamic>> diseases, int totalDonations) {
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
                Row(
                  children: [
                    Text(
                      "အရေအတွက်",
                      style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 14 : 15,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 20),
                    Text(
                      "%",
                      style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 14 : 15,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 16),
            Expanded(
              child: diseases.isEmpty
                  ? Center(
                      child: Text(
                        "မှတ်တမ်း မရှိပါ",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: diseases.length,
                      itemBuilder: (context, index) {
                        final disease = diseases[index];
                        final name = disease['disease'] as String? ?? '';
                        final count =
                            (disease['count'] ?? disease['quantity']) as int? ??
                                0;
                        final percentage =
                            (disease['percentage'] as num?)?.toDouble() ?? 0.0;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  name.isEmpty ? "-" : name,
                                  style: TextStyle(
                                    fontSize:
                                        Responsive.isMobile(context) ? 14 : 15,
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
                                            ? 14
                                            : 15,
                                        color: primaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 40,
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "${percentage.toStringAsFixed(1)}%",
                                      style: TextStyle(
                                        fontSize: Responsive.isMobile(context)
                                            ? 12
                                            : 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ],
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

  Widget _buildHospitalChart(BuildContext context,
      List<Map<String, dynamic>> hospitals, int totalDonations) {
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
                Row(
                  children: [
                    Text(
                      "အရေအတွက်",
                      style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 14 : 15,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 20),
                    Text(
                      "%",
                      style: TextStyle(
                        fontSize: Responsive.isMobile(context) ? 14 : 15,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 16),
            Expanded(
              child: hospitals.isEmpty
                  ? Center(
                      child: Text(
                        "မှတ်တမ်း မရှိပါ",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: hospitals.length,
                      itemBuilder: (context, index) {
                        final hospital = hospitals[index];
                        final name = hospital['hospital'] as String? ?? '';
                        final count = (hospital['count'] ??
                                hospital['quantity']) as int? ??
                            0;
                        final percentage =
                            (hospital['percentage'] as num?)?.toDouble() ?? 0.0;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  name.isEmpty ? "-" : name,
                                  style: TextStyle(
                                    fontSize:
                                        Responsive.isMobile(context) ? 14 : 15,
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
                                            ? 14
                                            : 15,
                                        color: primaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 40,
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "${percentage.toStringAsFixed(1)}%",
                                      style: TextStyle(
                                        fontSize: Responsive.isMobile(context)
                                            ? 12
                                            : 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ],
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
      "",
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return month >= 1 && month <= 12 ? months[month] : '';
  }
}
