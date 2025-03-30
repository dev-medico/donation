import 'package:donation/src/features/member/models/member.dart';
import 'package:donation/src/features/services/member_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final memberListProvider =
    AsyncNotifierProvider<MemberListNotifier, List<Member>>(() {
  return MemberListNotifier();
});

class MemberListNotifier extends AsyncNotifier<List<Member>> {
  @override
  Future<List<Member>> build() async {
    return fetchMembers();
  }

  Future<List<Member>> fetchMembers() async {
    try {
      final memberService = ref.read(memberServiceProvider);
      final membersData = await memberService.getMembers();

      final members = membersData.map((data) => Member.fromJson(data)).toList();
      return members;
    } catch (e) {
      print('Error fetching members: $e');
      return []; // Return empty list on error rather than crashing
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => fetchMembers());
  }

  Future<Member?> getMemberById(String id) async {
    try {
      final memberService = ref.read(memberServiceProvider);
      final memberData = await memberService.getMemberById(id);
      return memberData != null ? Member.fromJson(memberData) : null;
    } catch (e) {
      print('Error getting member by ID: $e');
      return null;
    }
  }

  Future<Member?> createMember(Map<String, dynamic> data) async {
    try {
      final memberService = ref.read(memberServiceProvider);
      final memberData = await memberService.createMember(data);

      // Refresh the list to include the new member
      refresh();

      return memberData != null ? Member.fromJson(memberData) : null;
    } catch (e) {
      print('Error creating member: $e');
      return null;
    }
  }

  Future<Member?> updateMember(String id, Map<String, dynamic> data) async {
    try {
      final memberService = ref.read(memberServiceProvider);
      final memberData = await memberService.updateMember(id, data);

      // Refresh the list to reflect the updated member
      refresh();

      return memberData != null ? Member.fromJson(memberData) : null;
    } catch (e) {
      print('Error updating member: $e');
      return null;
    }
  }

  Future<bool> deleteMember(String id) async {
    try {
      final memberService = ref.read(memberServiceProvider);
      await memberService.deleteMember(id);

      // Refresh the list to remove the deleted member
      refresh();
      return true;
    } catch (e) {
      print('Error deleting member: $e');
      return false;
    }
  }
}

// Use the newly added getMembersByBlock method
final membersByBlockProvider =
    FutureProvider.family<List<Member>, String>((ref, block) async {
  try {
    final memberService = ref.read(memberServiceProvider);
    final membersData = await memberService.getMembersByBlock(block);

    return membersData.map((data) => Member.fromJson(data)).toList();
  } catch (e) {
    print('Error fetching members by block: $e');
    return [];
  }
});

final selectedMemberProvider = StateProvider<Member?>((ref) => null);
