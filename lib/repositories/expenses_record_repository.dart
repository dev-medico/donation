import 'package:donation/core/api/api_client.dart';
import 'package:donation/core/api/api_response.dart';
import 'package:donation/models/expenses_record.dart';

class ExpensesRecordRepository {
  final ApiClient _apiClient;
  static const String _baseUrl = '/api/expenses-records';

  ExpensesRecordRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<ApiResponse<List<ExpensesRecord>>> getAllExpensesRecords() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(_baseUrl);
      return ApiResponse.fromJsonList(
        response.data!,
        (json) => (json)
            .map(
                (item) => ExpensesRecord.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<ExpensesRecord>> getExpensesRecordById(String id) async {
    try {
      final response =
          await _apiClient.get<Map<String, dynamic>>('$_baseUrl/$id');
      return ApiResponse.fromJson(
        response.data!,
        (json) => ExpensesRecord.fromJson(json),
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<ExpensesRecord>> createExpensesRecord(
      ExpensesRecord record) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        _baseUrl,
        data: record.toJson(),
      );
      return ApiResponse.fromJson(
        response.data!,
        (json) => ExpensesRecord.fromJson(json),
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<ExpensesRecord>> updateExpensesRecord(
      String id, ExpensesRecord record) async {
    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        '$_baseUrl/$id',
        data: record.toJson(),
      );
      return ApiResponse.fromJson(
        response.data!,
        (json) => ExpensesRecord.fromJson(json),
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<void>> deleteExpensesRecord(String id) async {
    try {
      await _apiClient.delete('$_baseUrl/$id');
      return ApiResponse(
          success: true, message: 'Expenses record deleted successfully');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<List<ExpensesRecord>>> searchExpensesRecords({
    String? category,
    String? description,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        if (category != null) 'category': category,
        if (description != null) 'description': description,
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
            .map(
                (item) => ExpensesRecord.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
