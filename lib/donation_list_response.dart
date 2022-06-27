class DonationListResponse {
  List<DonationData>? data;

  DonationListResponse({this.data});

  DonationListResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <DonationData>[];
      json['data'].forEach((v) {
        data!.add(DonationData.fromJson(v));
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

class DonationData {
  String? id;
  String? date;
  String? dateDetail;
  int? day;
  String? hospital;
  String? memberBirthDate;
  String? memberBloodBankCard;
  String? memberBloodType;
  String? memberFatherName;
  String? memberId;
  String? memberName;
  String? month;
  String? patientAddress;
  String? patientAge;
  String? patientDisease;
  String? patientName;
  int? year;

  DonationData(
      {this.id,
      this.date,
      this.dateDetail,
      this.day,
      this.hospital,
      this.memberBirthDate,
      this.memberBloodBankCard,
      this.memberBloodType,
      this.memberFatherName,
      this.memberId,
      this.memberName,
      this.month,
      this.patientAddress,
      this.patientAge,
      this.patientDisease,
      this.patientName,
      this.year});

  DonationData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    date = json['date'];
    dateDetail = json['date_detail'];
    day = json['day'];
    hospital = json['hospital'];
    memberBirthDate = json['member_birth_date'];
    memberBloodBankCard = json['member_blood_bank_card'];
    memberBloodType = json['member_blood_type'];
    memberFatherName = json['member_father_name'];
    memberId = json['member_id'];
    memberName = json['member_name'];
    month = json['month'];
    patientAddress = json['patient_address'];
    patientAge = json['patient_age'];
    patientDisease = json['patient_disease'];
    patientName = json['patient_name'];
    year = json['year'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['date'] = date;
    data['date_detail'] = dateDetail;
    data['day'] = day;
    data['hospital'] = hospital;
    data['member_birth_date'] = memberBirthDate;
    data['member_blood_bank_card'] = memberBloodBankCard;
    data['member_blood_type'] = memberBloodType;
    data['member_father_name'] = memberFatherName;
    data['member_id'] = memberId;
    data['member_name'] = memberName;
    data['month'] = month;
    data['patient_address'] = patientAddress;
    data['patient_age'] = patientAge;
    data['patient_disease'] = patientDisease;
    data['patient_name'] = patientName;
    data['year'] = year;
    return data;
  }
}
