import 'package:donation/src/features/donation_member/domain/member.dart';

class Donation {
  final String id;
  final String? member;
  final DateTime? donationDate;
  final String? hospital;
  final String? patientName;
  final String? patientAddress;
  final String? patientAge;
  final String? patientDisease;
  final String? location;
  final String? remark;
  final String? createdAt;
  final String? updatedAt;
  final String? memberId;
  final Member? memberObj;
  final String? date;
  final String ownerId;

  Donation({
    required this.id,
    this.member,
    this.donationDate,
    this.hospital,
    this.patientName,
    this.patientAddress,
    this.patientAge,
    this.patientDisease,
    this.location,
    this.remark,
    this.createdAt,
    this.updatedAt,
    this.memberId,
    this.memberObj,
    this.date,
    this.ownerId = '',
  });

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'] ?? json['_id'] ?? '',
      member: json['member'] as String?,
      donationDate: json['donationDate'] != null
          ? DateTime.parse(json['donationDate'])
          : null,
      hospital: json['hospital'] as String?,
      patientName: json['patientName'] as String?,
      patientAddress: json['patientAddress'] as String?,
      patientAge: json['patientAge'] as String?,
      patientDisease: json['patientDisease'] as String?,
      location: json['location'] as String?,
      remark: json['remark'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      memberId: json['memberId'] as String?,
      memberObj: json['memberObj'] != null
          ? Member.fromJson(json['memberObj'] as Map<String, dynamic>)
          : null,
      date: json['date'] as String?,
      ownerId: json['owner_id'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'member': member,
      'donationDate': donationDate?.toIso8601String(),
      'hospital': hospital,
      'patientName': patientName,
      'patientAddress': patientAddress,
      'patientAge': patientAge,
      'patientDisease': patientDisease,
      'location': location,
      'remark': remark,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'memberId': memberId,
      'memberObj': memberObj?.toJson(),
      'date': date,
      'owner_id': ownerId,
    };
  }

  Donation copyWith({
    String? id,
    String? member,
    DateTime? donationDate,
    String? hospital,
    String? patientName,
    String? patientAddress,
    String? patientAge,
    String? patientDisease,
    String? location,
    String? remark,
    String? createdAt,
    String? updatedAt,
    String? memberId,
    Member? memberObj,
    String? date,
    String? ownerId,
  }) {
    return Donation(
      id: id ?? this.id,
      member: member ?? this.member,
      donationDate: donationDate ?? this.donationDate,
      hospital: hospital ?? this.hospital,
      patientName: patientName ?? this.patientName,
      patientAddress: patientAddress ?? this.patientAddress,
      patientAge: patientAge ?? this.patientAge,
      patientDisease: patientDisease ?? this.patientDisease,
      location: location ?? this.location,
      remark: remark ?? this.remark,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      memberId: memberId ?? this.memberId,
      memberObj: memberObj ?? this.memberObj,
      date: date ?? this.date,
      ownerId: ownerId ?? this.ownerId,
    );
  }
}
