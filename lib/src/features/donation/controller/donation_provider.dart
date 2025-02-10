import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/src/features/services/donation_service.dart';
import 'package:donation/src/features/donation/models/donation.dart';

typedef DonationFilterModel = ({int? month, int? year});

final donationStreamProvider = StreamProvider<List<Donation>>((ref) async* {
  final donationService = ref.read(donationServiceProvider);
  while (true) {
    final donationsJson = await donationService.getDonations();
    final donations = donationsJson
        .map((json) => Donation.fromJson(json as Map<String, dynamic>))
        .toList();
    yield donations;
    await Future.delayed(
        const Duration(seconds: 30)); // Refresh every 30 seconds
  }
});

final donationProvider = FutureProvider<List<Donation>>((ref) async {
  final donationService = ref.read(donationServiceProvider);
  final donationsJson = await donationService.getDonations();
  return donationsJson
      .map((json) => Donation.fromJson(json as Map<String, dynamic>))
      .toList();
});

final donationByMonthYearStreamProvider =
    StreamProvider.family<List<Donation>, DonationFilterModel>(
        (ref, filter) async* {
  final donationService = ref.read(donationServiceProvider);
  while (true) {
    final donationsJson = await donationService.getDonationsByMonthYear(
      filter.month!,
      filter.year!,
    );
    final donations = donationsJson
        .map((json) => Donation.fromJson(json as Map<String, dynamic>))
        .toList();
    yield donations;
    await Future.delayed(
        const Duration(seconds: 30)); // Refresh every 30 seconds
  }
});

final donationByYearProvider =
    FutureProvider.family<List<Donation>, int>((ref, year) async {
  final donationService = ref.read(donationServiceProvider);
  final donationsJson = await donationService.getDonationsByYear(year);
  return donationsJson
      .map((json) => Donation.fromJson(json as Map<String, dynamic>))
      .toList();
});

final donationStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final donationService = ref.read(donationServiceProvider);
  return donationService.getDonationStats();
});
