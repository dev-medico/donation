import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/src/features/services/donation_service.dart';
import 'package:donation/src/features/donation/models/donation.dart';

typedef DonationFilterModel = ({int year, int month});


// Stream provider for donations by month and year - refreshes every 30 seconds
final donationByMonthYearStreamProvider =
    StreamProvider.family<List<Donation>, DonationFilterModel>(
        (ref, filter) async* {
  final donationService = ref.read(donationServiceProvider);
  while (true) {
    final donationsJson = await donationService.getDonationsByMonthYear(
      filter.month,
      filter.year,
    );
    final donations = donationsJson
        .map((json) => Donation.fromJson(json as Map<String, dynamic>))
        .toList();
    yield donations;
    await Future.delayed(const Duration(seconds: 30));
  }
});

// Future provider for donations by year - one-time fetch
final donationByYearProvider =
    FutureProvider.family<List<Donation>, int>((ref, year) async {
  final donationService = ref.read(donationServiceProvider);
  final donationsJson = await donationService.getDonationsByYear(year);
  return donationsJson
      .map((json) => Donation.fromJson(json as Map<String, dynamic>))
      .toList();
});

// Provider for donation statistics
final donationStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final donationService = ref.read(donationServiceProvider);
  return donationService.getDonationStats();
});

// Main provider used in the donation list screen - one-time fetch by month and year
final donationListProvider =
    FutureProvider.family<List<Donation>, DonationFilterModel>(
        (ref, filter) async {
  final donationService = ref.read(donationServiceProvider);
  final donationsJson = await donationService.getDonationsByMonthYear(
    filter.month,
    filter.year,
  );
  return donationsJson
      .map((json) => Donation.fromJson(json as Map<String, dynamic>))
      .toList();
});

// Donation loading status provider
final donationLoadingStatusProvider = StateProvider<String>((ref) => '');

// Selected donation for detail view
final selectedDonationProvider = StateProvider<Donation?>((ref) => null);
