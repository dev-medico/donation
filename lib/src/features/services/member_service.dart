import 'package:donation/src/features/donation_member/domain/member.dart';
import 'package:donation/src/features/services/base_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/core/api/api_client.dart';
import 'dart:math';

final memberLoadingStatusProvider = StateProvider<String>((ref) => '');
final memberServiceProvider =
    Provider<MemberService>((ref) => MemberService(ref));

class MemberService extends BaseService {
  final ProviderRef? ref;

  // Cache for member data
  List<dynamic>? _cachedMembers;
  DateTime? _lastFetchTime;
  final Duration _cacheValidityDuration = const Duration(minutes: 10);

  MemberService([this.ref]);

  // Base path for all member endpoints
  final String _basePath = '/member';

  void _updateLoadingStatus(String status) {
    if (ref != null) {
      ref!.read(memberLoadingStatusProvider.notifier).state = status;
    }
  }

  Future<List<dynamic>> getMembers({int limit = 1000}) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Fetching members...');

    List<dynamic> allMembers = [];
    int currentPage = 0;
    bool hasMoreData = true;

    try {
      while (hasMoreData) {
        _updateLoadingStatus('Fetching members page ${currentPage + 1}...');

        final response = await apiClient.get(
          _basePath + '/index',
          options: {'headers': headers},
          queryParameters: {
            'limit': limit,
            'page': currentPage,
          },
        );

        if (response.statusCode == 200) {
          // Check if response has the expected structure
          if (response.data != null && response.data!['data'] != null) {
            final pageData = response.data!['data'] as List<dynamic>;
            if (pageData.isNotEmpty) {
              allMembers.addAll(pageData);

              // Check if we received fewer items than the limit
              if (pageData.length < limit) {
                hasMoreData = false;
              } else {
                currentPage++;
              }
            } else {
              // Empty page, stop fetching
              hasMoreData = false;
            }
          } else {
            // Unexpected response format
            print('Unexpected response format: ${response.data}');
            hasMoreData = false;
          }
        } else {
          print('Non-200 status code: ${response.statusCode}');
          hasMoreData = false;
        }
      }

      _updateLoadingStatus('');
      return allMembers;
    } catch (e) {
      print('Error fetching members: $e');
      _updateLoadingStatus('Error: $e');
      return allMembers;
    }
  }

  Future<Map<String, dynamic>> getMemberById(String id) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Fetching member details...');

    try {
      final response = await apiClient.get(
        '$_basePath/view/$id',
        options: {'headers': headers},
      );

      _updateLoadingStatus('');
      if (response.statusCode == 200) {
        if (response.data != null && response.data!['data'] != null) {
          return response.data!['data'] as Map<String, dynamic>;
        }
        throw Exception('Invalid response format - missing data field');
      }
      throw Exception('Member not found. Status: ${response.statusCode}');
    } catch (e) {
      print('Error fetching member by ID: $e');
      _updateLoadingStatus('Error: $e');
      throw e;
    }
  }

  Future<List<dynamic>> findMembers(String query) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Searching members...');

    try {
      final response = await apiClient.get(
        '$_basePath/search',
        queryParameters: {'q': query},
        options: {'headers': headers},
      );

      _updateLoadingStatus('');
      if (response.statusCode == 200) {
        return response.data!['data'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      print('Error searching members: $e');
      _updateLoadingStatus('Error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> createMember(Map<String, dynamic> data) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Creating member...');

    try {
      print("Making API request to create member: $data");
      final response = await apiClient.post(
        '$_basePath/create',
        data: data,
        options: {'headers': headers},
      );
      print("Response received: ${response.data}");

      _updateLoadingStatus('Member created successfully!');
      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data!['data'] as Map<String, dynamic>;
      }
      throw Exception('Failed to create member: ${response.data}');
    } catch (e) {
      print('Error creating member: $e');
      _updateLoadingStatus('Error: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> updateMember(
      String id, Map<String, dynamic> data) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Updating member...');

    try {
      final response = await apiClient.post(
        '$_basePath/update',
        queryParameters: {'id': id},
        data: data,
        options: {'headers': headers},
      );

      _updateLoadingStatus('Member updated successfully!');
      if (response.statusCode == 200) {
        return response.data!['data'] as Map<String, dynamic>;
      }
      throw Exception('Failed to update member');
    } catch (e) {
      print('Error updating member: $e');
      _updateLoadingStatus('Error: $e');
      throw e;
    }
  }

  Future<void> deleteMember(String id) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Deleting member...');

    try {
      final response = await apiClient.post(
        '$_basePath/delete',
        queryParameters: {'id': id},
        options: {'headers': headers},
      );

      _updateLoadingStatus('Member deleted successfully!');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete member');
      }
    } catch (e) {
      print('Error deleting member: $e');
      _updateLoadingStatus('Error: $e');
      throw e;
    }
  }

  Future<List<dynamic>> getMembersByAgeRange(int start, int end) async {
    final headers = await getAuthHeaders();
    final response = await apiClient.get(
      '$_basePath/by-age-range',
      queryParameters: {'start': start, 'end': end},
      options: {'headers': headers},
    );
    return response.data!['data'] as List<dynamic>;
  }

  Future<List<dynamic>> getMembersByBlock(String block) async {
    final headers = await getAuthHeaders();
    final response = await apiClient.get(
      '$_basePath/by-block/$block',
      options: {'headers': headers},
    );
    return response.data!['data'] as List<dynamic>;
  }
}
