import 'package:donation/core/api/api_client.dart';
import 'package:donation/src/features/donation_member/domain/member.dart';

// Add caching capabilities
class MemberRepository {
  final ApiClient _apiClient;
  // Add cache storage
  List<Member>? _cachedMembers;
  DateTime? _lastFetchTime;
  // Define cache validity duration (10 minutes)
  final Duration _cacheValidityDuration = const Duration(minutes: 10);

  MemberRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<Member>> getMembers() async {
    // Check if we have valid cache
    if (_cachedMembers != null && _lastFetchTime != null) {
      final cacheAge = DateTime.now().difference(_lastFetchTime!);
      if (cacheAge < _cacheValidityDuration) {
        // Cache is still valid
        print('Using cached member data (${_cachedMembers!.length} members)');
        return _cachedMembers!;
      }
    }

    try {
      // Fetch fresh data from API
      print('Fetching member data from API...');
      final response =
          await _apiClient.get<Map<String, dynamic>>('member/index');

      if (response.data != null && response.data!['status'] == 'ok') {
        final List<dynamic> data = response.data!['data'];
        final members = data.map((item) => Member.fromJson(item)).toList();

        // Update cache
        _cachedMembers = members;
        _lastFetchTime = DateTime.now();

        return members;
      } else {
        throw Exception('Failed to load members');
      }
    } catch (e) {
      // If any error occurs and we have cached data, return that instead
      if (_cachedMembers != null) {
        print('Error fetching data, using cached data: $e');
        return _cachedMembers!;
      }
      rethrow;
    }
  }

  // Add method to invalidate cache
  void invalidateCache() {
    _cachedMembers = null;
    _lastFetchTime = null;
    print('Member cache invalidated');
  }

  // Update member method that also updates cache
  Future<bool> updateMember(Member member) async {
    try {
      final response = await _apiClient.put<Map<String, dynamic>>(
        'member/update',
        queryParameters: {'id': member.id},
        data: member.toJson(),
      );

      if (response.data != null && response.data!['status'] == 'ok') {
        // Update the member in the cache if it exists
        if (_cachedMembers != null) {
          final index = _cachedMembers!.indexWhere((m) => m.id == member.id);
          if (index >= 0) {
            _cachedMembers![index] = member;
            print('Updated member in cache: ${member.id}');
          }
        }
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Add a method to add a new member that also updates cache
  Future<bool> addMember(Member member) async {
    try {
      final response = await _apiClient.post(
        'member/create',
        data: member.toJson(),
      );

      if (response.data != null && response.data!['status'] == 'ok') {
        // Add the new member to the cache if it exists
        if (_cachedMembers != null) {
          _cachedMembers!.add(member);
          print('Added new member to cache: ${member.id}');
        }
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Get a single member with caching
  Future<Member?> getMember(String id) async {
    // Check if we have this member in cache
    if (_cachedMembers != null) {
      final cachedMember = _cachedMembers!.firstWhere(
        (m) => m.id.toString() == id,
        orElse: () => Member(),
      );

      if (cachedMember.id != null) {
        print('Using cached member: $id');
        return cachedMember;
      }
    }

    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        'member/view',
        queryParameters: {'id': id},
      );

      if (response.data != null && response.data!['status'] == 'ok') {
        final memberData = response.data!['data']['member'];
        final member = Member.fromJson(memberData);

        // Update the member in the cache if it exists
        if (_cachedMembers != null) {
          final index =
              _cachedMembers!.indexWhere((m) => m.id.toString() == id);
          if (index >= 0) {
            _cachedMembers![index] = member;
          } else {
            _cachedMembers!.add(member);
          }
        }

        return member;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Check if a member exists with the given criteria
  Future<Map<String, dynamic>> checkMemberExists(String name,
      {String? fatherName, String? bloodType}) async {
    try {
      // Build query parameters
      final queryParams = <String, dynamic>{
        'name': name,
      };

      // Add optional parameters if provided
      if (fatherName != null && fatherName.isNotEmpty) {
        queryParams['father_name'] = fatherName;
      }

      if (bloodType != null && bloodType != "သွေးအုပ်စု") {
        queryParams['blood_type'] = bloodType;
      }

      // Make API call
      final response = await _apiClient.get<Map<String, dynamic>>(
        'member/check-exists',
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
      print('Error checking member existence: $e');
      return {
        'exists': false,
        'members': <Member>[],
        'error': e.toString(),
      };
    }
  }
}
