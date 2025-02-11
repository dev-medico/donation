import 'package:donation/core/api/api_client.dart';
import 'package:donation/core/api/api_response.dart';

class ReportRepository {
  final ApiClient _apiClient;
  static const String _baseUrl = '/report';

  ReportRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<Map<String, dynamic>> getDiseaseStats() async {
    try {
      final response =
          await _apiClient.get<Map<String, dynamic>>('$_baseUrl/by-disease');
      if (response.data != null && response.data!['status'] == 'ok') {
        return response.data!;
      }
      throw Exception(
          response.data?['message'] ?? 'Failed to fetch disease stats');
    } catch (e) {
      throw Exception('Error fetching disease stats: $e');
    }
  }
}
