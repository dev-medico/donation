import 'package:donation/core/api/api_client.dart';
import 'package:donation/src/features/smart_search/domain/smart_search_models.dart';

/// Talks to the `smart-search/*` endpoints. Separate from the existing
/// search-member repository so the Find Blood screen keeps its own contract.
class SmartSearchRepository {
  SmartSearchRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;
  static const String _base = 'smart-search';

  /// Free text in, ranked donors out (server parses with Jev).
  Future<SmartSearchPage> search({
    required String query,
    int page = 0,
    int limit = 50,
    String? availability,
    bool includeCompatible = true,
  }) {
    return _load('$_base/index', {
      'q': query,
      'page': page,
      'limit': limit,
      if (availability != null && availability.isNotEmpty)
        'availability': availability,
      'include_compatible': includeCompatible ? 1 : 0,
    });
  }

  /// Explicit filters (after the user corrected a chip); no parsing involved.
  Future<SmartSearchPage> rank({
    String query = '',
    String? bloodGroup,
    String? township,
    String? ward,
    String? gender,
    bool urgent = false,
    int page = 0,
    int limit = 50,
    String? availability,
    bool includeCompatible = true,
  }) {
    return _load('$_base/rank', {
      'q': query,
      if (bloodGroup != null && bloodGroup.isNotEmpty) 'blood_group': bloodGroup,
      if (township != null && township.isNotEmpty) 'township': township,
      if (ward != null && ward.isNotEmpty) 'ward': ward,
      if (gender != null && gender.isNotEmpty) 'gender': gender,
      'urgent': urgent ? 1 : 0,
      'page': page,
      'limit': limit,
      if (availability != null && availability.isNotEmpty)
        'availability': availability,
      'include_compatible': includeCompatible ? 1 : 0,
    });
  }

  Future<List<TownshipOption>> townships() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '$_base/townships',
    );
    final data = response.data;
    if (data == null || data['status'] != 'ok' || data['data'] is! List) {
      throw Exception('Failed to load townships');
    }
    return (data['data'] as List)
        .whereType<Map>()
        .map((e) => TownshipOption.fromJson(Map<String, dynamic>.from(e)))
        .toList(growable: false);
  }

  Future<SmartSearchPage> _load(String path, Map<String, dynamic> params) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      path,
      queryParameters: params,
    );
    final data = response.data;
    if (data == null) {
      throw Exception('Invalid response data');
    }
    if (data['status'] != 'ok' || data['data'] is! List) {
      throw Exception(data['message']?.toString() ?? 'Smart search failed');
    }
    return SmartSearchPage.fromJson(data);
  }
}
