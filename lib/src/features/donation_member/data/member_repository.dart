import 'dart:developer';

import 'package:donation/core/api/api_client.dart';
import 'package:donation/src/features/donation_member/domain/member.dart';
import 'package:donation/src/features/donation_member/domain/member_range.dart';
import 'package:donation/src/features/donation_member/domain/donation.dart';
import 'package:flutter/foundation.dart';

class MemberRepository {
  final ApiClient _apiClient;
  static const String _baseUrl = 'member';

  // Cache for member data
  static Map<String, MemberWithDonations> _memberCache = {};
  static List<Member>? _memberListCache;
  static DateTime? _memberListCacheTime;

  // Cache expiration time in minutes
  static const int _cacheExpirationMinutes = 5;

  MemberRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  // Clear cache method for when needed (like after updates)
  void clearCache() {
    _memberCache.clear();
    _memberListCache = null;
    _memberListCacheTime = null;
    debugPrint('Member cache cleared');
  }

  // Method to clear a specific member's cache
  void clearMemberCache(String id) {
    _memberCache.remove(id);
    debugPrint('Cache cleared for member $id');
  }

  Future<MemberWithDonations> getMemberById(String id) async {
    // Check if we have this member in cache
    if (_memberCache.containsKey(id)) {
      debugPrint('Using cached data for member $id');
      return _memberCache[id]!;
    }

    try {
      debugPrint('Fetching member with ID: $id');
      final response = await _apiClient.get<Map<String, dynamic>>(
          '$_baseUrl/view',
          queryParameters: {'id': id});

      if (response.data == null) {
        debugPrint('Response data is null');
        throw Exception('Invalid response data');
      }

      final responseData = response.data!;
      log('Response received: ${responseData.toString()}...');

      // Check status from backend
      if (responseData['status'] == 'error') {
        debugPrint('Error status: ${responseData['message']}');
        throw Exception(responseData['message'] ?? 'Failed to load member');
      }

      if (responseData['status'] != 'ok' || responseData['data'] == null) {
        debugPrint(
            'Invalid response format: ${responseData.toString().substring(0, min(100, responseData.toString().length))}...');
        throw Exception('Invalid response format');
      }

      // Extract member data from the nested structure
      final memberData = responseData['data']['member'];
      if (memberData == null) {
        debugPrint('Member data not found in response');
        throw Exception('Member data not found in response');
      }

      // Parse donations data
      List<Donation> donations = [];
      if (responseData['data']['donations'] != null) {
        final donationsData = responseData['data']['donations'] as List;
        donations =
            donationsData.map((item) => Donation.fromJson(item)).toList();
        debugPrint('Found ${donations.length} donations');
      }

      // Create and cache the result
      final result = MemberWithDonations(
        member: Member.fromJson(memberData),
        donations: donations,
      );

      // Store in cache
      _memberCache[id] = result;

      return result;
    } catch (e) {
      debugPrint('Error in getMemberById: $e');
      throw Exception('Failed to load member: $e');
    }
  }

  // Method to get all members with caching
  Future<List<Member>> getAllMembers({bool forceRefresh = false}) async {
    // Check if cache is still valid (not expired and not forced to refresh)
    final bool isCacheValid = _memberListCache != null &&
        _memberListCacheTime != null &&
        DateTime.now().difference(_memberListCacheTime!).inMinutes <
            _cacheExpirationMinutes &&
        !forceRefresh;

    if (isCacheValid) {
      debugPrint(
          'Using cached member list (${_memberListCache!.length} members)');
      return _memberListCache!;
    }

    try {
      debugPrint('Fetching all members');
      final response = await _apiClient.get<Map<String, dynamic>>(
          '$_baseUrl/index',
          queryParameters: {'q': '', 'page': 0, 'limit': 5000});

      if (response.data == null) {
        throw Exception('Invalid response data');
      }

      final jsonData = response.data!;

      if (jsonData['status'] == 'ok' && jsonData['data'] is List) {
        final List<Member> members = (jsonData['data'] as List)
            .map((item) => Member.fromJson(item as Map<String, dynamic>))
            .toList();

        // Update the cache
        _memberListCache = members;
        _memberListCacheTime = DateTime.now();

        debugPrint('Fetched ${members.length} members');
        return members;
      } else {
        throw Exception(jsonData['message'] ?? 'Failed to retrieve members');
      }
    } catch (e) {
      debugPrint('Error fetching all members: $e');
      throw Exception('Failed to load members: $e');
    }
  }

