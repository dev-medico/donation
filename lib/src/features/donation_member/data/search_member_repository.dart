import 'package:donation/core/api/api_client.dart';
import 'package:donation/src/features/donation_member/domain/member.dart';
import 'package:flutter/foundation.dart';

class SearchMemberRepository {
  final ApiClient _apiClient;
  static const String _baseUrl = 'search-member';

  SearchMemberRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<Member>> searchMembers({
    String? query,
    String? bloodType,
    String? donationYear,
    int page = 0,
    int limit = 5000,
  }) async {
    try {
      debugPrint('Searching members with filters:');
      debugPrint('  - Query: $query');
      debugPrint('  - Blood Type: $bloodType');
      debugPrint('  - Donation Year: $donationYear');
      debugPrint('  - Page: $page, Limit: $limit');

      Map<String, dynamic> queryParams = {
        'q': query ?? '',
        'page': page,
        'limit': limit,
      };

      if (bloodType != null && bloodType.isNotEmpty && 
          bloodType != 'သွေးအုပ်စုဖြင့် ရှာဖွေမည်') {
        queryParams['blood_type'] = bloodType;
      }

      if (donationYear != null && donationYear.isNotEmpty) {
        queryParams['donation_year'] = donationYear;
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
          '$_baseUrl/index',
          queryParameters: queryParams);

      if (response.data == null) {
        throw Exception('Invalid response data');
      }

      final jsonData = response.data!;

      if (jsonData['status'] == 'ok' && jsonData['data'] is List) {
        final List<Member> members = (jsonData['data'] as List)
            .map((item) => Member.fromJson(item as Map<String, dynamic>))
            .toList();

        debugPrint('Search returned ${members.length} members');
        return members;
      } else {
        throw Exception(jsonData['message'] ?? 'Failed to search members');
      }
    } catch (e) {
      debugPrint('Error searching members: $e');
      throw Exception('Failed to search members: $e');
    }
  }
}
