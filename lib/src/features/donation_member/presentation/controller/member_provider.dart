import 'dart:developer';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/src/features/services/member_service.dart' as ms;
import 'package:donation/src/features/donation_member/domain/member.dart';

typedef SearchParams = ({String? search, String? bloodType});
typedef AgeRangeParams = ({int? start, int? end});

final memberServiceProvider =
    Provider<ms.MemberService>((ref) => ms.MemberService(ref));

final memberStreamProvider = StreamProvider.family<List<Member>, SearchParams>(
    (ref, searchParam) async* {
  final memberService = ref.read(memberServiceProvider);
  while (true) {
    final membersJson = await memberService.getMembers();
    // Filter members based on search parameters if needed
    final members = membersJson
        .map((json) => Member.fromJson(json as Map<String, dynamic>))
        .toList();

    final filteredMembers = members
        .where((member) =>
            (searchParam.search == null ||
                member.name != null &&
                    member.name!
                        .toLowerCase()
                        .contains(searchParam.search!.toLowerCase())) &&
            (searchParam.bloodType == null ||
                member.bloodType == searchParam.bloodType))
        .toList();

    yield filteredMembers;
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
  // Since getMemberStats doesn't exist, we'll compute it manually
  final membersProvider = ref.watch(membersDataProvider.future);
  final members = await membersProvider;

  int totalAge = 0;
  int count = 0;

  for (var member in members) {
    if (member.birthDate != null) {
      try {
        final birthDate = DateTime.parse(member.birthDate!);
        final age = DateTime.now().year - birthDate.year;
        totalAge += age;
        count++;
      } catch (e) {
        // Skip invalid dates
      }
    }
  }

  return count > 0 ? totalAge ~/ count : 0;
});

final memberCountByAgeRangeProvider =
    FutureProvider.family<int, AgeRangeParams>((ref, ageRange) async {
  final memberService = ref.read(memberServiceProvider);
  final members = await memberService.getMembersByAgeRange(
      ageRange.start ?? 0, ageRange.end ?? 100);
  return members.length;
});

final membersDataByTotalCountProvider =
    FutureProvider<List<Member>>((ref) async {
  // Since getMembersByTotalCount doesn't exist, we'll sort them by totalCount
  final memberService = ref.read(memberServiceProvider);
  final membersJson = await memberService.getMembers();
  final members = membersJson
      .map((json) => Member.fromJson(json as Map<String, dynamic>))
      .toList();

  // Sort by totalCount if available
  members.sort((a, b) {
    final countA = int.tryParse(a.totalCount ?? '0') ?? 0;
    final countB = int.tryParse(b.totalCount ?? '0') ?? 0;
    return countB.compareTo(countA); // Descending order
  });

  return members;
});

final membersDataByPhoneProvider =
    FutureProvider.family<Member?, String>((ref, phone) async {
  // Since getMemberByPhone doesn't exist, we'll filter by phone
  final memberService = ref.read(memberServiceProvider);
  try {
    final membersJson = await memberService.getMembers();
    final members = membersJson
        .map((json) => Member.fromJson(json as Map<String, dynamic>))
        .toList();

    return members.firstWhere(
      (member) => member.phone == phone,
      orElse: () => throw Exception('Member not found with phone: $phone'),
    );
  } catch (e) {
    return null;
  }
});

final loginMemberProvider = StateProvider<Member?>((ref) => null);

final searchMemberProvider =
    FutureProvider.family<List<Member>, ({String? search, String? bloodType})>(
  (ref, params) async {
    final memberService = ref.watch(memberServiceProvider);
    // Since searchMembers doesn't exist, we'll use findMembers or filter from getMembers
    List<dynamic> results = [];
    if (params.search != null && params.search!.isNotEmpty) {
      results = await memberService.findMembers(params.search!);
    } else {
      results = await memberService.getMembers();
    }

    final members = results
        .map((json) => Member.fromJson(json as Map<String, dynamic>))
        .toList();

    // Filter by blood type if specified
    if (params.bloodType != null && params.bloodType!.isNotEmpty) {
      return members
          .where((member) => member.bloodType == params.bloodType)
          .toList();
    }

    return members;
  },
);

// Fetch and cache the full member list
final memberListProvider = FutureProvider<List<Member>>((ref) async {
  ref.read(memberLoadingProvider.notifier).state = true;
  ref.read(memberErrorProvider.notifier).state = null;

  try {
    final memberService = ref.read(memberServiceProvider);
    final membersData = await memberService.getMembers(limit: 1000);
    final members = membersData
        .map((json) => Member.fromJson(json as Map<String, dynamic>))
        .toList();

    ref.read(memberLoadingProvider.notifier).state = false;
    return members;
  } catch (e) {
    ref.read(memberLoadingProvider.notifier).state = false;
    ref.read(memberErrorProvider.notifier).state = e.toString();
    print('Error fetching members: $e');
    return [];
  }
});

// Filter states
final memberSearchQueryProvider = StateProvider<String>((ref) => '');
final memberBloodTypeFilterProvider =
    StateProvider<String>((ref) => 'သွေးအုပ်စုဖြင့် ရှာဖွေမည်');
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
      if (bloodType != 'သွေးအုပ်စုဖြင့် ရှာဖွေမည်' && bloodType.isNotEmpty) {
        filtered = filtered
            .where((member) =>
                member.bloodType
                    ?.toLowerCase()
                    .contains(bloodType.toLowerCase()) ??
                false)
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

  if (bloodType != 'သွေးအုပ်စုဖြင့် ရှာဖွေမည်' && bloodType.isNotEmpty) {
    filtered = filtered
        .where((member) =>
            member.bloodType?.toLowerCase().contains(bloodType.toLowerCase()) ??
            false)
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

// Provider for the member loading status
final memberLoadingProvider = StateProvider<bool>((ref) => false);

// Provider for any error messages
final memberErrorProvider = StateProvider<String?>((ref) => null);

// Provider for the list of all members
final membersProvider = FutureProvider<List<Member>>((ref) async {
  final memberService = ref.read(memberServiceProvider);
  ref.read(memberLoadingProvider.notifier).state = true;
  ref.read(memberErrorProvider.notifier).state = null;

  try {
    final membersData = await memberService.getMembers();
    final members = membersData.map((data) => Member.fromJson(data)).toList();
    ref.read(memberLoadingProvider.notifier).state = false;
    return members;
  } catch (e) {
    ref.read(memberLoadingProvider.notifier).state = false;
    ref.read(memberErrorProvider.notifier).state = e.toString();
    return [];
  }
});

// Provider for a specific member by ID
final memberByIdProvider =
    FutureProvider.family<Member, String>((ref, id) async {
  if (id.isEmpty) {
    throw Exception('Invalid member ID');
  }

  ref.read(memberLoadingProvider.notifier).state = true;
  ref.read(memberErrorProvider.notifier).state = null;

  try {
    log("Fetching Member ID - " + id);
    final memberService = ref.read(memberServiceProvider);
    final memberData = await memberService.getMemberById(id);
    final member = Member.fromJson(memberData);
    ref.read(memberLoadingProvider.notifier).state = false;
    return member;
  } catch (e) {
    ref.read(memberLoadingProvider.notifier).state = false;
    ref.read(memberErrorProvider.notifier).state = e.toString();
    log("Error fetching member: $e");
    throw e;
  }
});

// Provider for searching members
final memberSearchProvider =
    FutureProvider.family<List<Member>, String>((ref, query) async {
  if (query.isEmpty) return [];

  ref.read(memberLoadingProvider.notifier).state = true;
  ref.read(memberErrorProvider.notifier).state = null;

  try {
    final memberService = ref.read(memberServiceProvider);
    final membersData = await memberService.findMembers(query);
    final members = membersData.map((data) => Member.fromJson(data)).toList();
    ref.read(memberLoadingProvider.notifier).state = false;
    return members;
  } catch (e) {
    ref.read(memberLoadingProvider.notifier).state = false;
    ref.read(memberErrorProvider.notifier).state = e.toString();
    return [];
  }
});

// Provider for the selected member
final selectedMemberProvider = StateProvider<Member?>((ref) => null);

// Provider for blood type filter
final bloodTypeFilterProvider = StateProvider<String?>((ref) => null);

// Provider for filtered members
final filteredMembersProvider = FutureProvider<List<Member>>((ref) async {
  final bloodType = ref.watch(bloodTypeFilterProvider);

  if (bloodType == null || bloodType.isEmpty) {
    return ref.watch(membersProvider).value ?? [];
  }

  final allMembers = ref.watch(membersProvider).value ?? [];
  return allMembers.where((member) => member.bloodType == bloodType).toList();
});