  Future<Member> updateMember(String id, Member member) async {
    try {
      debugPrint('Updating member with ID: $id');

      final response = await _apiClient.post<Map<String, dynamic>>(
        '$_baseUrl/update',
        queryParameters: {'id': id},
        data: member.toJson(),
      );

      if (response.data == null) {
        debugPrint('Response data is null');
        throw Exception('Invalid response data');
      }

      final responseData = response.data!;
      debugPrint(
          'Update response: ${responseData.toString().substring(0, min(100, responseData.toString().length))}...');

      // Check status from backend
      if (responseData['status'] == 'error') {
        debugPrint('Error status: ${responseData['message']}');
        throw Exception(responseData['message'] ?? 'Failed to update member');
      }

      if (responseData['status'] != 'ok' || responseData['data'] == null) {
        debugPrint('Invalid response format');
        throw Exception('Invalid response format');
      }

      // Get the updated member data
      final updatedMember = Member.fromJson(responseData['data']);

      // Clear caches after update
      clearMemberCache(id);
      _memberListCache =
          null; // Also clear the list cache since it's now outdated

      return updatedMember;
    } catch (e) {
      debugPrint('Error in updateMember: $e');
      throw Exception('Failed to update member: $e');
    }
  }

  /// Fetches range options from the API
  /// Returns a list of MemberRange objects for the dropdown
  Future<List<MemberRange>> getMemberRanges({String? bloodType}) async {
    try {
      debugPrint('Fetching member ranges${bloodType != null ? " for blood type: $bloodType" : ""}');

      final queryParams = <String, dynamic>{};
      if (bloodType != null && bloodType.isNotEmpty) {
        queryParams['blood_type'] = bloodType;
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_baseUrl/ranges',
        queryParameters: queryParams,
      );

      if (response.data == null) {
        throw Exception('Invalid response data');
      }

      final jsonData = response.data!;

      if (jsonData['status'] == 'ok' && jsonData['data'] != null) {
        final data = jsonData['data'] as Map<String, dynamic>;
        final rangesData = data['ranges'] as List;
        final ranges = rangesData
            .map((item) => MemberRange.fromJson(item as Map<String, dynamic>))
            .toList();

        debugPrint('Fetched ${ranges.length} ranges, total members: ${data['totalMembers']}');
        return ranges;
      } else {
        throw Exception(jsonData['message'] ?? 'Failed to retrieve ranges');
      }
    } catch (e) {
      debugPrint('Error fetching member ranges: $e');
      throw Exception('Failed to load member ranges: $e');
    }
  }

  /// Check if a member exists with the given criteria
  Future<Map<String, dynamic>> checkMemberExists(String name,
      {String? fatherName, String? bloodType}) async {
    try {
      final queryParams = <String, dynamic>{
        'name': name,
      };

      if (fatherName != null && fatherName.isNotEmpty) {
        queryParams['father_name'] = fatherName;
      }

      if (bloodType != null && bloodType != "သွေးအုပ်စု") {
        queryParams['blood_type'] = bloodType;
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_baseUrl/check-exists',
        queryParameters: queryParams,
      );

      if (response.data != null && response.data!['status'] == 'ok') {
        final exists = response.data!['exists'] as bool;
        final List<dynamic> membersData = response.data!['members'] ?? [];
        final members =
            membersData.map((item) => Member.fromJson(item)).toList();

        return {
          'exists': exists,
          'members': members,
        };
      } else {
        return {
          'exists': false,
          'members': <Member>[],
          'error': 'Failed to check member existence',
        };
      }
    } catch (e) {
      debugPrint('Error checking member existence: $e');
      return {
        'exists': false,
        'members': <Member>[],
        'error': e.toString(),
      };
    }
  }

