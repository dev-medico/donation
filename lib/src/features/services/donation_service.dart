import 'package:donation/src/features/services/base_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dio/dio.dart';

final donationServiceProvider =
    Provider<DonationService>((ref) => DonationService());

class DonationService extends BaseService {
  Future<List<dynamic>> getDonations() async {
    final headers = await getAuthHeaders();
    final response = await apiClient.get(
      'donations',
      options: Options(headers: headers),
    );
    return response.data['data'] as List<dynamic>;
  }

  Future<List<dynamic>> getDonationsByMonthYear(int month, int year) async {
    final headers = await getAuthHeaders();
    final response = await apiClient.get(
      'donations/by-month-year',
      queryParameters: {
        'month': month,
        'year': year,
      },
      options: Options(headers: headers),
    );
    return response.data['data'] as List<dynamic>;
  }

  Future<List<dynamic>> getDonationsByYear(int year) async {
    final headers = await getAuthHeaders();
    final response = await apiClient.get(
      'donations/by-year/$year',
      options: Options(headers: headers),
    );
    return response.data['data'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> createDonation(Map<String, dynamic> data) async {
    final headers = await getAuthHeaders();
    final response = await apiClient.post(
      'donations',
      data: data,
      options: Options(headers: headers),
    );
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateDonation(
      String id, Map<String, dynamic> data) async {
    final headers = await getAuthHeaders();
    final response = await apiClient.put(
      'donations/$id',
      data: data,
      options: Options(headers: headers),
    );
    return response.data['data'] as Map<String, dynamic>;
  }

  Future<void> deleteDonation(String id) async {
    final headers = await getAuthHeaders();
    await apiClient.delete(
      'donations/$id',
      options: Options(headers: headers),
    );
  }

  Future<Map<String, dynamic>> getDonationStats() async {
    final headers = await getAuthHeaders();
    final response = await apiClient.get(
      'donations/stats',
      options: Options(headers: headers),
    );
    return response.data as Map<String, dynamic>;
  }
}
