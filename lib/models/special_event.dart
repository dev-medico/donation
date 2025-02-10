class SpecialEvent {
  final String id;
  final String? date;
  final int? haemoglobin;
  final int? hbsAg;
  final int? hcvAb;
  final int? mpIct;
  final int? retroTest;
  final String? labName;
  final int? total;

  SpecialEvent({
    required this.id,
    this.date,
    this.haemoglobin,
    this.hbsAg,
    this.hcvAb,
    this.mpIct,
    this.retroTest,
    this.labName,
    this.total,
  });

  factory SpecialEvent.fromJson(Map<String, dynamic> json) {
    return SpecialEvent(
      id: json['_id'] as String,
      date: json['date'] as String?,
      haemoglobin: json['haemoglobin'] as int?,
      hbsAg: json['hbsAg'] as int?,
      hcvAb: json['hcvAb'] as int?,
      mpIct: json['mpIct'] as int?,
      retroTest: json['retroTest'] as int?,
      labName: json['labName'] as String?,
      total: json['total'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'date': date,
      'haemoglobin': haemoglobin,
      'hbsAg': hbsAg,
      'hcvAb': hcvAb,
      'mpIct': mpIct,
      'retroTest': retroTest,
      'labName': labName,
      'total': total,
    };
  }

  SpecialEvent copyWith({
    String? id,
    String? date,
    int? haemoglobin,
    int? hbsAg,
    int? hcvAb,
    int? mpIct,
    int? retroTest,
    String? labName,
    int? total,
  }) {
    return SpecialEvent(
      id: id ?? this.id,
      date: date ?? this.date,
      haemoglobin: haemoglobin ?? this.haemoglobin,
      hbsAg: hbsAg ?? this.hbsAg,
      hcvAb: hcvAb ?? this.hcvAb,
      mpIct: mpIct ?? this.mpIct,
      retroTest: retroTest ?? this.retroTest,
      labName: labName ?? this.labName,
      total: total ?? this.total,
    );
  }
}
