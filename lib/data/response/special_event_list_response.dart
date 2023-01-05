class SpecialEventListResponse {
  Meta? meta;
  List<SpecialEventData>? specialEventData;

  SpecialEventListResponse({this.meta, this.specialEventData});

  SpecialEventListResponse.fromJson(Map<String, dynamic> json) {
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    if (json['records'] != null) {
      specialEventData = <SpecialEventData>[];
      json['records'].forEach((v) {
        specialEventData!.add(SpecialEventData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (meta != null) {
      data['meta'] = meta!.toJson();
    }
    if (specialEventData != null) {
      data['records'] = specialEventData!.map((v) => v.toJson()).toList();
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

class SpecialEventData {
  String? date;
  int? haemoglobin;
  int? hbsAg;
  int? hcvAb;
  String? id;
  int? mpIct;
  int? retroTest;
  int? vdrlTest;
  String? labName;
  int? total;
  Xata? xata;

  SpecialEventData(
      {this.date,
      this.haemoglobin,
      this.hbsAg,
      this.hcvAb,
      this.id,
      this.mpIct,
      this.retroTest,
      this.vdrlTest,
      this.labName,
      this.total,
      this.xata});

  SpecialEventData.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    haemoglobin = json['haemoglobin'];
    hbsAg = json['hbs_ag'];
    hcvAb = json['hcv_ab'];
    id = json['id'];
    mpIct = json['mp_ict'];
    retroTest = json['retro_test'];
    vdrlTest = json['vdrl_test'];
    labName = json['lab_name'];
    total = json['total'];
    xata = json['xata'] != null ? Xata.fromJson(json['xata']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['haemoglobin'] = haemoglobin;
    data['hbs_ag'] = hbsAg;
    data['hcv_ab'] = hcvAb;
    data['id'] = id;
    data['mp_ict'] = mpIct;
    data['retro_test'] = retroTest;
    data['vdrl_test'] = vdrlTest;
    data['lab_name'] = labName;
    data['total'] = total;
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
