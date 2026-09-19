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
    bool includeNearby = true,
  }) {
    return _load('$_base/index', {
      'q': query,
      'page': page,
      'limit': limit,
      'nearby': includeNearby ? 1 : 0,
      if (availability != null && availability.isNotEmpty)
        'availability': availability,
      'include_compatible': includeCompatible ? 1 : 0,
    });
  }

  /// Explicit filters (after the user corrected a chip); no parsing involved.
  Future<SmartSearchPage> rank({
    String query = '',
    String? bloodGroup,
    List<String> groups = const [],
    String? township,
    String townshipMode = 'prefer',
    String? ward,
    String wardMode = 'prefer',
    String? gender,
    bool urgent = false,
    int page = 0,
    int limit = 50,
    String? availability,
    bool includeCompatible = true,
    int? ageMin,
    int? ageMax,
    String? donorKind,
    String? hospital,
  }) {
    return _load('$_base/rank', {
      if (groups.length > 1) 'groups': groups.join(','),
      if (ageMin != null) 'age_min': ageMin,
      if (ageMax != null) 'age_max': ageMax,
      if (donorKind != null && donorKind.isNotEmpty) 'donor_kind': donorKind,
      if (hospital != null && hospital.isNotEmpty) 'hospital': hospital,
      'q': query,
      if (bloodGroup != null && bloodGroup.isNotEmpty)
        'blood_group': bloodGroup,
      if (township != null && township.isNotEmpty) 'township': township,
      if (township != null && township.isNotEmpty)
        'township_mode': townshipMode,
      if (ward != null && ward.isNotEmpty) 'ward': ward,
      if (ward != null && ward.isNotEmpty) 'ward_mode': wardMode,
      if (gender != null && gender.isNotEmpty) 'gender': gender,
      'urgent': urgent ? 1 : 0,
      'page': page,
      'limit': limit,
      if (availability != null && availability.isNotEmpty)
        'availability': availability,
      'include_compatible': includeCompatible ? 1 : 0,
    });
  }

  /// Quarters by degree and townships by hops around the selection.
  Future<NearbyInfo> nearby({String? ward, String? township}) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '$_base/nearby',
      queryParameters: {
        if (ward != null && ward.isNotEmpty) 'ward': ward,
        if (township != null && township.isNotEmpty) 'township': township,
      },
    );
    final data = response.data;
    if (data == null || data['status'] != 'ok') {
      throw Exception('Failed to load nearby places');
    }
    return NearbyInfo.fromJson(data);
  }

  Future<List<LocalityLink>> links(
      {required String ward, String? township}) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '$_base/links',
      queryParameters: {
        'kind': 'quarter',
        'key': ward,
        if (township != null && township.isNotEmpty) 'township': township,
      },
    );
    final data = response.data;
    if (data == null || data['status'] != 'ok' || data['data'] is! List) {
      throw Exception('Failed to load links');
    }
    return (data['data'] as List)
        .whereType<Map>()
        .map((e) => LocalityLink.fromJson(Map<String, dynamic>.from(e)))
        .toList(growable: false);
  }

  /// action: add | block | unblock | confirm
  Future<void> setLink({
    required String from,
    required String fromTownship,
    required String to,
    required String toTownship,
    required String action,
  }) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '$_base/link',
      data: {
        'kind': 'quarter',
        'from': from,
        'from_township': fromTownship,
        'to': to,
        'to_township': toTownship,
        'action': action,
      },
    );
    final data = response.data;
    if (data == null || data['status'] != 'ok') {
      throw Exception(data?['message']?.toString() ?? 'Failed to save link');
    }
  }

  /// Quarter / village keys with donor counts; optionally one township and a substring.
  Future<List<WardOption>> wards({String? township, String? query}) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '$_base/wards',
      queryParameters: {
        if (township != null && township.isNotEmpty) 'township': township,
        if (query != null && query.isNotEmpty) 'q': query,
        'limit': 400,
      },
    );
    final data = response.data;
    if (data == null || data['status'] != 'ok' || data['data'] is! List) {
      throw Exception('Failed to load wards');
    }
    return (data['data'] as List)
        .whereType<Map>()
        .map((e) => WardOption.fromJson(Map<String, dynamic>.from(e)))
        .toList(growable: false);
  }

  /// Donors per group who can give now, busiest hospitals and townships.
  Future<SmartOverview> overview() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '$_base/overview',
    );
    final data = response.data;
    if (data == null || data['status'] != 'ok') {
      throw Exception('Failed to load overview');
    }
    return SmartOverview.fromJson(data);
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

  Future<SmartSearchPage> _load(
      String path, Map<String, dynamic> params) async {
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