  /// Fetches initial members with a limit (for when no range is selected)
  /// Supports search query and blood type filtering
  Future<List<Member>> getInitialMembers({
    int limit = 50,
    String? query,
    String? bloodType,
  }) async {
    try {
      debugPrint('Fetching initial $limit members');

      final queryParams = <String, dynamic>{
        'page': 0,
        'limit': limit,
      };

      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }
      if (bloodType != null && bloodType.isNotEmpty) {
        queryParams['blood_type'] = bloodType;
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_baseUrl/index',
        queryParameters: queryParams,
      );

      if (response.data == null) {
        throw Exception('Invalid response data');
      }

      final jsonData = response.data!;

      if (jsonData['status'] == 'ok' && jsonData['data'] is List) {
        final members = (jsonData['data'] as List)
            .map((item) => Member.fromJson(item as Map<String, dynamic>))
            .toList();

        debugPrint('Fetched ${members.length} initial members');
        return members;
      } else {
        throw Exception(jsonData['message'] ?? 'Failed to retrieve members');
      }
    } catch (e) {
      debugPrint('Error fetching initial members: $e');
      throw Exception('Failed to load members: $e');
    }
  }

  /// Fetches members with pagination support
  /// Returns a map with 'members' list and 'hasMore' flag
  Future<Map<String, dynamic>> getMembersPaginated({
    int page = 0,
    int limit = 50,
    String? query,
    String? bloodType,
  }) async {
    try {
      debugPrint('Fetching members page $page (limit: $limit)');

      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }
      if (bloodType != null && bloodType.isNotEmpty) {
        queryParams['blood_type'] = bloodType;
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_baseUrl/index',
        queryParameters: queryParams,
      );

      if (response.data == null) {
        throw Exception('Invalid response data');
      }

      final jsonData = response.data!;

      if (jsonData['status'] == 'ok' && jsonData['data'] is List) {
        final members = (jsonData['data'] as List)
            .map((item) => Member.fromJson(item as Map<String, dynamic>))
            .toList();

        // Calculate hasMore based on total or response length
        final total = jsonData['total'] as int?;
        final hasMore = total != null
            ? (page + 1) * limit < total
            : members.length >= limit;

        debugPrint('Fetched ${members.length} members (page $page), hasMore: $hasMore');
        return {
          'members': members,
          'hasMore': hasMore,
          'total': total ?? 0,
        };
      } else {
        throw Exception(jsonData['message'] ?? 'Failed to retrieve members');
      }
    } catch (e) {
      debugPrint('Error fetching members page $page: $e');
      throw Exception('Failed to load members: $e');
    }
  }

  /// Fetches members for a specific range
  /// Used for lazy loading when a range is selected
  Future<List<Member>> getMembersByRange({
    required String rangeStart,
    required String rangeEnd,
    String? query,
    String? bloodType,
  }) async {
    try {
      debugPrint('Fetching members for range: $rangeStart to $rangeEnd');

      final queryParams = <String, dynamic>{
        'page': 0,
        'limit': 100, // Should be enough for 50 members per range
        'range_start': rangeStart,
        'range_end': rangeEnd,
      };

      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }
      if (bloodType != null && bloodType.isNotEmpty) {
        queryParams['blood_type'] = bloodType;
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_baseUrl/index',
        queryParameters: queryParams,
      );

      if (response.data == null) {
        throw Exception('Invalid response data');
      }

      final jsonData = response.data!;

      if (jsonData['status'] == 'ok' && jsonData['data'] is List) {
        final members = (jsonData['data'] as List)
            .map((item) => Member.fromJson(item as Map<String, dynamic>))
            .toList();

        debugPrint('Fetched ${members.length} members for range');
        return members;
      } else {
        throw Exception(jsonData['message'] ?? 'Failed to retrieve members');
      }
    } catch (e) {
      debugPrint('Error fetching members by range: $e');
      throw Exception('Failed to load members: $e');
    }
  }
}

class MemberWithDonations {
  final Member member;
  final List<Donation> donations;

  MemberWithDonations({
    required this.member,
    required this.donations,
  });
}

// Utility function to avoid errors with large strings
int min(int a, int b) {
  return a < b ? a : b;
}
