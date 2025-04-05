import 'package:donation/src/features/services/base_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/src/features/donation/models/donation.dart';
import 'dart:math';

final donationLoadingStatusProvider = StateProvider<String>((ref) => '');
final donationServiceProvider =
    Provider<DonationService>((ref) => DonationService(ref));

class DonationService extends BaseService {
  final ProviderRef? ref;

  DonationService([this.ref]);

  // Base path for all donation endpoints
  final String _basePath = '/donation';

  void _updateLoadingStatus(String status) {
    if (ref != null) {
      ref!.read(donationLoadingStatusProvider.notifier).state = status;
    }
  }

  // Future<List<dynamic>> getDonations({int limit = 500}) async {
  //   final headers = await getAuthHeaders();
  //   _updateLoadingStatus('Fetching donations...');

  //   List<dynamic> allDonations = [];
  //   int currentPage = 0;
  //   bool hasMoreData = true;

  //   try {
  //     while (hasMoreData) {
  //       _updateLoadingStatus('Fetching donations page ${currentPage + 1}...');

  //       final response = await apiClient.get(
  //         _basePath,
  //         queryParameters: {
  //           'limit': limit.toString(),
  //           'page': currentPage.toString(),
  //         },
  //         options: {'headers': headers},
  //       );

  //       if (response.statusCode == 200) {
  //         final pageData = response.data!['data'] as List<dynamic>;
  //         allDonations.addAll(pageData);

  //         hasMoreData = response.data!['hasMore'] == true;

  //         if (hasMoreData) {
  //           currentPage++;
  //         }
  //       } else {
  //         hasMoreData = false;
  //       }
  //     }

  //     _updateLoadingStatus('');
  //     return allDonations;
  //   } catch (e) {
  //     print('Error fetching donations: $e');
  //     _updateLoadingStatus('Error: $e');
  //     return allDonations;
  //   }
  // }

  Future<List<dynamic>> getDonationsByMonthYear(int month, int year,
      {int limit = 500}) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Fetching donations for $month/$year...');

    try {
      // Make a single API call instead of paginating in a loop
      final response = await apiClient.get(
        '$_basePath/by-month-year',
        queryParameters: {
          'month': month.toString(),
          'year': year.toString(),
          'limit': limit.toString(),
          'page': '0', // Just get the first page
        },
        options: {'headers': headers},
      );

      _updateLoadingStatus('');
      if (response.statusCode == 200) {
        return response.data!['data'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      print('Error fetching donations by month/year: $e');
      _updateLoadingStatus('Error: $e');
      return [];
    }
  }

  Future<List<dynamic>> getDonationsByYear(int year, {int limit = 500}) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Fetching donations for $year...');

    List<dynamic> allDonations = [];
    int currentPage = 0;
    bool hasMoreData = true;

    try {
      while (hasMoreData) {
        _updateLoadingStatus(
            'Fetching donations for $year page ${currentPage + 1}...');

        final response = await apiClient.get(
          '$_basePath/by-year',
          queryParameters: {
            'year': year.toString(),
            'limit': limit.toString(),
            'page': currentPage.toString(),
          },
          options: {'headers': headers},
        );

        if (response.statusCode == 200) {
          final pageData = response.data!['data'] as List<dynamic>;
          allDonations.addAll(pageData);

          hasMoreData = response.data!['hasMore'] == true;

          if (hasMoreData) {
            currentPage++;
          }
        } else {
          hasMoreData = false;
        }
      }

      _updateLoadingStatus('');
      return allDonations;
    } catch (e) {
      print('Error fetching donations by year: $e');
      _updateLoadingStatus('Error: $e');
      return allDonations;
    }
  }

  Future<Map<String, dynamic>> getDonationById(String id) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Fetching donation details...');

    try {
      final response = await apiClient.get(
        '$_basePath/$id',
        options: {'headers': headers},
      );

      _updateLoadingStatus('');
      if (response.statusCode == 200) {
        return response.data!['data'] as Map<String, dynamic>;
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
        '$_basePath/create',
        data: data,
        options: {'headers': headers},
      );

      _updateLoadingStatus('Donation created successfully!');
      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data!['data'] as Map<String, dynamic>;
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
      final response = await apiClient.post(
        '$_basePath/update',
        data: data,
        queryParameters: {'id': id},
        options: {'headers': headers},
      );

      _updateLoadingStatus('Donation updated successfully!');
      if (response.statusCode == 200) {
        return response.data!['data'] as Map<String, dynamic>;
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
      final response = await apiClient.post(
        '$_basePath/delete',
        queryParameters: {'id': id},
        options: {'headers': headers},
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
        options: {'headers': headers},
      );

      _updateLoadingStatus('');
      if (response.statusCode == 200) {
        return response.data! as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      print('Error fetching donation stats: $e');
      _updateLoadingStatus('Error: $e');
      return {};
    }
  }
}
