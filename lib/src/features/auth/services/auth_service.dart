import 'package:donation/core/api/api_client.dart';
import 'package:donation/data/response/login_response/login_response.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  final _apiClient = ApiClient();

  Future<LoginResponse> login(String email, String password) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      return LoginResponse.fromJson(response.data!);
    } catch (e) {
      rethrow;
    }
  }
} 