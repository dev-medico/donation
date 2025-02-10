import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/models/donation.dart';
import 'package:donation/repositories/donation_repository.dart';
import 'package:donation/services/donation_service.dart';

// Repository provider
final donationRepositoryProvider = Provider<DonationRepository>((ref) {
  return DonationRepository();
});

// Service provider
final donationServiceProvider = Provider<DonationService>((ref) {
  final repository = ref.watch(donationRepositoryProvider);
  return DonationService(repository: repository);
});

// All donations provider
final donationsProvider = FutureProvider<List<Donation>>((ref) async {
  final service = ref.watch(donationServiceProvider);
  final response = await service.getAllDonations();
  if (!response.success) {
    throw Exception(response.message);
  }
  return response.data ?? [];
});

// Selected donation provider
final selectedDonationProvider =
    FutureProvider.family<Donation, String>((ref, id) async {
  final service = ref.watch(donationServiceProvider);
  final response = await service.getDonationById(id);
  if (!response.success) {
    throw Exception(response.message);
  }
  return response.data!;
});

// Member donations provider
final memberDonationsProvider =
    FutureProvider.family<List<Donation>, String>((ref, memberId) async {
  final service = ref.watch(donationServiceProvider);
  final response = await service.getDonationsByMemberId(memberId);
  if (!response.success) {
    throw Exception(response.message);
  }
  return response.data ?? [];
});

// Donation search provider
final donationSearchProvider =
    FutureProvider.family<List<Donation>, Map<String, dynamic>>(
        (ref, searchParams) async {
  final service = ref.watch(donationServiceProvider);
  final response = await service.searchDonations(
    hospital: searchParams['hospital'] as String?,
    patientName: searchParams['patientName'] as String?,
    fromDate: searchParams['fromDate'] as DateTime?,
    toDate: searchParams['toDate'] as DateTime?,
  );
  if (!response.success) {
    throw Exception(response.message);
  }
  return response.data ?? [];
});

// Donation creation state
final donationCreationStateProvider = StateProvider<AsyncValue<void>>((ref) {
  return const AsyncValue.data(null);
});

// Donation update state
final donationUpdateStateProvider = StateProvider<AsyncValue<void>>((ref) {
  return const AsyncValue.data(null);
});

// Donation deletion state
final donationDeletionStateProvider = StateProvider<AsyncValue<void>>((ref) {
  return const AsyncValue.data(null);
});

// Create donation provider
final createDonationProvider =
    FutureProvider.family<void, Map<String, dynamic>>(
        (ref, donationData) async {
  final service = ref.watch(donationServiceProvider);
  final stateNotifier = ref.read(donationCreationStateProvider.notifier);

  try {
    stateNotifier.state = const AsyncValue.loading();

    final response = await service.createDonation(
      memberId: donationData['memberId'] as String,
      hospital: donationData['hospital'] as String,
      patientName: donationData['patientName'] as String?,
      patientAge: donationData['patientAge'] as String?,
      patientDisease: donationData['patientDisease'] as String?,
      patientAddress: donationData['patientAddress'] as String?,
      ownerId: donationData['ownerId'] as String,
    );

    if (!response.success) {
      throw Exception(response.message);
    }

    stateNotifier.state = const AsyncValue.data(null);
  } catch (error, stackTrace) {
    stateNotifier.state = AsyncValue.error(error, stackTrace);
    rethrow;
  }
});

// Update donation provider
final updateDonationProvider =
    FutureProvider.family<void, Map<String, dynamic>>(
        (ref, donationData) async {
  final service = ref.watch(donationServiceProvider);
  final stateNotifier = ref.read(donationUpdateStateProvider.notifier);

  try {
    stateNotifier.state = const AsyncValue.loading();

    final response = await service.updateDonation(
      donationData['id'] as String,
      hospital: donationData['hospital'] as String?,
      patientName: donationData['patientName'] as String?,
      patientAge: donationData['patientAge'] as String?,
      patientDisease: donationData['patientDisease'] as String?,
      patientAddress: donationData['patientAddress'] as String?,
    );

    if (!response.success) {
      throw Exception(response.message);
    }

    stateNotifier.state = const AsyncValue.data(null);
  } catch (error, stackTrace) {
    stateNotifier.state = AsyncValue.error(error, stackTrace);
    rethrow;
  }
});

// Delete donation provider
final deleteDonationProvider =
    FutureProvider.family<void, String>((ref, id) async {
  final service = ref.watch(donationServiceProvider);
  final stateNotifier = ref.read(donationDeletionStateProvider.notifier);

  try {
    stateNotifier.state = const AsyncValue.loading();

    final response = await service.deleteDonation(id);
    if (!response.success) {
      throw Exception(response.message);
    }

    stateNotifier.state = const AsyncValue.data(null);
  } catch (error, stackTrace) {
    stateNotifier.state = AsyncValue.error(error, stackTrace);
    rethrow;
  }
});
