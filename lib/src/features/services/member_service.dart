import 'package:donation/src/features/donation_member/domain/member.dart';
import 'package:donation/src/features/services/base_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:donation/core/api/api_client.dart';
import 'dart:math';

final memberLoadingStatusProvider = StateProvider<String>((ref) => '');
final memberServiceProvider =
    Provider<MemberService>((ref) => MemberService(ref));

class MemberService extends BaseService {
  final ProviderRef? ref;

  MemberService([this.ref]);

  // Base path for all member endpoints
  final String _basePath = '/members';

  void _updateLoadingStatus(String status) {
    if (ref != null) {
      ref!.read(memberLoadingStatusProvider.notifier).state = status;
    }
  }

  Future<List<dynamic>> getMembers({int limit = 200}) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Fetching members...');

    try {
      final response = await apiClient.get(
        _basePath,
        options: Options(headers: headers),
        queryParameters: {'limit': limit},
      );

      _updateLoadingStatus('');
      if (response.statusCode == 200) {
        return response.data['data'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      print('Error fetching members: $e');
      _updateLoadingStatus('Error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getMemberById(String id) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Fetching member details...');

    try {
      final response = await apiClient.get(
        '$_basePath/$id',
        options: Options(headers: headers),
      );

      _updateLoadingStatus('');
      if (response.statusCode == 200) {
        return response.data['data'] as Map<String, dynamic>;
      }
      throw Exception('Member not found');
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
        options: Options(headers: headers),
      );

      _updateLoadingStatus('');
      if (response.statusCode == 200) {
        return response.data['data'] as List<dynamic>;
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
      final response = await apiClient.post(
        _basePath,
        data: data,
        options: Options(headers: headers),
      );

      _updateLoadingStatus('Member created successfully!');
      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data['data'] as Map<String, dynamic>;
      }
      throw Exception('Failed to create member');
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
      final response = await apiClient.put(
        '$_basePath/$id',
        data: data,
        options: Options(headers: headers),
      );

      _updateLoadingStatus('Member updated successfully!');
      if (response.statusCode == 200) {
        return response.data['data'] as Map<String, dynamic>;
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
      final response = await apiClient.delete(
        '$_basePath/$id',
        options: Options(headers: headers),
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
      options: Options(headers: headers),
    );
    return response.data['data'] as List<dynamic>;
  }

  Future<List<dynamic>> getMembersByBlock(String block) async {
    final headers = await getAuthHeaders();
    final response = await apiClient.get(
      '$_basePath/by-block/$block',
      options: Options(headers: headers),
    );
    return response.data['data'] as List<dynamic>;
  }
}
