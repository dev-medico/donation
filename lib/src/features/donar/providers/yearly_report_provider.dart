import 'package:donation/src/features/donar/donar_yearly_report.dart';
import 'package:donation/src/features/services/donar_record_service.dart';
import 'package:donation/src/features/services/expense_record_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Provider to fetch yearly report data
final yearlyReportProvider = FutureProvider.family<YearlyReportData, int>((ref, year) async {
  final donarService = ref.read(donarRecordServiceProvider);
  final expenseService = ref.read(expenseRecordServiceProvider);
  
  try {
    // Fetch monthly stats for the selected year
    final donarStats = await donarService.getMonthlyStats(year: year);
    final expenseStats = await expenseService.getMonthlyStats(year: year);
    
    // Calculate opening balance from previous year's data
    final previousYearStats = await donarService.getYearlyStats(
      startYear: year - 1,
      endYear: year - 1,
    );
    
    int openingBalance = 0;
    if (previousYearStats.isNotEmpty) {
      final prevYearData = previousYearStats.first;
      final prevDonation = prevYearData['total_donation'] ?? 0;
      final prevExpense = prevYearData['total_expense'] ?? 0;
      openingBalance = (prevDonation - prevExpense).toInt();
    }
    
    // Process monthly data
    List<int> monthlyDonations = List.filled(12, 0);
    List<int> monthlyExpenses = List.filled(12, 0);
    int totalDonation = 0;
    int totalExpense = 0;
    
    // Map the stats data by month
    Map<int, dynamic> donationsByMonth = {};
    Map<int, dynamic> expensesByMonth = {};
    
    for (var stat in donarStats) {
      // Handle both String and num types for month
      var monthValue = stat['month'];
      int month = monthValue is String ? int.parse(monthValue) : (monthValue as num).toInt();
      donationsByMonth[month] = stat;
    }
    
    for (var stat in expenseStats) {
      // Handle both String and num types for month
      var monthValue = stat['month'];
      int month = monthValue is String ? int.parse(monthValue) : (monthValue as num).toInt();
      expensesByMonth[month] = stat;
    }
    
    // Fill monthly arrays for all 12 months
    for (int i = 1; i <= 12; i++) {
      if (donationsByMonth.containsKey(i)) {
        int amount = (donationsByMonth[i]['total_donation'] ?? 0).toInt();
        monthlyDonations[i - 1] = amount;
        totalDonation += amount;
      }
      
      if (expensesByMonth.containsKey(i)) {
        int amount = (expensesByMonth[i]['total_expense'] ?? 0).toInt();
        monthlyExpenses[i - 1] = amount;
        totalExpense += amount;
      }
    }
    
    int closingBalance = openingBalance + totalDonation - totalExpense;
    
    return YearlyReportData(
      openingBalance: openingBalance,
      monthlyDonation: monthlyDonations,
      monthlyExpense: monthlyExpenses,
      closingBalance: closingBalance,
      totalDonationAmount: totalDonation,
      totalExpense: totalExpense,
      selectedYear: year,
    );
  } catch (e) {
    print('Error fetching yearly report: $e');
    throw e;
  }
});

// Data model for yearly report
class YearlyReportData {
  final int openingBalance;
  final List<int> monthlyDonation;
  final List<int> monthlyExpense;
  final int closingBalance;
  final int totalDonationAmount;
  final int totalExpense;
  final int selectedYear;
  
  YearlyReportData({
    required this.openingBalance,
    required this.monthlyDonation,
    required this.monthlyExpense,
    required this.closingBalance,
    required this.totalDonationAmount,
    required this.totalExpense,
    required this.selectedYear,
  });
}

// Available years provider
final availableYearsProvider = FutureProvider<List<int>>((ref) async {
  final donarService = ref.read(donarRecordServiceProvider);
  
  try {
    // Get all yearly stats to determine available years
    final yearlyStats = await donarService.getYearlyStats();
    
    Set<int> years = {};
    for (var stat in yearlyStats) {
      // Handle both String and num types for year
      var yearValue = stat['year'];
      int year = yearValue is String ? int.parse(yearValue) : (yearValue as num).toInt();
      years.add(year);
    }
    
    // Add current year if not present
    years.add(DateTime.now().year);
    
    // Sort years in descending order
    final sortedYears = years.toList()..sort((a, b) => b.compareTo(a));
    
    return sortedYears;
  } catch (e) {
    print('Error fetching available years: $e');
    // Return default years if API fails
    final currentYear = DateTime.now().year;
    return List.generate(10, (index) => currentYear - index);
  }
});