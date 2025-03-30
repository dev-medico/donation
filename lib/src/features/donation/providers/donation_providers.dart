import 'package:donation/src/features/donation/models/donation.dart';
import 'package:donation/src/features/services/donation_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final donationListProvider =
    AsyncNotifierProvider<DonationListNotifier, List<Donation>>(() {
  return DonationListNotifier();
});

class DonationListNotifier extends AsyncNotifier<List<Donation>> {
  @override
  Future<List<Donation>> build() async {
    return fetchDonations();
  }

  Future<List<Donation>> fetchDonations() async {
    final donationService = ref.read(donationServiceProvider);
    final donationsData = await donationService.getDonations();

    final donations =
        donationsData.map((data) => Donation.fromJson(data)).toList();
    return donations;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => fetchDonations());
  }

  Future<Donation> getDonationById(String id) async {
    final donationService = ref.read(donationServiceProvider);
    final donationData = await donationService.getDonationById(id);
    return Donation.fromJson(donationData);
  }

  Future<Donation> createDonation(Map<String, dynamic> data) async {
    final donationService = ref.read(donationServiceProvider);
    final donationData = await donationService.createDonation(data);

    // Refresh the list to include the new donation
    refresh();

    return Donation.fromJson(donationData);
  }

  Future<Donation> updateDonation(String id, Map<String, dynamic> data) async {
    final donationService = ref.read(donationServiceProvider);
    final donationData = await donationService.updateDonation(id, data);

    // Refresh the list to reflect the updated donation
    refresh();

    return Donation.fromJson(donationData);
  }

  Future<void> deleteDonation(String id) async {
    final donationService = ref.read(donationServiceProvider);
    await donationService.deleteDonation(id);

    // Refresh the list to remove the deleted donation
    refresh();
  }
}

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
