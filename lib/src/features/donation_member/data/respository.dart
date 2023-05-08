import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:merchant/realm/realm_provider.dart';

class MemberRepository {
  WidgetRef ref;

  MemberRepository(this.ref);
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
    DateTime now = DateTime.now();

    ref.watch(realmServiceProvider)!.createMember(
        name: name,
        birthDate: birthDate,
        bloodBankCard: bloodBankNo,
        bloodType: bloodType,
        fatherName: fatherName,
        lastDate: now,
        memberCount: memberCount.toString(),
        totalCount: totalCount.toString(),
        memberId: memberId,
        note: note,
        nrc: nrc,
        phone: phone,
        registerDate: now,
        address: address);

    // XataRepository()
    //     .uploadNewMember(jsonEncode(<String, dynamic>{
    //   "birth_date": birthDate.toString(),
    //   "blood_bank_card": bloodBankNo.toString(),
    //   "last_donation_date": "",
    //   "donation_counts": 0,
    //   "note": noteController.text.toString() != ""
    //       ? noteController.text.toString()
    //       : "-",
    //   "nrc": nrc.toString(),
    //   "phone": phone.toString(),
    //   "total_count": int.parse(totalCount.toString()),
    //   "father_name": fatherName.toString(),
    //   "name": name.toString(),
    //   "register_date": date,
    //   "member_id": memberId.toString(),
    //   "blood_type": bloodType.toString(),
    //   "address": "$homeNo, $street, $quarter, $township, $region1"
    // }))
    //     .then((value) {
    //   if (value.statusCode.toString().startsWith("2")) {
    //     nameController.clear();
    //     memberIDController.clear();
    //     fatherNameController.clear();
    //     nrcController.clear();
    //     phoneController.clear();
    //     selectedBloodType = "သွေးအုပ်စု";
    //     birthDate = "မွေးသက္ကရာဇ်";
    //     bloodBankNoController.clear();
    //     totalDonationController.clear();
    //     homeNoController.clear();
    //     streetController.clear();
    //     quarterController.clear();
    //     townController.clear();
    //     region1 = "";
    //     regional = "";
    //     noteController.clear();

    //     XataRepository().getMembersTotal().then((value) {
    //       var newMemberCount = int.parse(
    //               TotalDataResponse.fromJson(jsonDecode(value.body))
    //                   .records!
    //                   .first
    //                   .value
    //                   .toString()) +
    //           1;
    //       XataRepository().updateMembersTotal(newMemberCount);
    //       setState(() {
    //         _isLoading = false;
    //       });
    //       Utils.messageSuccessDialog("အဖွဲ့၀င် အသစ်ထည့်ခြင်း \nအောင်မြင်ပါသည်။",
    //           context, "အိုကေ", Colors.black);
    //     });
    //   } else {
    //     log(value.statusCode.toString());
    //     log(value.body);
    //   }
    // });
  }
}
