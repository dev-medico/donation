import 'package:donation/src/features/services/base_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService extends BaseService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    final data = response.data!;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', data['token']);
    await prefs.setString('name', email);

    return data;
  }

  Future<Map<String, dynamic>> memberLogin(String phone) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/auth/member-login',
      data: {
        'phone': phone,
      },
    );

    final data = response.data!;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', data['token']);
    await prefs.setString('memberPhone', phone);

    return data;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('name');
    await prefs.remove('memberPhone');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  Future<bool> isMemberLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('memberPhone') != null;
  }
}
