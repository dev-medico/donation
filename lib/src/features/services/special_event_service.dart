import 'package:donation/src/features/services/base_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final specialEventLoadingStatusProvider = StateProvider<String>((ref) => '');
final specialEventServiceProvider =
    Provider<SpecialEventService>((ref) => SpecialEventService(ref));

class SpecialEventService extends BaseService {
  final ProviderRef? ref;

  SpecialEventService([this.ref]);

  // Base path for all special event endpoints
  final String _basePath = '/special-event';

  void _updateLoadingStatus(String status) {
    if (ref != null) {
      ref!.read(specialEventLoadingStatusProvider.notifier).state = status;
    }
  }

  Future<List<dynamic>> getSpecialEvents({
    int page = 0,
    int limit = 50,
    String? q,
  }) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Fetching special events...');

    try {
      final response = await apiClient.get(
        _basePath,
        options: {'headers': headers},
        queryParameters: {
          'page': page,
          'limit': limit,
          if (q != null && q.isNotEmpty) 'q': q,
        },
      );

      _updateLoadingStatus('');
      if (response.statusCode == 200) {
        if (response.data != null && response.data!['data'] != null) {
          return response.data!['data'] as List<dynamic>;
        }
        return [];
      }
      throw Exception('Failed to fetch special events');
    } catch (e) {
      print('Error fetching special events: $e');
      _updateLoadingStatus('Error: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> getSpecialEventById(String id) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Fetching special event details...');

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
        throw Exception('Invalid response format');
      }
      throw Exception('Special event not found');
    } catch (e) {
      print('Error fetching special event by ID: $e');
      _updateLoadingStatus('Error: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> createSpecialEvent(Map<String, dynamic> data) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Creating special event...');

    try {
      final response = await apiClient.post(
        '$_basePath/create',
        data: data,
        options: {'headers': headers},
      );

      _updateLoadingStatus('Special event created successfully!');
      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data!['data'] as Map<String, dynamic>;
      }
      throw Exception('Failed to create special event');
    } catch (e) {
      print('Error creating special event: $e');
      _updateLoadingStatus('Error: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> updateSpecialEvent(
      String id, Map<String, dynamic> data) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Updating special event...');

    try {
      final response = await apiClient.post(
        '$_basePath/update/$id',
        data: data,
        options: {'headers': headers},
      );

      _updateLoadingStatus('Special event updated successfully!');
      if (response.statusCode == 200) {
        return response.data!['data'] as Map<String, dynamic>;
      }
      throw Exception('Failed to update special event');
    } catch (e) {
      print('Error updating special event: $e');
      _updateLoadingStatus('Error: $e');
      throw e;
    }
  }

  Future<void> deleteSpecialEvent(String id) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Deleting special event...');

    try {
      final response = await apiClient.post(
        '$_basePath/delete/$id',
        options: {'headers': headers},
      );

      _updateLoadingStatus('Special event deleted successfully!');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete special event');
      }
    } catch (e) {
      print('Error deleting special event: $e');
      _updateLoadingStatus('Error: $e');
      throw e;
    }
  }
}