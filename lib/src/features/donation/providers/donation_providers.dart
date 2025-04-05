import 'package:donation/src/features/donation/models/donation.dart';
import 'package:donation/src/features/services/donation_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final donationsByMonthYearProvider =
    FutureProvider.family<List<Donation>, ({int month, int year})>(
        (ref, params) async {
  final donationService = ref.read(donationServiceProvider);
  final donationsData =
      await donationService.getDonationsByMonthYear(params.month, params.year);

  return donationsData.map((data) => Donation.fromJson(data)).toList();
});

final donationsByYearProvider =
    FutureProvider.family<List<Donation>, int>((ref, year) async {
  final donationService = ref.read(donationServiceProvider);
  final donationsData = await donationService.getDonationsByYear(year);

  return donationsData.map((data) => Donation.fromJson(data)).toList();
});

final donationStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final donationService = ref.read(donationServiceProvider);
  return donationService.getDonationStats();
});

final selectedDonationProvider = StateProvider<Donation?>((ref) => null);
