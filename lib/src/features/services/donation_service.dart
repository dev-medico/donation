import 'package:donation/src/features/services/base_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:donation/src/features/donation/models/donation.dart';
import 'dart:math';

final donationLoadingStatusProvider = StateProvider<String>((ref) => '');
final donationServiceProvider =
    Provider<DonationService>((ref) => DonationService(ref));

class DonationService extends BaseService {
  final ProviderRef? ref;

  DonationService([this.ref]);

  // Base path for all donation endpoints
  final String _basePath = '/donations';

  void _updateLoadingStatus(String status) {
    if (ref != null) {
      ref!.read(donationLoadingStatusProvider.notifier).state = status;
    }
  }

  Future<List<dynamic>> getDonations({int limit = 200}) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Fetching donations...');

    try {
    final response = await apiClient.get(
        _basePath,
      options: Options(headers: headers),
        queryParameters: {'limit': limit},
    );

      _updateLoadingStatus('');
      if (response.statusCode == 200) {
    return response.data['data'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      print('Error fetching donations: $e');
      _updateLoadingStatus('Error: $e');
      return [];
    }
  }

  Future<List<dynamic>> getDonationsByMonthYear(int month, int year) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Fetching donations for $month/$year...');

    try {
    final response = await apiClient.get(
        '$_basePath/by-month-year',
      queryParameters: {
        'month': month,
        'year': year,
      },
      options: Options(headers: headers),
    );

      _updateLoadingStatus('');
      if (response.statusCode == 200) {
    return response.data['data'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      print('Error fetching donations by month/year: $e');
      _updateLoadingStatus('Error: $e');
      return [];
    }
  }

  Future<List<dynamic>> getDonationsByYear(int year) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Fetching donations for $year...');

    try {
    final response = await apiClient.get(
        '$_basePath/by-year/$year',
      options: Options(headers: headers),
    );

      _updateLoadingStatus('');
      if (response.statusCode == 200) {
    return response.data['data'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      print('Error fetching donations by year: $e');
      _updateLoadingStatus('Error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getDonationById(String id) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Fetching donation details...');

    try {
      final response = await apiClient.get(
        '$_basePath/$id',
        options: Options(headers: headers),
      );

      _updateLoadingStatus('');
      if (response.statusCode == 200) {
        return response.data['data'] as Map<String, dynamic>;
      }
      throw Exception('Donation not found');
    } catch (e) {
      print('Error fetching donation by ID: $e');
      _updateLoadingStatus('Error: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> createDonation(Map<String, dynamic> data) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Creating donation...');

    try {
    final response = await apiClient.post(
        _basePath,
      data: data,
      options: Options(headers: headers),
    );

      _updateLoadingStatus('Donation created successfully!');
      if (response.statusCode == 201 || response.statusCode == 200) {
    return response.data['data'] as Map<String, dynamic>;
      }
      throw Exception('Failed to create donation');
    } catch (e) {
      print('Error creating donation: $e');
      _updateLoadingStatus('Error: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> updateDonation(
      String id, Map<String, dynamic> data) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Updating donation...');

    try {
    final response = await apiClient.put(
        '$_basePath/$id',
      data: data,
      options: Options(headers: headers),
    );

      _updateLoadingStatus('Donation updated successfully!');
      if (response.statusCode == 200) {
    return response.data['data'] as Map<String, dynamic>;
      }
      throw Exception('Failed to update donation');
    } catch (e) {
      print('Error updating donation: $e');
      _updateLoadingStatus('Error: $e');
      throw e;
    }
  }

  Future<void> deleteDonation(String id) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Deleting donation...');

    try {
      final response = await apiClient.delete(
        '$_basePath/$id',
      options: Options(headers: headers),
    );

      _updateLoadingStatus('Donation deleted successfully!');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete donation');
      }
    } catch (e) {
      print('Error deleting donation: $e');
      _updateLoadingStatus('Error: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> getDonationStats() async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Fetching donation statistics...');

    try {
    final response = await apiClient.get(
        '$_basePath/stats',
      options: Options(headers: headers),
    );

      _updateLoadingStatus('');
      if (response.statusCode == 200) {
    return response.data as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      print('Error fetching donation stats: $e');
      _updateLoadingStatus('Error: $e');
      return {};
    }
  }
}
