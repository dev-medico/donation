import 'package:donation/src/features/services/base_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:donation/core/api/api_client.dart';
import 'package:donation/src/features/donation_member/domain/member.dart';

final memberServiceProvider = Provider<MemberService>((ref) => MemberService());

class MemberService extends BaseService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Member>> searchMembers({
    String? query,
    String? bloodType,
    int page = 0,
    int limit = 50,
  }) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/member/index',
        queryParameters: {
          'q': query ?? '',
          'blood_type': bloodType,
          'page': page,
          'limit': limit,
        },
      );

      if (response.data != null && response.data!['status'] == 'ok') {
        final List<dynamic> memberData = response.data!['data'];
        return memberData.map((json) => Member.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print('Error searching members: $e');
      return [];
    }
  }

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
