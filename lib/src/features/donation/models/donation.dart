class Donation {
  final String? id;
  final String? memberId;
  final String? memberName;
  final String? bloodType;
  final DateTime? donationDate;
  final String? hospital;
  final String? patientName;
  final String? patientPhone;
  final String? patientAddress;
  final String? remark;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Donation({
    this.id,
    this.memberId,
    this.memberName,
    this.bloodType,
    this.donationDate,
    this.hospital,
    this.patientName,
    this.patientPhone,
    this.patientAddress,
    this.remark,
    this.createdAt,
    this.updatedAt,
  });

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'] as String?,
      memberId: json['member_id'] as String?,
      memberName: json['member_name'] as String?,
      bloodType: json['blood_type'] as String?,
      donationDate: json['donation_date'] != null ? DateTime.parse(json['donation_date']) : null,
      hospital: json['hospital'] as String?,
      patientName: json['patient_name'] as String?,
      patientPhone: json['patient_phone'] as String?,
      patientAddress: json['patient_address'] as String?,
      remark: json['remark'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'member_id': memberId,
      'member_name': memberName,
      'blood_type': bloodType,
      'donation_date': donationDate?.toIso8601String(),
      'hospital': hospital,
      'patient_name': patientName,
      'patient_phone': patientPhone,
      'patient_address': patientAddress,
      'remark': remark,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
} 