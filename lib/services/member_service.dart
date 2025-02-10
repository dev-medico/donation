import 'package:donation/core/api/api_response.dart';
import 'package:donation/models/member.dart';
import 'package:donation/repositories/member_repository.dart';

class MemberService {
  final MemberRepository _repository;

  MemberService({MemberRepository? repository})
      : _repository = repository ?? MemberRepository();

  Future<ApiResponse<List<Member>>> getAllMembers() async {
    return await _repository.getAllMembers();
  }

  Future<ApiResponse<Member>> getMemberById(String id) async {
    return await _repository.getMemberById(id);
  }

  Future<ApiResponse<Member>> createMember({
    required String name,
    required String bloodType,
    String? birthDate,
    String? fatherName,
    String? phone,
    String? address,
    String? nrc,
    String? gender,
    required String ownerId,
  }) async {
    final member = Member(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(), // This will be replaced by the backend
      name: name,
      bloodType: bloodType,
      birthDate: birthDate,
      fatherName: fatherName,
      phone: phone,
      address: address,
      nrc: nrc,
      gender: gender,
      registerDate: DateTime.now(),
      ownerId: ownerId,
    );

    return await _repository.createMember(member);
  }

  Future<ApiResponse<Member>> updateMember(
    String id, {
    String? name,
    String? bloodType,
    String? birthDate,
    String? fatherName,
    String? phone,
    String? address,
    String? nrc,
    String? gender,
    String? status,
  }) async {
    final response = await _repository.getMemberById(id);
    if (!response.success) {
      return response;
    }

    final updatedMember = response.data!.copyWith(
      name: name,
      bloodType: bloodType,
      birthDate: birthDate,
      fatherName: fatherName,
      phone: phone,
      address: address,
      nrc: nrc,
      gender: gender,
      status: status,
    );

    return await _repository.updateMember(id, updatedMember);
  }

  Future<ApiResponse<void>> deleteMember(String id) async {
    return await _repository.deleteMember(id);
  }

  Future<ApiResponse<List<Member>>> searchMembers({
    String? name,
    String? bloodType,
    String? phone,
  }) async {
    return await _repository.searchMembers(
      name: name,
      bloodType: bloodType,
      phone: phone,
    );
  }

  Future<ApiResponse<List<Member>>> getMembersByBloodType(
      String bloodType) async {
    return await searchMembers(bloodType: bloodType);
  }

  Future<ApiResponse<List<Member>>> getMembersByStatus(String status) async {
    final response = await getAllMembers();
    if (!response.success) {
      return response;
    }

    final filteredMembers =
        response.data?.where((member) => member.status == status).toList() ??
            [];

    return ApiResponse(
      success: true,
      message: 'Members filtered by status successfully',
      data: filteredMembers,
    );
  }
}
