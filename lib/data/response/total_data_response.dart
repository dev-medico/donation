class TotalDataResponse {
  Meta? meta;
  List<Records>? records;

  TotalDataResponse({this.meta, this.records});

  TotalDataResponse.fromJson(Map<String, dynamic> json) {
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
    if (json['records'] != null) {
      records = <Records>[];
      json['records'].forEach((v) {
        records!.add(Records.fromJson(v));
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

class Records {
  String? id;
  dynamic value;
  Xata? xata;

  Records({this.id, this.value, this.xata});

  Records.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    value = json['value'];
    xata = json['xata'] != null ? Xata.fromJson(json['xata']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['value'] = value;
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
