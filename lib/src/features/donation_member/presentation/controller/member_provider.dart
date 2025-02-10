import 'dart:developer';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/src/features/services/member_service.dart';
import 'package:donation/src/features/donation_member/models/member.dart';

typedef SearchParams = ({String? search, String? bloodType});
typedef AgeRangeParams = ({int? start, int? end});

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
    FutureProvider.family<List<Member>, SearchParams>((ref, searchParam) async {
  final memberService = ref.read(memberServiceProvider);
  final membersJson = await memberService.getMembers(
    search: searchParam.search,
    bloodType: searchParam.bloodType,
  );
  return membersJson
      .map((json) => Member.fromJson(json as Map<String, dynamic>))
      .toList();
});
