import 'package:donation/src/features/services/base_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final donarRecordLoadingStatusProvider = StateProvider<String>((ref) => '');
final donarRecordServiceProvider =
    Provider<DonarRecordService>((ref) => DonarRecordService(ref));

class DonarRecordService extends BaseService {
  final ProviderRef? ref;

  DonarRecordService([this.ref]);

  // Base path for all donar record endpoints
  final String _basePath = '/donar-record';

  void _updateLoadingStatus(String status) {
    if (ref != null) {
      ref!.read(donarRecordLoadingStatusProvider.notifier).state = status;
    }
  }

  Future<List<dynamic>> getDonarRecords({
    int page = 0,
    int limit = 50,
    String? startDate,
    String? endDate,
  }) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Fetching donar records...');

    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        if (startDate != null) 'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
      };

      final response = await apiClient.get(
        _basePath,
        options: {'headers': headers},
        queryParameters: queryParams,
      );

      _updateLoadingStatus('');
      if (response.statusCode == 200) {
        if (response.data != null && response.data!['data'] != null) {
          return response.data!['data'] as List<dynamic>;
        }
        return [];
      }
      throw Exception('Failed to fetch donar records');
    } catch (e) {
      print('Error fetching donar records: $e');
      _updateLoadingStatus('Error: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> createDonarRecord(Map<String, dynamic> data) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Creating donar record...');

    try {
      final response = await apiClient.post(
        '$_basePath/create',
        data: data,
        options: {'headers': headers},
      );

      _updateLoadingStatus('Donar record created successfully!');
      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data!['data'] as Map<String, dynamic>;
      }
      throw Exception('Failed to create donar record');
    } catch (e) {
      print('Error creating donar record: $e');
      _updateLoadingStatus('Error: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> updateDonarRecord(
      String id, Map<String, dynamic> data) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Updating donar record...');

    try {
      final response = await apiClient.post(
        '$_basePath/update/$id',
        data: data,
        options: {'headers': headers},
      );

      _updateLoadingStatus('Donar record updated successfully!');
      if (response.statusCode == 200) {
        return response.data!['data'] as Map<String, dynamic>;
      }
      throw Exception('Failed to update donar record');
    } catch (e) {
      print('Error updating donar record: $e');
      _updateLoadingStatus('Error: $e');
      throw e;
    }
  }

  Future<void> deleteDonarRecord(String id) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Deleting donar record...');

    try {
      final response = await apiClient.post(
        '$_basePath/delete/$id',
        options: {'headers': headers},
      );

      _updateLoadingStatus('Donar record deleted successfully!');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete donar record');
      }
    } catch (e) {
      print('Error deleting donar record: $e');
      _updateLoadingStatus('Error: $e');
      throw e;
    }
  }

  Future<List<dynamic>> getMonthlyStats({int? year}) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Fetching monthly statistics...');

    try {
      final queryParams = {
        if (year != null) 'year': year,
      };

      final response = await apiClient.get(
        '$_basePath/monthly-stats',
        options: {'headers': headers},
        queryParameters: queryParams,
      );

      _updateLoadingStatus('');
      if (response.statusCode == 200) {
        if (response.data != null && response.data!['data'] != null) {
          return response.data!['data'] as List<dynamic>;
        }
        return [];
      }
      throw Exception('Failed to fetch monthly statistics');
    } catch (e) {
      print('Error fetching monthly stats: $e');
      _updateLoadingStatus('Error: $e');
      throw e;
    }
  }

  Future<List<dynamic>> getYearlyStats({int? startYear, int? endYear}) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Fetching yearly statistics...');

    try {
      final queryParams = {
        if (startYear != null) 'startYear': startYear,
        if (endYear != null) 'endYear': endYear,
      };

      final response = await apiClient.get(
        '$_basePath/yearly-stats',
        options: {'headers': headers},
        queryParameters: queryParams,
      );

      _updateLoadingStatus('');
      if (response.statusCode == 200) {
        if (response.data != null && response.data!['data'] != null) {
          return response.data!['data'] as List<dynamic>;
        }
        return [];
      }
      throw Exception('Failed to fetch yearly statistics');
    } catch (e) {
      print('Error fetching yearly stats: $e');
      _updateLoadingStatus('Error: $e');
      throw e;
    }
  }
}