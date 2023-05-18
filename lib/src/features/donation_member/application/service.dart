import 'package:donation/src/features/donation_member/data/respository.dart';

class MemberService {
  MemberRepository _memberRepository;

  MemberService(
    this._memberRepository,
  );

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
    String memberCount,
    String address,
    String note,
  ) {
    _memberRepository.addMember(memberId, name, fatherName, birthDate, nrc,
        phone, bloodType, bloodBankNo, totalCount, memberCount, address, note);
  }
}
