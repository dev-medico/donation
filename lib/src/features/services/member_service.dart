import 'package:donation/src/features/services/base_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dio/dio.dart';

final memberServiceProvider = Provider<MemberService>((ref) => MemberService());

class MemberService extends BaseService {
  Future<List<dynamic>> getMembers({String? search, String? bloodType}) async {
    final headers = await getAuthHeaders();

    String url = 'members';
    if (search != null && search.isNotEmpty) {
      url += '?search=$search';
    }
    if (bloodType != null && bloodType != "သွေးအုပ်စု အလိုက်ကြည့်မည်") {
      url += (search != null && search.isNotEmpty) ? '&' : '?';
      url += 'blood_type=$bloodType';
    }

    final response = await apiClient.get(
      url,
      options: Options(headers: headers),
    );

    return response.data['data'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> getMemberByPhone(String phone) async {
    final headers = await getAuthHeaders();

    final response = await apiClient.get(
      'members/by-phone/$phone',
      options: Options(headers: headers),
    );

    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMemberStats() async {
    final headers = await getAuthHeaders();

    final response = await apiClient.get(
      'members/stats',
      options: Options(headers: headers),
    );

    return response.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getMembersByAgeRange(int start, int end) async {
    final headers = await getAuthHeaders();

    final response = await apiClient.get(
      'members/by-age-range',
      queryParameters: {
        'start': start,
        'end': end,
      },
      options: Options(headers: headers),
    );

    return response.data['data'] as List<dynamic>;
  }

  Future<List<dynamic>> getMembersByTotalCount() async {
    final headers = await getAuthHeaders();

    final response = await apiClient.get(
      'members/by-total-count',
      options: Options(headers: headers),
    );

    return response.data['data'] as List<dynamic>;
  }
}
