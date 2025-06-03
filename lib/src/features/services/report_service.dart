import 'dart:developer';
import 'package:donation/core/api/api_client.dart';
import 'package:donation/src/features/services/base_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final reportServiceProvider = Provider<ReportService>((ref) => ReportService());

class ReportService extends BaseService {
  Future<List<Map<String, dynamic>>> getDiseaseStats() async {
    try {
      final apiClient = ApiClient();
      final response = await apiClient.get<Map<String, dynamic>>(
        '/report/by-disease',
      );
      
      log('Disease stats response: ${response.data}');

      if (response.data != null && response.data!['status'] == 'ok') {
        final data = response.data!['data'];
        final rawResult = List<Map<String, dynamic>>.from(data);
        
        // Map the data to expected format
        final result = rawResult.map((item) {
          return {
            'name': item['patient_disease'] ?? item['name'] ?? '',
            'count': int.tryParse(item['quantity']?.toString() ?? item['count']?.toString() ?? '0') ?? 0,
          };
        }).toList();
        
        log('Mapped disease stats: $result');
        
        return result;
      } else {
        throw Exception(
            response.data?['message'] ?? 'API returned error status');
      }
    } catch (e) {
      log('Error in getDiseaseStats: $e');
      throw Exception('Error loading disease stats: $e');
    }
  }

  Future<Map<String, dynamic>> getGenderStats() async {
    try {
      final apiClient = ApiClient();
      final response = await apiClient.get<Map<String, dynamic>>(
        '/report/by-gender',
      );

      if (response.data != null && response.data!['status'] == 'ok') {
        final data = response.data!;
        final genderData = List<Map<String, dynamic>>.from(data['data']);
        return {
          'genderStats': genderData,
          'averageAge': data['averageAge'],
          'ageRanges': Map<String, int>.from(data['ageRanges']),
          'totalDonations': data['totalDonations'],
          'totalMembers': data['totalMembers'],
        };
      } else {
        throw Exception(
            response.data?['message'] ?? 'Failed to load gender stats');
      }
    } catch (e) {
      throw Exception('Error loading gender stats: $e');
    }
  }

  Future<Map<String, dynamic>> getBloodTypeStats() async {
    try {
      final apiClient = ApiClient();
      final response = await apiClient.get<Map<String, dynamic>>(
        '/report/by-blood-type',
      );

      if (response.data != null && response.data!['status'] == 'ok') {
        final bloodTypeData =
            List<Map<String, dynamic>>.from(response.data!['data']);
        final bloodTypeMap = Map<String, int>.fromEntries(
          bloodTypeData.map((item) => MapEntry(
                item['blood_type'] as String,
                (item['quantity'] as num).toInt(),
              )),
        );

        return {
          'data': bloodTypeMap,
          'totalDonations': response.data!['totalDonations'],
        };
      } else {
        throw Exception(
            response.data?['message'] ?? 'Failed to load blood type stats');
      }
    } catch (e) {
      throw Exception('Error loading blood type stats: $e');
    }
  }

  Future<Map<String, dynamic>> getHospitalStats() async {
    try {
      final apiClient = ApiClient();
      final response = await apiClient.get<Map<String, dynamic>>(
        '/report/by-hospital',
      );

      if (response.data != null && response.data!['status'] == 'ok') {
        final hospitalData =
            List<Map<String, dynamic>>.from(response.data!['data']);
        final hospitalMap = Map<String, int>.fromEntries(
          hospitalData.map((item) => MapEntry(
                item['hospital'] as String,
                (item['quantity'] as num).toInt(),
              )),
        );

        return {
          'data': hospitalMap,
          'totalDonations': response.data!['totalDonations'],
        };
      } else {
        throw Exception(
            response.data?['message'] ?? 'Failed to load hospital stats');
      }
    } catch (e) {
      throw Exception('Error loading hospital stats: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getRequestGiveStats() async {
    try {
      final apiClient = ApiClient();
      final response = await apiClient.get<Map<String, dynamic>>(
        '/report/by-request-give',
      );

      if (response.data != null && response.data!['status'] == 'ok') {
        return List<Map<String, dynamic>>.from(response.data!['data']);
      } else {
        throw Exception(
            response.data?['message'] ?? 'Failed to load request/give stats');
      }
    } catch (e) {
      throw Exception('Error loading request/give stats: $e');
    }
  }

  Future<Map<String, dynamic>> getDonationSummary({int? year, int? month}) async {
    try {
      final apiClient = ApiClient();
      
      // Build query parameters properly using ApiClient's queryParameters feature
      Map<String, dynamic> queryParams = {};
      if (year != null) queryParams['year'] = year;
      if (month != null) queryParams['month'] = month;
      
      final response = await apiClient.get<Map<String, dynamic>>(
        '/report/donation-summary',
        queryParameters: queryParams,
      );

      if (response.data != null && response.data!['status'] == 'ok') {
        final data = response.data!['data'] as Map<String, dynamic>;
        return data;
      } else {
        throw Exception(
            response.data?['message'] ?? 'Failed to load donation summary');
      }
    } catch (e) {
      throw Exception('Error loading donation summary: $e');
    }
  }

  Future<Map<String, dynamic>> getBloodDonationReport({int? year, int? month}) async {
    try {
      final apiClient = ApiClient();
      
      // Build query parameters properly using ApiClient's queryParameters feature
      Map<String, dynamic> queryParams = {};
      if (year != null) queryParams['year'] = year;
      if (month != null) queryParams['month'] = month;
      
      log('Calling blood donation report API with params: $queryParams');
      
      // Use Yii2 action naming convention
      final response = await apiClient.get<Map<String, dynamic>>(
        '/report/blood-donation-report',
        queryParameters: queryParams,
      );
      
      log('Blood donation report API response status: ${response.statusCode}');
      log('Blood donation report API response data: ${response.data}');

      if (response.data != null && response.data!['status'] == 'ok') {
        final data = response.data!['data'] as Map<String, dynamic>;
        return data;
      } else {
        throw Exception(
            response.data?['message'] ?? 'Failed to load blood donation report');
      }
    } catch (e) {
      log('Error in getBloodDonationReport: $e');
      throw Exception('Error loading blood donation report: $e');
    }
  }
}
