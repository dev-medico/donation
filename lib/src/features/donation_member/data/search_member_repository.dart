import 'package:donation/core/api/api_client.dart';
import 'package:donation/src/features/donation_member/domain/member.dart';
import 'package:flutter/foundation.dart';

typedef SearchMemberPageLoader = Future<Map<String, dynamic>> Function(
  Map<String, dynamic> queryParameters,
);

class SearchMemberRepository {
  final ApiClient _apiClient;
  final SearchMemberPageLoader? _pageLoader;
  static const String _baseUrl = 'search-member';

  SearchMemberRepository({
    ApiClient? apiClient,
    SearchMemberPageLoader? pageLoader,
  })  : _apiClient = apiClient ?? ApiClient(),
        _pageLoader = pageLoader;

  /// Loads one server page. Global counts are returned separately in
  /// [SearchMemberPage.analysis], so the UI never needs to download thousands
  /// of members just to render the availability summary.
  Future<SearchMemberPage> searchMembers({
    String? query,
    String? bloodType,
    String? availability,
    String? lastDonation,
    int page = 0,
    int limit = 50,
  }) async {
    try {
      debugPrint('Searching members with filters:');
      debugPrint('  - Query: $query');
      debugPrint('  - Blood Type: $bloodType');
      debugPrint('  - Availability: $availability');
      debugPrint('  - Last donation: $lastDonation');
      debugPrint('  - Page: $page, Limit: $limit');

      final queryParams = <String, dynamic>{
        'q': query ?? '',
        'page': page,
        'limit': limit,
      };

      if (bloodType != null &&
          bloodType.isNotEmpty &&
          bloodType != 'သွေးအုပ်စုဖြင့် ရှာဖွေမည်') {
        queryParams['blood_type'] = bloodType;
      }
      if (availability != null && availability.isNotEmpty) {
        queryParams['availability'] = availability;
      }
      // The server resolves this against the effective last donation date,
      // which is the later of the member's stored date and their newest
      // donation row, so paging and the analysis counters stay in agreement.
      if (lastDonation != null && lastDonation.isNotEmpty) {
        queryParams['last_donation'] = lastDonation;
      }

      final pageLoader = _pageLoader;
      final jsonData = pageLoader != null
          ? await pageLoader(queryParams)
          : (await _apiClient.get<Map<String, dynamic>>(
              '$_baseUrl/index',
              queryParameters: queryParams,
            ))
              .data;
      if (jsonData == null) {
        throw Exception('Invalid response data');
      }
      if (jsonData['status'] != 'ok' || jsonData['data'] is! List) {
        throw Exception(jsonData['message'] ?? 'Failed to search members');
      }

      final members = (jsonData['data'] as List)
          .map((item) => Member.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
      final total = _parseInt(jsonData['total']);
      final analysisJson = jsonData['analysis'];
      final analysis = analysisJson is Map
          ? SearchMemberAnalysis.fromJson(
              Map<String, dynamic>.from(analysisJson),
            )
          : null;

      debugPrint(
        'Search page ${page + 1} returned ${members.length} of ${total ?? '?'}',
      );
      return SearchMemberPage(
        members: members,
        total: total,
        analysis: analysis,
        page: _parseInt(jsonData['page']) ?? page,
        limit: _parseInt(jsonData['limit']) ?? limit,
      );
    } catch (e) {
      debugPrint('Error searching members: $e');
      throw Exception('Failed to search members: $e');
    }
  }
}

int? _parseInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}

class SearchMemberPage {
  const SearchMemberPage({
    required this.members,
    required this.total,
    required this.analysis,
    required this.page,
    required this.limit,
  });

  final List<Member> members;
  final int? total;
  final SearchMemberAnalysis? analysis;
  final int page;
  final int limit;

  bool get hasMore {
    final knownTotal = total;
    if (knownTotal != null) {
      return (page + 1) * limit < knownTotal;
    }
    return members.length >= limit;
  }
}

class SearchMemberAnalysis {
  const SearchMemberAnalysis({
    required this.total,
    required this.green,
    required this.yellow,
    required this.red,
    this.calculatedOn,
  });

  factory SearchMemberAnalysis.fromJson(Map<String, dynamic> json) {
    return SearchMemberAnalysis(
      total: _parseInt(json['total']) ?? 0,
      green: _parseInt(json['green']) ?? 0,
      yellow: _parseInt(json['yellow']) ?? 0,
      red: _parseInt(json['red']) ?? 0,
      calculatedOn: DateTime.tryParse(json['calculated_on']?.toString() ?? ''),
    );
  }

  final int total;
  final int green;
  final int yellow;
  final int red;
  final DateTime? calculatedOn;
}
