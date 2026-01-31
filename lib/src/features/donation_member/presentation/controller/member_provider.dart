import 'dart:developer';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/src/features/services/member_service.dart' as ms;
import 'package:donation/src/features/donation_member/domain/member.dart';
import 'package:donation/src/features/donation_member/domain/member_range.dart';
import 'package:donation/src/features/donation_member/data/member_repository.dart';
import 'package:donation/src/features/donation_member/data/search_member_repository.dart';

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
  final membersProvider = ref.watch(memberListProvider.future);
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

// Repository provider
final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  return MemberRepository();
});

// Search member repository provider
final searchMemberRepositoryProvider = Provider<SearchMemberRepository>((ref) {
  return SearchMemberRepository();
});

// Loading and error state providers
final memberLoadingProvider = StateProvider<bool>((ref) => false);
final memberErrorProvider = StateProvider<String?>((ref) => null);

// Replace the existing memberListProvider with a simple data-only provider
final memberListProvider = FutureProvider.autoDispose<List<Member>>((ref) {
  // Only fetch data without modifying any other state
  final repository = ref.read(memberRepositoryProvider);
  // Member list should show all members without year filter
  return repository.getAllMembers(forceRefresh: false);
});

// Separate provider for search member list with year filter
final searchMemberListWithYearProvider = FutureProvider.autoDispose<List<Member>>((ref) {
  final repository = ref.read(searchMemberRepositoryProvider);
  final donationYear = ref.watch(searchMemberDonationYearFilterProvider);
  final searchQuery = ref.watch(searchMemberQueryProvider);
  final bloodType = ref.watch(searchMemberBloodTypeFilterProvider);
  
  return repository.searchMembers(
    query: searchQuery.isEmpty ? null : searchQuery,
    bloodType: (bloodType == 'သွေးအုပ်စုဖြင့် ရှာဖွေမည်' || bloodType.isEmpty) ? null : bloodType,
    donationYear: donationYear,
  );
});

// Add a separate function to handle loading state
final loadMembersProvider =
    Provider<Future<List<Member>> Function(bool)>((ref) {
  return (bool forceRefresh) async {
    try {
      // First update the loading states
      ref.read(memberLoadingProvider.notifier).state = true;
      ref.read(memberErrorProvider.notifier).state = null;
      ref.read(memberLoadingStatusProvider.notifier).state =
          'အဖွဲ့၀င်များ ရယူနေပါသည်...';

      // Get repository and fetch data
      final repository = ref.read(memberRepositoryProvider);
      final members =
          await repository.getAllMembers(forceRefresh: forceRefresh);

      // Update states after fetching
      ref.read(memberLoadingProvider.notifier).state = false;
      ref.read(memberLoadingStatusProvider.notifier).state = '';

      // Invalidate the provider to refresh the data
      if (forceRefresh) {
        ref.invalidate(memberListProvider);
      }

      return members;
    } catch (e) {
      // Handle error
      ref.read(memberLoadingProvider.notifier).state = false;
      ref.read(memberErrorProvider.notifier).state = e.toString();
      ref.read(memberLoadingStatusProvider.notifier).state = '';
      log('Error fetching members: $e');
      return [];
    }
  };
});

// Filter states
final memberSearchQueryProvider = StateProvider<String>((ref) => '');
final memberBloodTypeFilterProvider =
    StateProvider<String>((ref) => 'သွေးအုပ်စုဖြင့် ရှာဖွေမည်');
final memberRangeFilterProvider = StateProvider<String?>((ref) => null);

// =====================================================
// NEW: Optimized Range-based Providers for Lazy Loading
// =====================================================

/// Selected MemberRange object (instead of String)
final selectedMemberRangeProvider = StateProvider<MemberRange?>((ref) => null);

// =====================================================
// Pagination State Providers for Infinite Scroll
// =====================================================

/// Current page for pagination (0-indexed)
final memberPageProvider = StateProvider<int>((ref) => 0);

/// Whether there are more members to load
final memberHasMoreProvider = StateProvider<bool>((ref) => true);

/// Whether currently loading more members
final memberIsLoadingMoreProvider = StateProvider<bool>((ref) => false);

/// Accumulated members list for pagination
final accumulatedMembersProvider = StateProvider<List<Member>>((ref) => []);

/// Fetch ranges from API - this returns quickly with just range metadata
final memberRangesProvider = FutureProvider.autoDispose<List<MemberRange>>((ref) async {
  final repository = ref.read(memberRepositoryProvider);
  final bloodType = ref.watch(memberBloodTypeFilterProvider);

  return repository.getMemberRanges(
    bloodType: bloodType != 'သွေးအုပ်စုဖြင့် ရှာဖွေမည်' ? bloodType : null,
  );
});

