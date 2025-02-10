import 'package:donation/core/api/api_client.dart';
import 'package:donation/core/api/api_response.dart';
import 'package:donation/models/donar_record.dart';

class DonarRecordRepository {
  final ApiClient _apiClient;
  static const String _baseUrl = '/api/donar-records';

  DonarRecordRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<ApiResponse<List<DonarRecord>>> getAllDonarRecords() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(_baseUrl);
      return ApiResponse.fromJsonList(
        response.data!,
        (json) => (json)
            .map((item) => DonarRecord.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<DonarRecord>> getDonarRecordById(String id) async {
    try {
      final response =
          await _apiClient.get<Map<String, dynamic>>('$_baseUrl/$id');
      return ApiResponse.fromJson(
        response.data!,
        (json) => DonarRecord.fromJson(json),
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<DonarRecord>> createDonarRecord(DonarRecord record) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        _baseUrl,
        data: record.toJson(),
      );
      return ApiResponse.fromJson(
        response.data!,
        (json) => DonarRecord.fromJson(json),
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<DonarRecord>> updateDonarRecord(
      String id, DonarRecord record) async {
    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        '$_baseUrl/$id',
        data: record.toJson(),
      );
      return ApiResponse.fromJson(
        response.data!,
        (json) => DonarRecord.fromJson(json),
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<void>> deleteDonarRecord(String id) async {
    try {
      await _apiClient.delete('$_baseUrl/$id');
      return ApiResponse(
          success: true, message: 'Donar record deleted successfully');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<List<DonarRecord>>> searchDonarRecords({
    String? name,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        if (name != null) 'name': name,
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
            .map((item) => DonarRecord.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
