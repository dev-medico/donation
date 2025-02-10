import 'package:donation/core/api/api_response.dart';
import 'package:donation/models/donation.dart';
import 'package:donation/repositories/donation_repository.dart';

class DonationService {
  final DonationRepository _repository;

  DonationService({DonationRepository? repository})
      : _repository = repository ?? DonationRepository();

  Future<ApiResponse<List<Donation>>> getAllDonations() async {
    return await _repository.getAllDonations();
  }

  Future<ApiResponse<Donation>> getDonationById(String id) async {
    return await _repository.getDonationById(id);
  }

  Future<ApiResponse<List<Donation>>> getDonationsByMemberId(
      String memberId) async {
    return await _repository.getDonationsByMemberId(memberId);
  }

  Future<ApiResponse<Donation>> createDonation({
    required String memberId,
    required String hospital,
    String? patientName,
    String? patientAge,
    String? patientDisease,
    String? patientAddress,
    required String ownerId,
  }) async {
    final donation = Donation(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(), // Will be replaced by backend
      date: DateTime.now().toIso8601String(),
      donationDate: DateTime.now(),
      hospital: hospital,
      memberId: memberId,
      patientName: patientName,
      patientAge: patientAge,
      patientDisease: patientDisease,
      patientAddress: patientAddress,
      ownerId: ownerId,
    );

    return await _repository.createDonation(donation);
  }

  Future<ApiResponse<Donation>> updateDonation(
    String id, {
    String? hospital,
    String? patientName,
    String? patientAge,
    String? patientDisease,
    String? patientAddress,
  }) async {
    final response = await _repository.getDonationById(id);
    if (!response.success) {
      return response;
    }

    final updatedDonation = response.data!.copyWith(
      hospital: hospital,
      patientName: patientName,
      patientAge: patientAge,
      patientDisease: patientDisease,
      patientAddress: patientAddress,
    );

    return await _repository.updateDonation(id, updatedDonation);
  }

  Future<ApiResponse<void>> deleteDonation(String id) async {
    return await _repository.deleteDonation(id);
  }

  Future<ApiResponse<List<Donation>>> searchDonations({
    String? hospital,
    String? patientName,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    return await _repository.searchDonations(
      hospital: hospital,
      patientName: patientName,
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  Future<ApiResponse<List<Donation>>> getDonationsByDateRange(
    DateTime fromDate,
    DateTime toDate,
  ) async {
    return await searchDonations(
      fromDate: fromDate,
      toDate: toDate,
    );
  }

  Future<ApiResponse<List<Donation>>> getDonationsByHospital(
      String hospital) async {
    return await searchDonations(hospital: hospital);
  }
}