/// Fetch members only for the selected range (lazy loading)
/// Returns initial 50 members if no range is selected (with search support)
final rangedMemberListProvider = FutureProvider.autoDispose<List<Member>>((ref) async {
  final selectedRange = ref.watch(selectedMemberRangeProvider);
  final repository = ref.read(memberRepositoryProvider);
  final searchQuery = ref.watch(memberSearchQueryProvider);
  final bloodType = ref.watch(memberBloodTypeFilterProvider);

  // Watch individual search providers for server-side filtering
  final phoneSearch = ref.watch(memberPhoneSearchProvider);
  final fatherNameSearch = ref.watch(memberFatherNameSearchProvider);
  final bloodBankCardSearch = ref.watch(memberBloodBankCardSearchProvider);
  final memberIdSearch = ref.watch(memberIdSearchProvider);
  final birthDateSearch = ref.watch(memberBirthDateSearchProvider);

  // If no range selected, show initial 50 members (with search support)
  if (selectedRange == null) {
    return repository.getInitialMembers(
      limit: 50,
      query: searchQuery.isNotEmpty ? searchQuery : null,
      bloodType: bloodType != 'သွေးအုပ်စုဖြင့် ရှာဖွေမည်' ? bloodType : null,
      phone: phoneSearch.isNotEmpty ? phoneSearch : null,
      fatherName: fatherNameSearch.isNotEmpty ? fatherNameSearch : null,
      bloodBankCard: bloodBankCardSearch.isNotEmpty ? bloodBankCardSearch : null,
      memberIdSearch: memberIdSearch.isNotEmpty ? memberIdSearch : null,
      birthDate: birthDateSearch.isNotEmpty ? birthDateSearch : null,
    );
  }

  // Otherwise fetch for selected range
  return repository.getMembersByRange(
    rangeStart: selectedRange.start,
    rangeEnd: selectedRange.end,
    query: searchQuery.isNotEmpty ? searchQuery : null,
    bloodType: bloodType != 'သွေးအုပ်စုဖြင့် ရှာဖွေမည်' ? bloodType : null,
    phone: phoneSearch.isNotEmpty ? phoneSearch : null,
    fatherName: fatherNameSearch.isNotEmpty ? fatherNameSearch : null,
    bloodBankCard: bloodBankCardSearch.isNotEmpty ? bloodBankCardSearch : null,
    memberIdSearch: memberIdSearch.isNotEmpty ? memberIdSearch : null,
    birthDate: birthDateSearch.isNotEmpty ? birthDateSearch : null,
  );
});

/// Total member count from ranges API
final totalMemberCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final repository = ref.read(memberRepositoryProvider);
  final bloodType = ref.watch(memberBloodTypeFilterProvider);

  try {
    final ranges = await repository.getMemberRanges(
      bloodType: bloodType != 'သွေးအုပ်စုဖြင့် ရှာဖွေမည်' ? bloodType : null,
    );
    return ranges.fold<int>(0, (sum, range) => sum + range.count);
  } catch (e) {
    return 0;
  }
});

// Additional search field providers
final memberBirthDateSearchProvider = StateProvider<String>((ref) => '');
final memberPhoneSearchProvider = StateProvider<String>((ref) => '');
final memberFatherNameSearchProvider = StateProvider<String>((ref) => '');
final memberBloodBankCardSearchProvider = StateProvider<String>((ref) => '');
final memberIdSearchProvider = StateProvider<String>((ref) => '');

// Separate filter providers for search member screen
final searchMemberQueryProvider = StateProvider<String>((ref) => '');
final searchMemberBloodTypeFilterProvider =
    StateProvider<String>((ref) => 'သွေးအုပ်စုဖြင့် ရှာဖွေမည်');
final searchMemberDonationYearFilterProvider = 
    StateProvider<String?>((ref) => DateTime.now().year.toString());

