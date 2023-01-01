class MemberListResponse {
  List<MemberData>? data;

  MemberListResponse({this.data});

  MemberListResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <MemberData>[];
      json['data'].forEach((v) {
        data!.add(MemberData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MemberData {
  String? address;
  String? birthDate;
  String? bloodBankCard;
  String? bloodType;
  int? donationCounts;
  String? fatherName;
  String? id;
  String? lastDonationDate;
  String? memberId;
  String? name;
  String? note;
  String? nrc;
  String? phone;
  String? registerDate;
  int? totalCount;

  MemberData(
      {this.address,
      this.birthDate,
      this.bloodBankCard,
      this.bloodType,
      this.donationCounts,
      this.fatherName,
      this.id,
      this.lastDonationDate,
      this.memberId,
      this.name,
      this.note,
      this.nrc,
      this.phone,
      this.registerDate,
      this.totalCount});

  MemberData.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    birthDate = json['birth_date'];
    bloodBankCard = json['blood_bank_card'];
    bloodType = json['blood_type'];
    donationCounts = json['donation_counts'];
    fatherName = json['father_name'];
    id = json['id'];
    lastDonationDate = json['last_donation_date'];
    memberId = json['member_id'];
    name = json['name'];
    note = json['note'];
    nrc = json['nrc'];
    phone = json['phone'];
    registerDate = json['register_date'];
    totalCount = json['total_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['address'] = address;
    data['birth_date'] = birthDate;
    data['blood_bank_card'] = bloodBankCard;
    data['blood_type'] = bloodType;
    data['donation_counts'] = donationCounts;
    data['father_name'] = fatherName;
    data['id'] = id;
    data['last_donation_date'] = lastDonationDate;
    data['member_id'] = memberId;
    data['name'] = name;
    data['note'] = note;
    data['nrc'] = nrc;
    data['phone'] = phone;
    data['register_date'] = registerDate;
    data['total_count'] = totalCount;
    return data;
  }
}
