import 'package:donation/core/api/api_client.dart';
import 'package:donation/src/features/services/base_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final requestGiveLoadingStatusProvider = StateProvider<String>((ref) => '');

/// Incremented after a successful worksheet save so every report/chart that
/// depends on the monthly aggregates can refresh without tightly coupling UI
/// screens to one another.
final requestGiveRevisionProvider = StateProvider<int>((ref) => 0);
final requestGiveServiceProvider =
    Provider<RequestGiveService>((ref) => RequestGiveService(ref));

class RequestGiveConflictException implements Exception {
  const RequestGiveConflictException(this.message);

  final String message;

  @override
  String toString() => message;
}

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
        '$_basePath/index',
        options: {'headers': headers},
        queryParameters: {
          'page': page,
          'limit': limit,
          if (q != null && q.isNotEmpty) 'q': q,
        },
      );

      _updateLoadingStatus('');
      if (response.statusCode == 200) {
        if (response.data != null &&
            response.data!['status'] == 'ok' &&
            response.data!['data'] != null) {
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
        '$_basePath/view',
        options: {'headers': headers},
        queryParameters: {'id': id},
      );

      _updateLoadingStatus('');
      if (response.statusCode == 200) {
        if (response.data != null &&
            response.data!['status'] == 'ok' &&
            response.data!['data'] != null) {
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

  Future<Map<String, dynamic>> createRequestGive(
      Map<String, dynamic> data) async {
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
        if (response.data != null && response.data!['status'] == 'ok') {
          return response.data!['data'] as Map<String, dynamic>;
        }
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
        '$_basePath/update',
        data: data,
        options: {'headers': headers},
        queryParameters: {'id': id},
      );

      _updateLoadingStatus('Request give updated successfully!');
      if (response.statusCode == 200) {
        if (response.data != null && response.data!['status'] == 'ok') {
          return response.data!['data'] as Map<String, dynamic>;
        }
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
        '$_basePath/delete',
        options: {'headers': headers},
        queryParameters: {'id': id},
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

  Future<Map<String, dynamic>> getDetailedReport({
    int? year,
    int? month,
  }) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Fetching detailed report...');

    try {
      final queryParams = <String, dynamic>{};
      if (year != null) queryParams['year'] = year;
      if (month != null) queryParams['month'] = month;

      print('Fetching detailed report with params: $queryParams');

      final response = await apiClient.get(
        '$_basePath/detailed-report',
        options: {'headers': headers},
        queryParameters: queryParams,
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      _updateLoadingStatus('');
      if (response.statusCode == 200) {
        if (response.data != null && response.data!['status'] == 'ok') {
          return response.data!['data'] as Map<String, dynamic>;
        }
        // If status is not ok, check for error message
        if (response.data != null && response.data!['status'] == 'error') {
          throw Exception(
              response.data!['message'] ?? 'Unknown error from server');
        }
        throw Exception('Invalid response format: ${response.data}');
      }
      throw Exception(
          'Failed to fetch detailed report: HTTP ${response.statusCode}');
    } catch (e) {
      print('Error fetching detailed report: $e');
      print('Stack trace: ${StackTrace.current}');
      _updateLoadingStatus('Error: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> getOrCreateMonthly({
    required int year,
    required int month,
  }) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Fetching monthly data...');

    try {
      final response = await apiClient.get(
        '$_basePath/get-or-create-monthly',
        options: {'headers': headers},
        queryParameters: {
          'year': year,
          'month': month,
        },
      );

      _updateLoadingStatus('');
      if (response.statusCode == 200) {
        if (response.data != null && response.data!['status'] == 'ok') {
          return response.data!;
        }
        throw Exception('Invalid response format');
      }
      throw Exception('Failed to fetch monthly data');
    } catch (e) {
      print('Error fetching monthly data: $e');
      _updateLoadingStatus('Error: $e');
      throw e;
    }
  }

  /// Loads the daily worksheet for one calendar month.
  ///
  /// The backend keeps historical, monthly-only records read-only and returns
  /// [legacyOnly] for those months. Newer months return the saved daily rows,
  /// with `null` kept distinct from an explicitly recorded zero.
  Future<Map<String, dynamic>> getMonthEntry({
    required int year,
    required int month,
  }) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Fetching monthly worksheet...');

    try {
      final response = await apiClient.get(
        '$_basePath/month-entry',
        options: {'headers': headers},
        queryParameters: {'year': year, 'month': month},
      );

      if (response.statusCode == 200 &&
          response.data != null &&
          response.data!['status'] == 'ok' &&
          response.data!['data'] is Map) {
        _updateLoadingStatus('');
        return Map<String, dynamic>.from(response.data!['data'] as Map);
      }

      final message = response.data?['message']?.toString();
      throw Exception(message ?? 'Failed to fetch monthly worksheet');
    } catch (e) {
      _updateLoadingStatus('Error: $e');
      rethrow;
    }
  }

  /// Replaces the daily worksheet for one month in a single server
  /// transaction and refreshes that month's aggregate report totals.
  Future<Map<String, dynamic>> saveMonth({
    required int year,
    required int month,
    required List<Map<String, dynamic>> records,
    required int expectedRevision,
  }) async {
    final headers = await getAuthHeaders();
    _updateLoadingStatus('Saving monthly worksheet...');

    try {
      final response = await apiClient.post(
        '$_basePath/save-month',
        options: {'headers': headers},
        data: {
          'year': year,
          'month': month,
          'records': records,
          'expectedRevision': expectedRevision,
        },
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null &&
          response.data!['status'] == 'ok' &&
          response.data!['data'] is Map) {
        _updateLoadingStatus('');
        return Map<String, dynamic>.from(response.data!['data'] as Map);
      }

      final message = response.data?['message']?.toString();
      throw Exception(message ?? 'Failed to save monthly worksheet');
    } on ApiException catch (e) {
      _updateLoadingStatus('Error: $e');
      if (e.statusCode == 409) {
        throw RequestGiveConflictException(e.message);
      }
      rethrow;
    } catch (e) {
      _updateLoadingStatus('Error: $e');
      rethrow;
    }
  }
}
