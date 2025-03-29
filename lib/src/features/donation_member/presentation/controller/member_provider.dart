import 'dart:developer';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/src/features/services/member_service.dart';
import 'package:donation/src/features/donation_member/domain/member.dart';

typedef SearchParams = ({String? search, String? bloodType});
typedef AgeRangeParams = ({int? start, int? end});

final memberServiceProvider = Provider<MemberService>((ref) => MemberService());

final memberStreamProvider = StreamProvider.family<List<Member>, SearchParams>(
    (ref, searchParam) async* {
  final memberService = ref.read(memberServiceProvider);
  while (true) {
    final membersJson = await memberService.getMembers(
      search: searchParam.search,
      bloodType: searchParam.bloodType,
    );
    final members = membersJson
        .map((json) => Member.fromJson(json as Map<String, dynamic>))
        .toList();
    yield members;
    await Future.delayed(
        const Duration(seconds: 30)); // Refresh every 30 seconds
  }
});

final membersDataProvider = FutureProvider<List<Member>>((ref) async {
  final memberService = ref.read(memberServiceProvider);
  final membersJson = await memberService.getMembers();
  return membersJson
      .map((json) => Member.fromJson(json as Map<String, dynamic>))
      .toList();
});

final averageAgeOfMemberProvider = FutureProvider<int>((ref) async {
  final memberService = ref.read(memberServiceProvider);
  final stats = await memberService.getMemberStats();
  return stats['average_age'] as int;
});

final memberCountByAgeRangeProvider =
    FutureProvider.family<int, AgeRangeParams>((ref, ageRange) async {
  final memberService = ref.read(memberServiceProvider);
  final members =
      await memberService.getMembersByAgeRange(ageRange.start!, ageRange.end!);
  return members.length;
});

final membersDataByTotalCountProvider =
    FutureProvider<List<Member>>((ref) async {
  final memberService = ref.read(memberServiceProvider);
  final membersJson = await memberService.getMembersByTotalCount();
  return membersJson
      .map((json) => Member.fromJson(json as Map<String, dynamic>))
      .toList();
});

final membersDataByPhoneProvider =
    FutureProvider.family<Member?, String>((ref, phone) async {
  final memberService = ref.read(memberServiceProvider);
  try {
    final memberJson = await memberService.getMemberByPhone(phone);
    return Member.fromJson(memberJson);
  } catch (e) {
    return null;
  }
});

final loginMemberProvider = StateProvider<Member?>((ref) => null);

final searchMemberProvider =
    FutureProvider.family<List<Member>, ({String? search, String? bloodType})>(
  (ref, params) async {
    final memberService = ref.watch(memberServiceProvider);
    return memberService.searchMembers(
      query: params.search,
      bloodType: params.bloodType,
    );
  },
);

// Fetch and cache the full member list
final memberListProvider = FutureProvider<List<Member>>((ref) async {
  final memberService = ref.read(memberServiceProvider);
  try {
    return await memberService.searchMembers(limit: 5000);
  } catch (e) {
    print('Error fetching members: $e');
    return [];
  }
});

// Filter states
final memberSearchQueryProvider = StateProvider<String>((ref) => '');
final memberBloodTypeFilterProvider =
    StateProvider<String>((ref) => 'သွေးအုပ်စု အလိုက်ကြည့်မည်');
final memberRangeFilterProvider = StateProvider<String?>((ref) => null);

