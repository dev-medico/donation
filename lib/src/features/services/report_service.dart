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

      if (response.data != null && response.data!['status'] == 'ok') {
        final data = response.data!['data'];
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception(
            response.data?['message'] ?? 'Failed to load disease stats');
      }
    } catch (e) {
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
}
