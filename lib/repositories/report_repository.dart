import 'package:donation/core/api/api_client.dart';
import 'package:donation/core/api/api_response.dart';

class ReportRepository {
  final ApiClient _apiClient;
  static const String _baseUrl = 'report';

  ReportRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<ApiResponse<Map<String, dynamic>>> getDashboard() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>('$_baseUrl/dashboard');
      
      if (response.data == null) {
        return ApiResponse.error('Invalid response data');
      }
      
      final jsonData = response.data!;
      
      if (jsonData['success'] == true) {
        return ApiResponse<Map<String, dynamic>>(
          success: true,
          message: jsonData['message'] ?? 'Dashboard retrieved successfully',
          data: jsonData['data'] as Map<String, dynamic>,
        );
      } else {
        return ApiResponse.error(jsonData['message'] ?? 'Failed to retrieve dashboard');
      }
    } catch (e) {
      return ApiResponse.error('Error fetching dashboard: $e');
    }
  }
  
  Future<Map<String, dynamic>> getDiseaseStats() async {
    try {
      final response =
          await _apiClient.get<Map<String, dynamic>>('$_baseUrl/by-disease');
      if (response.data != null && response.data!['success'] == true) {
        return response.data!;
      }
      throw Exception(
          response.data?['message'] ?? 'Failed to fetch disease stats');
    } catch (e) {
      throw Exception('Error fetching disease stats: $e');
    }
  }
}
