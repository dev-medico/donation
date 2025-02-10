import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/services/member_service.dart';
import 'package:donation/repositories/member_repository.dart';
import 'package:donation/providers/member_provider.dart';

final memberServiceProvider = Provider<MemberService>((ref) {
  final repository = ref.watch(memberRepositoryProvider);
  return MemberService(repository: repository);
});

// Member creation state
final memberCreationStateProvider = StateProvider<AsyncValue<void>>((ref) {
  return const AsyncValue.data(null);
});

// Member update state
final memberUpdateStateProvider = StateProvider<AsyncValue<void>>((ref) {
  return const AsyncValue.data(null);
});

// Member deletion state
final memberDeletionStateProvider = StateProvider<AsyncValue<void>>((ref) {
  return const AsyncValue.data(null);
});

// Create member
final createMemberProvider =
    FutureProvider.family<void, Map<String, dynamic>>((ref, memberData) async {
  final memberService = ref.watch(memberServiceProvider);
  final stateNotifier = ref.read(memberCreationStateProvider.notifier);

  try {
    stateNotifier.state = const AsyncValue.loading();

    final response = await memberService.createMember(
      name: memberData['name'] as String,
      bloodType: memberData['bloodType'] as String,
      birthDate: memberData['birthDate'] as String?,
      fatherName: memberData['fatherName'] as String?,
      phone: memberData['phone'] as String?,
      address: memberData['address'] as String?,
      nrc: memberData['nrc'] as String?,
      gender: memberData['gender'] as String?,
      ownerId: memberData['ownerId'] as String,
    );

    if (!response.success) {
      throw Exception(response.message);
    }

    stateNotifier.state = const AsyncValue.data(null);
  } catch (error, stackTrace) {
    stateNotifier.state = AsyncValue.error(error, stackTrace);
    rethrow;
  }
});

// Update member
final updateMemberProvider =
    FutureProvider.family<void, Map<String, dynamic>>((ref, memberData) async {
  final memberService = ref.watch(memberServiceProvider);
  final stateNotifier = ref.read(memberUpdateStateProvider.notifier);

  try {
    stateNotifier.state = const AsyncValue.loading();

    final response = await memberService.updateMember(
      memberData['id'] as String,
      name: memberData['name'] as String?,
      bloodType: memberData['bloodType'] as String?,
      birthDate: memberData['birthDate'] as String?,
      fatherName: memberData['fatherName'] as String?,
      phone: memberData['phone'] as String?,
      address: memberData['address'] as String?,
      nrc: memberData['nrc'] as String?,
      gender: memberData['gender'] as String?,
      status: memberData['status'] as String?,
    );

    if (!response.success) {
      throw Exception(response.message);
    }

    stateNotifier.state = const AsyncValue.data(null);
  } catch (error, stackTrace) {
    stateNotifier.state = AsyncValue.error(error, stackTrace);
    rethrow;
  }
});

// Delete member
final deleteMemberProvider =
    FutureProvider.family<void, String>((ref, memberId) async {
  final memberService = ref.watch(memberServiceProvider);
  final stateNotifier = ref.read(memberDeletionStateProvider.notifier);

  try {
    stateNotifier.state = const AsyncValue.loading();

    final response = await memberService.deleteMember(memberId);
    if (!response.success) {
      throw Exception(response.message);
    }

    stateNotifier.state = const AsyncValue.data(null);
  } catch (error, stackTrace) {
    stateNotifier.state = AsyncValue.error(error, stackTrace);
    rethrow;
  }
});
