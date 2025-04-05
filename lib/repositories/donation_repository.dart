import 'package:donation/core/api/api_client.dart';
import 'package:donation/core/api/api_response.dart';
import 'package:donation/models/donation.dart';

class DonationRepository {
  final ApiClient _apiClient;
  static const String _baseUrl = 'donations';

  DonationRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<ApiResponse<List<Donation>>> getAllDonations() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(_baseUrl);
      return ApiResponse.fromJsonList(
        response.data!,
        (json) => (json)
            .map((item) => Donation.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Donation>> getDonationById(String id) async {
    try {
      final response =
          await _apiClient.get<Map<String, dynamic>>('$_baseUrl/$id');
      return ApiResponse.fromJson(
        response.data!,
        (json) => Donation.fromJson(json),
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<List<Donation>>> getDonationsByMemberId(
      String memberId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_baseUrl/member/$memberId',
      );
      return ApiResponse.fromJsonList(
        response.data!,
        (json) => (json)
            .map((item) => Donation.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Donation>> createDonation(Donation donation) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        _baseUrl,
        data: donation.toJson(),
      );
      return ApiResponse.fromJson(
        response.data!,
        (json) => Donation.fromJson(json),
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Donation>> updateDonation(
      String id, Donation donation) async {
    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        '$_baseUrl/$id',
        data: donation.toJson(),
      );
      return ApiResponse.fromJson(
        response.data!,
        (json) => Donation.fromJson(json),
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<void>> deleteDonation(String id) async {
    try {
      await _apiClient.post('$_baseUrl/delete/$id');
      return ApiResponse(
          success: true, message: 'Donation deleted successfully');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<List<Donation>>> searchDonations({
    String? hospital,
    String? patientName,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        if (hospital != null) 'hospital': hospital,
        if (patientName != null) 'patient_name': patientName,
        if (fromDate != null) 'from_date': fromDate.toIso8601String(),
        if (toDate != null) 'to_date': toDate.toIso8601String(),
      };

      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_baseUrl/search',
        queryParameters: queryParameters,
      );

      return ApiResponse.fromJsonList(
        response.data!,
        (json) => (json)
            .map((item) => Donation.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
