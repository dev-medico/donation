import 'package:donation/src/features/services/base_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:donation/core/api/api_client.dart';
import 'package:donation/src/features/donation_member/domain/member.dart';

final memberServiceProvider = Provider<MemberService>((ref) => MemberService());

class MemberService extends BaseService {
  // Base path for all member endpoints
  final String _basePath = '/member';

  Future<List<Member>> searchMembers({
    String? query,
    String? bloodType,
    int page = 0,
    int limit = 50,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'q': query ?? '',
        'page': page,
        'limit': limit,
      };

      if (bloodType != null) {
        params['blood_type'] = bloodType;
      }

      print('Searching members with params: $params');

      final response = await apiClient.get<Map<String, dynamic>>(
        _basePath + '/index',
        queryParameters: params,
      );

      print('Search members response status: ${response.statusCode}');
      print('Search members response data: ${response.data}');

      if (response.data != null && response.data!['status'] == 'ok') {
        final List<dynamic> memberData = response.data!['data'];
        final members =
            memberData.map((json) => Member.fromJson(json)).toList();
        print('Parsed ${members.length} members');
        return members;
      }

      print('No members found or invalid response format');
      return [];
    } catch (e) {
      print('Error searching members: $e');
      return [];
    }
  }

  Future<List<dynamic>> getMembers({String? search, String? bloodType}) async {
    final headers = await getAuthHeaders();

    final Map<String, dynamic> params = {};
    if (search != null && search.isNotEmpty) {
      params['search'] = search;
    }
    if (bloodType != null && bloodType != "သွေးအုပ်စု အလိုက်ကြည့်မည်") {
      params['blood_type'] = bloodType;
    }

    print('Getting members with params: $params');

    final response = await apiClient.get(
      _basePath + '/index',
      queryParameters: params,
      options: Options(headers: headers),
    );

    print('Get members response status: ${response.statusCode}');

    return response.data['data'] as List<dynamic>;
  }

  Future<Member> getMemberById(String id) async {
    final headers = await getAuthHeaders();

    print('Getting member by ID: $id');

    final response = await apiClient.get(
      '$_basePath/view?$id',
      options: Options(headers: headers),
    );

    print('Get member by ID response status: ${response.statusCode}');

    return Member.fromJson(response.data['data']);
  }

  Future<Map<String, dynamic>> getMemberByPhone(String phone) async {
    final headers = await getAuthHeaders();

    print('Getting member by phone: $phone');

    final response = await apiClient.get(
      '$_basePath/by-phone/$phone',
      options: Options(headers: headers),
    );

    print('Get member by phone response status: ${response.statusCode}');

    return response.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMemberStats() async {
    final headers = await getAuthHeaders();

    print('Getting member stats');

    final response = await apiClient.get(
      '$_basePath/stats',
      options: Options(headers: headers),
    );

    print('Get member stats response status: ${response.statusCode}');

    return response.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getMembersByAgeRange(int start, int end) async {
    final headers = await getAuthHeaders();

    print('Getting members by age range: $start-$end');

    final response = await apiClient.get(
      '$_basePath/by-age-range',
      queryParameters: {
        'start': start,
        'end': end,
      },
      options: Options(headers: headers),
    );

    print('Get members by age range response status: ${response.statusCode}');

    return response.data['data'] as List<dynamic>;
  }

  Future<List<dynamic>> getMembersByTotalCount() async {
    final headers = await getAuthHeaders();

    print('Getting members by total count');

    final response = await apiClient.get(
      '$_basePath/by-total-count',
      options: Options(headers: headers),
    );

    print('Get members by total count response status: ${response.statusCode}');

    return response.data['data'] as List<dynamic>;
  }

  Future<Member> createMember(Map<String, dynamic> memberData) async {
    final headers = await getAuthHeaders();

    print('Creating member with data: $memberData');

    final response = await apiClient.post(
      _basePath+'/create',
      data: memberData,
      options: Options(headers: headers),
    );

    print('Create member response status: ${response.statusCode}');

    return Member.fromJson(response.data['data']);
  }

  Future<Member> updateMember(
      String id, Map<String, dynamic> memberData) async {
    final headers = await getAuthHeaders();

    print('Updating member $id with data: $memberData');

    final response = await apiClient.put(
      '$_basePath/update/$id',
      data: memberData,
      options: Options(headers: headers),
    );

    print('Update member response status: ${response.statusCode}');

    return Member.fromJson(response.data['data']);
  }

  Future<bool> deleteMember(String id) async {
    final headers = await getAuthHeaders();

    print('Deleting member: $id');

    final response = await apiClient.delete(
      '$_basePath/$id',
      options: Options(headers: headers),
    );

    print('Delete member response status: ${response.statusCode}');

    return response.data['success'] == true;
  }
}
