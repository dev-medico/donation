import 'package:donation/src/features/services/base_service.dart';
import 'package:donation/src/features/money_donor/models/money_donor.dart';

class MoneyDonorService extends BaseService {
  /// Get paginated list of money donors
  Future<Map<String, dynamic>> getMoneyDonors({
    int page = 0,
    int limit = 20,
    String q = '',
  }) async {
    final queryParams = <String, dynamic>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (q.isNotEmpty) {
      queryParams['q'] = q;
    }

    final response = await apiClient.get(
      '/money-donor/index',
      queryParameters: queryParams,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = response.data;
      if (data['status'] == 'ok') {
        final List<dynamic> donorsJson = data['data'] ?? [];
        final List<MoneyDonor> donors = donorsJson
            .map((json) => MoneyDonor.fromJson(json))
            .toList();

        return {
          'donors': donors,
          'total': data['total'] ?? 0,
          'hasMore': data['hasMore'] ?? false,
          'page': data['page'] ?? page,
          'limit': data['limit'] ?? limit,
        };
      }
    }

    throw Exception('Failed to load money donors');
  }

  /// Get single money donor by ID
  Future<MoneyDonor> getMoneyDonor(int id) async {
    final response = await apiClient.get(
      '/money-donor/view',
      queryParameters: {'id': id.toString()},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = response.data;
      if (data['status'] == 'ok') {
        return MoneyDonor.fromJson(data['data']);
      }
    }

    throw Exception('Failed to load money donor');
  }

  /// Create new money donor
  Future<MoneyDonor> createMoneyDonor(Map<String, dynamic> donorData) async {
    final response = await apiClient.post(
      '/money-donor/create',
      data: donorData,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = response.data;
      if (data['status'] == 'ok') {
        return MoneyDonor.fromJson(data['data']);
      }
    }

    throw Exception('Failed to create money donor');
  }

  /// Update existing money donor
  Future<MoneyDonor> updateMoneyDonor(int id, Map<String, dynamic> donorData) async {
    final response = await apiClient.post(
      '/money-donor/update/$id',
      data: donorData,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = response.data;
      if (data['status'] == 'ok') {
        return MoneyDonor.fromJson(data['data']);
      }
    }

    throw Exception('Failed to update money donor');
  }

  /// Delete money donor
  Future<bool> deleteMoneyDonor(int id) async {
    final response = await apiClient.post('/money-donor/delete/$id');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = response.data;
      return data['status'] == 'ok';
    }

    return false;
  }

  /// Search money donors for dropdown
  Future<List<MoneyDonor>> searchMoneyDonors(String query) async {
    final response = await apiClient.get(
      '/money-donor/search',
      queryParameters: {'q': query},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = response.data;
      if (data['status'] == 'ok') {
        final List<dynamic> donorsJson = data['data'] ?? [];
        return donorsJson
            .map((json) => MoneyDonor.fromJson(json))
            .toList();
      }
    }

    return [];
  }

  /// Get donation report for a specific donor
  Future<Map<String, dynamic>> getReport(int id) async {
    final response = await apiClient.get(
      '/money-donor/report',
      queryParameters: {'id': id.toString()},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = response.data;
      if (data['status'] == 'ok') {
        return data['data'];
      }
    }

    throw Exception('Failed to load report');
  }
}
