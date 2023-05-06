import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:merchant/src/features/donation_member/data/respository.dart';

class MemberService {
  MemberRepository _memberRepository;

  MemberService(this._memberRepository,);

  addMember(
      String memberId,
      String name,
      String fatherName,
      String birthDate,
      String nrc,
      String phone,
      String bloodType,
      String bloodBankNo,
      String totalCount,
      String homeNo,
      String street,
      String quarter,
      String township,
      String note,
      String region) {
    _memberRepository.addMember(
        memberId,
        name,
        fatherName,
        birthDate,
        nrc,
        phone,
        bloodType,
        bloodBankNo,
        totalCount,
        homeNo,
        street,
        quarter,
        township,
        note,
        region);
  }
}