// Filtered members provider
final filteredMemberListProvider = StateProvider.autoDispose<List<Member>>((ref) {
  final allMembersAsync = ref.watch(memberListProvider);

  return allMembersAsync.when(
    data: (allMembers) {
      final searchQuery = ref.watch(memberSearchQueryProvider);
      final bloodType = ref.watch(memberBloodTypeFilterProvider);
      final range = ref.watch(memberRangeFilterProvider);

      List<Member> filtered = List.from(allMembers);

      // Apply main page filters if they're set
      if (bloodType != 'သွေးအုပ်စုဖြင့် ရှာဖွေမည်' && bloodType.isNotEmpty) {
        filtered = filtered
            .where((member) =>
                member.bloodType
                    ?.toLowerCase()
                    .contains(bloodType.toLowerCase()) ??
                false)
            .toList();
      }

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

      // Apply additional search filters
      final birthDateSearch = ref.watch(memberBirthDateSearchProvider);
      final phoneSearch = ref.watch(memberPhoneSearchProvider);
      final fatherNameSearch = ref.watch(memberFatherNameSearchProvider);
      final bloodBankCardSearch = ref.watch(memberBloodBankCardSearchProvider);
      final memberIdSearch = ref.watch(memberIdSearchProvider);
      
      if (birthDateSearch.isNotEmpty) {
        filtered = filtered
            .where((member) =>
                member.birthDate?.toLowerCase().contains(birthDateSearch.toLowerCase()) ?? false)
            .toList();
      }
      
      if (phoneSearch.isNotEmpty) {
        filtered = filtered
            .where((member) =>
                member.phone?.toLowerCase().contains(phoneSearch.toLowerCase()) ?? false)
            .toList();
      }
      
      if (fatherNameSearch.isNotEmpty) {
        filtered = filtered
            .where((member) =>
                member.fatherName?.toLowerCase().contains(fatherNameSearch.toLowerCase()) ?? false)
            .toList();
      }
      
      if (bloodBankCardSearch.isNotEmpty) {
        filtered = filtered
            .where((member) =>
                member.bloodBankCard?.toLowerCase().contains(bloodBankCardSearch.toLowerCase()) ?? false)
            .toList();
      }
      
      if (memberIdSearch.isNotEmpty) {
        filtered = filtered
            .where((member) =>
                member.memberId?.toLowerCase().contains(memberIdSearch.toLowerCase()) ?? false)
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

// Separate provider for search member screen - simply returns the search results
final filteredSearchMemberListProvider = StateProvider.autoDispose<List<Member>>((ref) {
  // The searchMemberListWithYearProvider already handles filtering
  // This provider just returns the results for display
  final allMembersAsync = ref.watch(searchMemberListWithYearProvider);

  return allMembersAsync.when(
    data: (members) => members,
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
            member.bloodType?.toLowerCase().trim() == bloodType.toLowerCase().trim())
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

// Function to update filtered members for search screen
void updateSearchFilteredMembers(WidgetRef ref) {
  // The search is now handled by the API, so we just refresh the provider
  ref.invalidate(searchMemberListWithYearProvider);
}

// Provider for the member loading status
final memberLoadingStatusProvider = StateProvider<String>((ref) => '');

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
    return ref.watch(memberListProvider).value ?? [];
  }

  final allMembers = ref.watch(memberListProvider).value ?? [];
  return allMembers.where((member) => member.bloodType == bloodType).toList();
});

// Update the refresh provider to use the new loading function
final refreshMembersProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    try {
      // Use the loadMembersProvider to handle the loading states
      await ref.read(loadMembersProvider)(true);
    } catch (e) {
      log('Error refreshing members: $e');
    }
  };
});

// Function to reset all filter providers
void resetFilterProviders(WidgetRef ref) {
  ref.read(memberSearchQueryProvider.notifier).state = '';
  ref.read(memberBloodTypeFilterProvider.notifier).state =
      'သွေးအုပ်စုဖြင့် ရှာဖွေမည်';
  ref.read(memberRangeFilterProvider.notifier).state = null;
  ref.read(selectedMemberRangeProvider.notifier).state = null; // Reset new range provider
  ref.read(memberBirthDateSearchProvider.notifier).state = '';
  ref.read(memberPhoneSearchProvider.notifier).state = '';
  ref.read(memberFatherNameSearchProvider.notifier).state = '';
  ref.read(memberBloodBankCardSearchProvider.notifier).state = '';
  ref.read(memberIdSearchProvider.notifier).state = '';
  // Reset pagination state
  resetPaginationState(ref);
}

// Function to reset pagination state
void resetPaginationState(WidgetRef ref) {
  ref.read(memberPageProvider.notifier).state = 0;
  ref.read(memberHasMoreProvider.notifier).state = true;
  ref.read(memberIsLoadingMoreProvider.notifier).state = false;
  ref.read(accumulatedMembersProvider.notifier).state = [];
}

// Function to reset search member filter providers
void resetSearchFilterProviders(WidgetRef ref) {
  ref.read(searchMemberQueryProvider.notifier).state = '';
  ref.read(searchMemberBloodTypeFilterProvider.notifier).state =
      'သွေးအုပ်စုဖြင့် ရှာဖွေမည်';
  ref.read(searchMemberDonationYearFilterProvider.notifier).state = DateTime.now().year.toString();
}