// Filtered members provider
final filteredMemberListProvider = StateProvider<List<Member>>((ref) {
  final allMembersAsync = ref.watch(memberListProvider);

  return allMembersAsync.when(
    data: (allMembers) {
      final searchQuery = ref.watch(memberSearchQueryProvider);
      final bloodType = ref.watch(memberBloodTypeFilterProvider);
      final range = ref.watch(memberRangeFilterProvider);

      List<Member> filtered = List.from(allMembers);

      // Filter by blood type
      if (bloodType != 'သွေးအုပ်စု အလိုက်ကြည့်မည်' &&
          bloodType != 'သွေးအုပ်စုဖြင့် ရှာဖွေမည်') {
        filtered = filtered
            .where((member) =>
                member.bloodType != null && member.bloodType == bloodType)
            .toList();
      }

      // Filter by search text
      if (searchQuery.isNotEmpty) {
        filtered = filtered
            .where((member) =>
                (member.name
                        ?.toLowerCase()
                        .contains(searchQuery.toLowerCase()) ??
                    false) ||
                (member.memberId
                        ?.toLowerCase()
                        .contains(searchQuery.toLowerCase()) ??
                    false) ||
                (member.phone
                        ?.toLowerCase()
                        .contains(searchQuery.toLowerCase()) ??
                    false))
            .toList();
      }

      // Filter by range
      if (range != null && range.isNotEmpty) {
        final rangeParts = range.split(' မှ ');
        if (rangeParts.length == 2) {
          final startId = rangeParts[0];
          final endId = rangeParts[1];

          final startIndex =
              filtered.indexWhere((member) => member.memberId == startId);
          final endIndex =
              filtered.indexWhere((member) => member.memberId == endId);

          if (startIndex != -1 && endIndex != -1 && startIndex <= endIndex) {
            filtered = filtered.sublist(startIndex, endIndex + 1);
          }
        }
      }

      return filtered;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Using a function instead that can be called when needed
void updateFilteredMembers(WidgetRef ref) {
  final allMembers = ref.read(memberListProvider).value ?? [];
  final searchQuery = ref.read(memberSearchQueryProvider);
  final bloodType = ref.read(memberBloodTypeFilterProvider);
  final range = ref.read(memberRangeFilterProvider);

  List<Member> filtered = List.from(allMembers);

  if (bloodType != 'သွေးအုပ်စု အလိုက်ကြည့်မည်' &&
      bloodType != 'သွေးအုပ်စုဖြင့် ရှာဖွေမည်') {
    filtered = filtered
        .where((member) =>
            member.bloodType != null && member.bloodType == bloodType)
        .toList();
  }

  if (searchQuery.isNotEmpty) {
    filtered = filtered
        .where((member) =>
            (member.name?.toLowerCase().contains(searchQuery.toLowerCase()) ??
                false) ||
            (member.memberId
                    ?.toLowerCase()
                    .contains(searchQuery.toLowerCase()) ??
                false) ||
            (member.phone?.toLowerCase().contains(searchQuery.toLowerCase()) ??
                false))
        .toList();
  }

  if (range != null && range.isNotEmpty) {
    final rangeParts = range.split(' မှ ');
    if (rangeParts.length == 2) {
      final startId = rangeParts[0];
      final endId = rangeParts[1];

      final startIndex =
          filtered.indexWhere((member) => member.memberId == startId);
      final endIndex =
          filtered.indexWhere((member) => member.memberId == endId);

      if (startIndex != -1 && endIndex != -1 && startIndex <= endIndex) {
        filtered = filtered.sublist(startIndex, endIndex + 1);
      }
    }
  }

  ref.read(filteredMemberListProvider.notifier).state = filtered;
}

// Selected member provider
final selectedMemberProvider = StateProvider<Member?>((ref) => null);

// Member operation states
final memberLoadingProvider = StateProvider<bool>((ref) => false);
final memberErrorProvider = StateProvider<String?>((ref) => null);

// Get member by ID provider
final memberByIdProvider =
    FutureProvider.family<Member, String>((ref, id) async {
  final memberService = ref.read(memberServiceProvider);

  try {
    return await memberService.getMemberById(id);
  } catch (e) {
    throw e;
  }
});

// Helper function to fetch member by ID with loading state
Future<Member?> fetchMemberById(WidgetRef ref, String id) async {
  ref.read(memberLoadingProvider.notifier).state = true;
  ref.read(memberErrorProvider.notifier).state = null;

  try {
    final member = await ref.read(memberByIdProvider(id).future);
    ref.read(memberLoadingProvider.notifier).state = false;
    return member;
  } catch (e) {
    ref.read(memberLoadingProvider.notifier).state = false;
    ref.read(memberErrorProvider.notifier).state = e.toString();
    return null;
  }
}

// Create member provider
final createMemberProvider =
    FutureProvider.family<Member, Map<String, dynamic>>(
        (ref, memberData) async {
  final memberService = ref.read(memberServiceProvider);
  ref.read(memberLoadingProvider.notifier).state = true;
  ref.read(memberErrorProvider.notifier).state = null;

  try {
    final member = await memberService.createMember(memberData);
    ref.read(memberLoadingProvider.notifier).state = false;

    // Refresh the member list
    ref.refresh(memberListProvider);

    return member;
  } catch (e) {
    ref.read(memberLoadingProvider.notifier).state = false;
    ref.read(memberErrorProvider.notifier).state = e.toString();
    throw e;
  }
});

// Update member provider
final updateMemberProvider =
    FutureProvider.family<Member, ({String id, Map<String, dynamic> data})>(
        (ref, params) async {
  final memberService = ref.read(memberServiceProvider);
  ref.read(memberLoadingProvider.notifier).state = true;
  ref.read(memberErrorProvider.notifier).state = null;

  try {
    final member = await memberService.updateMember(params.id, params.data);
    ref.read(memberLoadingProvider.notifier).state = false;

    // Refresh the member list
    ref.refresh(memberListProvider);

    return member;
  } catch (e) {
    ref.read(memberLoadingProvider.notifier).state = false;
    ref.read(memberErrorProvider.notifier).state = e.toString();
    throw e;
  }
});

// Delete member provider
final deleteMemberProvider =
    FutureProvider.family<bool, String>((ref, id) async {
  final memberService = ref.read(memberServiceProvider);
  ref.read(memberLoadingProvider.notifier).state = true;
  ref.read(memberErrorProvider.notifier).state = null;

  try {
    final result = await memberService.deleteMember(id);
    ref.read(memberLoadingProvider.notifier).state = false;

    // Refresh the member list
    ref.refresh(memberListProvider);

    return result;
  } catch (e) {
    ref.read(memberLoadingProvider.notifier).state = false;
    ref.read(memberErrorProvider.notifier).state = e.toString();
    throw e;
  }
});
