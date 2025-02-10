import 'package:donation/models/member.dart';

class Donation {
  final String id;
  final String? date;
  final DateTime? donationDate;
  final String? hospital;
  final String? memberId;
  final Member? memberObj;
  final String? patientAddress;
  final String? patientAge;
  final String? patientDisease;
  final String? patientName;
  final String ownerId;

  Donation({
    required this.id,
    this.date,
    this.donationDate,
    this.hospital,
    this.memberId,
    this.memberObj,
    this.patientAddress,
    this.patientAge,
    this.patientDisease,
    this.patientName,
    required this.ownerId,
  });

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['_id'] as String,
      date: json['date'] as String?,
      donationDate: json['donationDate'] != null
          ? DateTime.parse(json['donationDate'])
          : null,
      hospital: json['hospital'] as String?,
      memberId: json['memberId'] as String?,
      memberObj: json['memberObj'] != null
          ? Member.fromJson(json['memberObj'] as Map<String, dynamic>)
          : null,
      patientAddress: json['patientAddress'] as String?,
      patientAge: json['patientAge'] as String?,
      patientDisease: json['patientDisease'] as String?,
      patientName: json['patientName'] as String?,
      ownerId: json['owner_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'date': date,
      'donationDate': donationDate?.toIso8601String(),
      'hospital': hospital,
      'memberId': memberId,
      'memberObj': memberObj?.toJson(),
      'patientAddress': patientAddress,
      'patientAge': patientAge,
      'patientDisease': patientDisease,
      'patientName': patientName,
      'owner_id': ownerId,
    };
  }

  Donation copyWith({
    String? id,
    String? date,
    DateTime? donationDate,
    String? hospital,
    String? memberId,
    Member? memberObj,
    String? patientAddress,
    String? patientAge,
    String? patientDisease,
    String? patientName,
    String? ownerId,
  }) {
    return Donation(
      id: id ?? this.id,
      date: date ?? this.date,
      donationDate: donationDate ?? this.donationDate,
      hospital: hospital ?? this.hospital,
      memberId: memberId ?? this.memberId,
      memberObj: memberObj ?? this.memberObj,
      patientAddress: patientAddress ?? this.patientAddress,
      patientAge: patientAge ?? this.patientAge,
      patientDisease: patientDisease ?? this.patientDisease,
      patientName: patientName ?? this.patientName,
      ownerId: ownerId ?? this.ownerId,
    );
  }
}
