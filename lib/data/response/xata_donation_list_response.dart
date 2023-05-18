import 'package:donation/data/response/member_response.dart';

class XataDonationListResponse {
  Meta? meta;
  List<DonationRecord>? records;

  XataDonationListResponse({this.meta, this.records});

  XataDonationListResponse.fromJson(Map<String, dynamic> json) {
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    if (json['records'] != null) {
      records = <DonationRecord>[];
      json['records'].forEach((v) {
        records!.add(DonationRecord.fromJson(v));
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

class DonationRecord {
  String? date;
  String? hospital;
  String? id;
  MemberData? member;
  String? patientAddress;
  String? patientAge;
  String? patientDisease;
  String? patientName;
  Xata? xata;

  DonationRecord(
      {this.date,
      this.hospital,
      this.id,
      this.member,
      this.patientAddress,
      this.patientAge,
      this.patientDisease,
      this.patientName,
      this.xata});

  DonationRecord.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    hospital = json['hospital'];
    id = json['id'];
    member =
        json['member'] != null ? MemberData.fromJson(json['member']) : null;
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
