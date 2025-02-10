import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:donation/models/member.dart';
import 'package:donation/repositories/member_repository.dart';

final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  return MemberRepository();
});

final membersProvider = FutureProvider<List<Member>>((ref) async {
  final repository = ref.watch(memberRepositoryProvider);
  final response = await repository.getAllMembers();
  if (!response.success) {
    throw Exception(response.message);
  }
  return response.data ?? [];
});

final memberSearchProvider =
    FutureProvider.family<List<Member>, Map<String, String?>>(
        (ref, searchParams) async {
  final repository = ref.watch(memberRepositoryProvider);
  final response = await repository.searchMembers(
    name: searchParams['name'],
    bloodType: searchParams['bloodType'],
    phone: searchParams['phone'],
  );
  if (!response.success) {
    throw Exception(response.message);
  }
  return response.data ?? [];
});

final selectedMemberProvider =
    FutureProvider.family<Member, String>((ref, id) async {
  final repository = ref.watch(memberRepositoryProvider);
  final response = await repository.getMemberById(id);
  if (!response.success) {
    throw Exception(response.message);
  }
  return response.data!;
});
