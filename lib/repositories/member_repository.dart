import 'package:donation/core/api/api_client.dart';
import 'package:donation/core/api/api_response.dart';
import 'package:donation/models/member.dart';

class MemberRepository {
  final ApiClient _apiClient;
  static const String _baseUrl = 'member';

  MemberRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<ApiResponse<List<Member>>> getAllMembers() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>('$_baseUrl/index', 
        queryParameters: {
          'q': '',
          'page': 0,
          'limit': 5000
        });
      
      if (response.data == null) {
        return ApiResponse.error('Invalid response data');
      }
      
      final jsonData = response.data!;
      
      if (jsonData['success'] == true && jsonData['data'] is List) {
        return ApiResponse<List<Member>>(
          success: true,
          message: jsonData['message'] ?? 'Members retrieved successfully',
          data: (jsonData['data'] as List)
              .map((item) => Member.fromJson(item as Map<String, dynamic>))
              .toList(),
          meta: jsonData['meta'] as Map<String, dynamic>?,
        );
      } else {
        return ApiResponse.error(jsonData['message'] ?? 'Failed to retrieve members');
      }
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Member>> getMemberById(String id) async {
    try {
      final response =
          await _apiClient.get<Map<String, dynamic>>('$_baseUrl/view', 
              queryParameters: {'id': id});
      return ApiResponse.fromJson(
        response.data!,
        (json) => Member.fromJson(json),
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Member>> createMember(Member member) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '$_baseUrl/create',
        data: member.toJson(),
      );
      return ApiResponse.fromJson(
        response.data!,
        (json) => Member.fromJson(json),
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Member>> updateMember(String id, Member member) async {
    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        '$_baseUrl/update',
        queryParameters: {'id': id},
        data: member.toJson(),
      );
      return ApiResponse.fromJson(
        response.data!,
        (json) => Member.fromJson(json),
      );
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<void>> deleteMember(String id) async {
    try {
      await _apiClient.delete('$_baseUrl/delete', queryParameters: {'id': id});
      return ApiResponse(success: true, message: 'Member deleted successfully');
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<List<Member>>> searchMembers({
    String? name,
    String? bloodType,
    String? phone,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'q': name ?? '',
        'page': 0,
        'limit': 5000,
        if (bloodType != null) 'blood_type': bloodType,
        if (phone != null) 'phone': phone,
      };

      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_baseUrl/index',
        queryParameters: queryParameters,
      );

      if (response.data == null) {
        return ApiResponse.error('Invalid response data');
      }
      
      final jsonData = response.data!;
      
      if (jsonData['success'] == true && jsonData['data'] is List) {
        return ApiResponse<List<Member>>(
          success: true,
          message: jsonData['message'] ?? 'Members retrieved successfully',
          data: (jsonData['data'] as List)
              .map((item) => Member.fromJson(item as Map<String, dynamic>))
              .toList(),
          meta: jsonData['meta'] as Map<String, dynamic>?,
        );
      } else {
        return ApiResponse.error(jsonData['message'] ?? 'Failed to retrieve members');
      }
    } catch (e) {
      return ApiResponse.error(e.toString());
    }
  }
}
