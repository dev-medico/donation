import 'package:donation/core/api/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BaseService {
  final _apiClient = ApiClient();

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  ApiClient get apiClient => _apiClient;
}
