import 'package:donation/src/features/services/base_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final expenseRecordLoadingStatusProvider = StateProvider<String>((ref) => '');
final expenseRecordServiceProvider =
    Provider<ExpenseRecordService>((ref) => ExpenseRecordService(ref));

class ExpenseRecordService extends BaseService {
  final ProviderRef? ref;

  ExpenseRecordService([this.ref]);

  // Base path for all expense record endpoints
  final String _basePath = '/expenses-record';

  void _updateLoadingStatus(String status) {
    if (ref != null) {
      ref!.read(expenseRecordLoadingStatusProvider.notifier).state = status;
    }
  }

  Future<List<dynamic>> getExpenseRecords({
    int page = 0,
    int limit = 50,
    String? startDate,
    String? endDate,
  }) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Fetching expense records...');

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
      throw Exception('Failed to fetch expense records');
    } catch (e) {
      print('Error fetching expense records: $e');
      _updateLoadingStatus('Error: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> createExpenseRecord(Map<String, dynamic> data) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Creating expense record...');

    try {
      final response = await apiClient.post(
        '$_basePath/create',
        data: data,
        options: {'headers': headers},
      );

      _updateLoadingStatus('Expense record created successfully!');
      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data!['data'] as Map<String, dynamic>;
      }
      throw Exception('Failed to create expense record');
    } catch (e) {
      print('Error creating expense record: $e');
      _updateLoadingStatus('Error: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> updateExpenseRecord(
      String id, Map<String, dynamic> data) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Updating expense record...');

    try {
      final response = await apiClient.post(
        '$_basePath/update/$id',
        data: data,
        options: {'headers': headers},
      );

      _updateLoadingStatus('Expense record updated successfully!');
      if (response.statusCode == 200) {
        return response.data!['data'] as Map<String, dynamic>;
      }
      throw Exception('Failed to update expense record');
    } catch (e) {
      print('Error updating expense record: $e');
      _updateLoadingStatus('Error: $e');
      throw e;
    }
  }

  Future<void> deleteExpenseRecord(String id) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Deleting expense record...');

    try {
      final response = await apiClient.post(
        '$_basePath/delete/$id',
        options: {'headers': headers},
      );

      _updateLoadingStatus('Expense record deleted successfully!');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete expense record');
      }
    } catch (e) {
      print('Error deleting expense record: $e');
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