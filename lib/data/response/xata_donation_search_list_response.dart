class DonationSearchListResponse {
  Meta? meta;
  List<DonationSearchRecords>? records;

  DonationSearchListResponse({this.meta, this.records});

  DonationSearchListResponse.fromJson(Map<String, dynamic> json) {
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    if (json['records'] != null) {
      records = <DonationSearchRecords>[];
      json['records'].forEach((v) {
        records!.add(DonationSearchRecords.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (meta != null) {
      data['meta'] = meta!.toJson();
    }
    if (records != null) {
      data['records'] = records!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Meta {
  Page? page;

  Meta({this.page});

  Meta.fromJson(Map<String, dynamic> json) {
    page = json['page'] != null ? Page.fromJson(json['page']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (page != null) {
      data['page'] = page!.toJson();
    }
    return data;
  }
}

class Page {
  String? cursor;
  bool? more;

  Page({this.cursor, this.more});

  Page.fromJson(Map<String, dynamic> json) {
    cursor = json['cursor'];
    more = json['more'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cursor'] = cursor;
    data['more'] = more;
    return data;
  }
}

class DonationSearchRecords {
  String? date;
  String? hospital;
  String? id;
  Member? member;
  String? patientAddress;
  String? patientAge;
  String? patientDisease;
  String? patientName;
  Xata? xata;

  DonationSearchRecords(
      {this.date,
      this.hospital,
      this.id,
      this.member,
      this.patientAddress,
      this.patientAge,
      this.patientDisease,
      this.patientName,
      this.xata});

  DonationSearchRecords.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    hospital = json['hospital'];
    id = json['id'];
    member = json['member'] != null ? Member.fromJson(json['member']) : null;
    patientAddress = json['patient_address'];
    patientAge = json['patient_age'];
    patientDisease = json['patient_disease'];
    patientName = json['patient_name'];
    xata = json['xata'] != null ? Xata.fromJson(json['xata']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['hospital'] = hospital;
    data['id'] = id;
    if (member != null) {
      data['member'] = member!.toJson();
    }
    data['patient_address'] = patientAddress;
    data['patient_age'] = patientAge;
    data['patient_disease'] = patientDisease;
    data['patient_name'] = patientName;
    if (xata != null) {
      data['xata'] = xata!.toJson();
    }
    return data;
  }
}

class Member {
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
  Xata? xata;

  Member(
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
      this.totalCount,
      this.xata});

  Member.fromJson(Map<String, dynamic> json) {
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
    xata = json['xata'] != null ? Xata.fromJson(json['xata']) : null;
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
    if (xata != null) {
      data['xata'] = xata!.toJson();
    }
    return data;
  }
}

class Xata {
  int? version;

  Xata({this.version});

  Xata.fromJson(Map<String, dynamic> json) {
    version = json['version'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['version'] = version;
    return data;
  }
}
