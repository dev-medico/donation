

class Data {
  String? birthDate;
  String? bloodBankCard;
  String? bloodType;
  String? fatherName;
  String? homeNo;
  String? lastDate;
  LastDateDetail? lastDateDetail;
  dynamic memberCount;
  String? memberId;
  String? name;
  String? note;
  String? nrc;
  String? phone;
  String? quarter;
  String? region;
  String? registerDate;
  String? street;
  dynamic totalCount;
  String? town;

  Data(
      {this.birthDate,
      this.bloodBankCard,
      this.bloodType,
      this.fatherName,
      this.homeNo,
      this.lastDate,
      this.lastDateDetail,
      this.memberCount,
      this.memberId,
      this.name,
      this.note,
      this.nrc,
      this.phone,
      this.quarter,
      this.region,
      this.registerDate,
      this.street,
      this.totalCount,
      this.town});

  Data.fromJson(Map<String, dynamic> json) {
    birthDate = json['birth_date'];
    bloodBankCard = json['blood_bank_card'];
    bloodType = json['blood_type'];
    fatherName = json['father_name'];
    homeNo = json['home_no'];
    lastDate = json['last_date'];
    lastDateDetail = json['last_date_detail'] != null
        ? LastDateDetail.fromJson(json['last_date_detail'])
        : null;
    memberCount = json['member_count'];
    memberId = json['member_id'];
    name = json['name'];
    note = json['note'];
    nrc = json['nrc'];
    phone = json['phone'];
    quarter = json['quarter'];
    region = json['region'];
    registerDate = json['register_date'];
    street = json['street'];
    totalCount = json['total_count'];
    town = json['town'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['birth_date'] = birthDate;
    data['blood_bank_card'] = bloodBankCard;
    data['blood_type'] = bloodType;
    data['father_name'] = fatherName;
    data['home_no'] = homeNo;
    data['last_date'] = lastDate;
    if (lastDateDetail != null) {
      data['last_date_detail'] = lastDateDetail!.toJson();
    }
    data['member_count'] = memberCount;
    data['member_id'] = memberId;
    data['name'] = name;
    data['note'] = note;
    data['nrc'] = nrc;
    data['phone'] = phone;
    data['quarter'] = quarter;
    data['region'] = region;
    data['register_date'] = registerDate;
    data['street'] = street;
    data['total_count'] = totalCount;
    data['town'] = town;
    return data;
  }
}

class LastDateDetail {
  String? sDatatype;
  String? value;

  LastDateDetail({this.sDatatype, this.value});

  LastDateDetail.fromJson(Map<String, dynamic> json) {
    sDatatype = json['__datatype__'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['__datatype__'] = sDatatype;
    data['value'] = value;
    return data;
  }
}
