import 'package:donation/src/features/donar/donar_yearly_report.dart';
import 'package:donation/src/features/donar/providers/yearly_report_provider.dart';
import 'package:donation/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class YearlyReportScreen extends ConsumerStatefulWidget {
  const YearlyReportScreen({Key? key}) : super(key: key);
  static const routeName = "/yearly-report";

  @override
  ConsumerState<YearlyReportScreen> createState() => _YearlyReportScreenState();
}

class _YearlyReportScreenState extends ConsumerState<YearlyReportScreen> {
  int selectedYear = DateTime.now().year;
  
  @override
  Widget build(BuildContext context) {
    final yearlyReportAsync = ref.watch(yearlyReportProvider(selectedYear));
    final availableYearsAsync = ref.watch(availableYearsProvider);
    
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [primaryColor, primaryDark],
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          "ရ/သုံး ငွေစာရင်း",
          style: TextStyle(fontSize: 17, color: Colors.white),
        ),
        actions: [
          // Year selector dropdown
          availableYearsAsync.when(
            data: (years) => Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: DropdownButton<int>(
                value: selectedYear,
                dropdownColor: primaryColor,
                style: const TextStyle(color: Colors.white),
                underline: Container(),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                items: years.map((year) {
                  return DropdownMenuItem<int>(
                    value: year,
                    child: Text(
                      year.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedYear = value;
                    });
                  }
                },
              ),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            error: (_, __) => const SizedBox(),
          ),
        ],
      ),
      body: yearlyReportAsync.when(
        data: (reportData) => DonationYearlyReport(
          openingBalance: reportData.openingBalance,
          monthlyDonation: reportData.monthlyDonation,
          monthlyExpense: reportData.monthlyExpense,
          closingBalance: reportData.closingBalance,
          totalDonationAmount: reportData.totalDonationAmount,
          totalExpense: reportData.totalExpense,
          selectedYear: reportData.selectedYear,
        ),
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading yearly report...'),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading report',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Refresh the provider
                  ref.invalidate(yearlyReportProvider(selectedYear));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}