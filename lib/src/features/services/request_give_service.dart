import 'package:donation/src/features/services/base_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final requestGiveLoadingStatusProvider = StateProvider<String>((ref) => '');
final requestGiveServiceProvider =
    Provider<RequestGiveService>((ref) => RequestGiveService(ref));

class RequestGiveService extends BaseService {
  final ProviderRef? ref;

  RequestGiveService([this.ref]);

  // Base path for all request give endpoints
  final String _basePath = '/request-give';

  void _updateLoadingStatus(String status) {
    if (ref != null) {
      ref!.read(requestGiveLoadingStatusProvider.notifier).state = status;
    }
  }

  Future<List<dynamic>> getRequestGives({
    int page = 0,
    int limit = 50,
    String? q,
  }) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Fetching request gives...');

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
      throw Exception('Failed to fetch request gives');
    } catch (e) {
      print('Error fetching request gives: $e');
      _updateLoadingStatus('Error: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> getRequestGiveById(String id) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Fetching request give details...');

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
      throw Exception('Request give not found');
    } catch (e) {
      print('Error fetching request give by ID: $e');
      _updateLoadingStatus('Error: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> createRequestGive(Map<String, dynamic> data) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Creating request give...');

    try {
      final response = await apiClient.post(
        '$_basePath/create',
        data: data,
        options: {'headers': headers},
      );

      _updateLoadingStatus('Request give created successfully!');
      if (response.statusCode == 201 || response.statusCode == 200) {
        return response.data!['data'] as Map<String, dynamic>;
      }
      throw Exception('Failed to create request give');
    } catch (e) {
      print('Error creating request give: $e');
      _updateLoadingStatus('Error: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> updateRequestGive(
      String id, Map<String, dynamic> data) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Updating request give...');

    try {
      final response = await apiClient.post(
        '$_basePath/update/$id',
        data: data,
        options: {'headers': headers},
      );

      _updateLoadingStatus('Request give updated successfully!');
      if (response.statusCode == 200) {
        return response.data!['data'] as Map<String, dynamic>;
      }
      throw Exception('Failed to update request give');
    } catch (e) {
      print('Error updating request give: $e');
      _updateLoadingStatus('Error: $e');
      throw e;
    }
  }

  Future<void> deleteRequestGive(String id) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Deleting request give...');

    try {
      final response = await apiClient.post(
        '$_basePath/delete/$id',
        options: {'headers': headers},
      );

      _updateLoadingStatus('Request give deleted successfully!');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete request give');
      }
    } catch (e) {
      print('Error deleting request give: $e');
      _updateLoadingStatus('Error: $e');
      throw e;
    }
  }
}