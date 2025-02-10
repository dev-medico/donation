import 'package:json_annotation/json_annotation.dart';

class Member {
  final String id;
  final String? birthDate;
  final String? bloodBankCard;
  final String? bloodType;
  final String? fatherName;
  final DateTime? lastDate;
  final String? memberCount;
  final String? memberId;
  final String? name;
  final String? note;
  final String? nrc;
  final String? phone;
  final String? address;
  final String? gender;
  final String? profileUrl;
  final DateTime? registerDate;
  final String? totalCount;
  final String? status;
  final String ownerId;

  Member({
    required this.id,
    this.birthDate,
    this.bloodBankCard,
    this.bloodType,
    this.fatherName,
    this.lastDate,
    this.memberCount,
    this.memberId,
    this.name,
    this.note,
    this.nrc,
    this.phone,
    this.address,
    this.gender,
    this.profileUrl,
    this.registerDate,
    this.totalCount,
    this.status,
    required this.ownerId,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['_id'] as String,
      birthDate: json['birthDate'] as String?,
      bloodBankCard: json['bloodBankCard'] as String?,
      bloodType: json['bloodType'] as String?,
      fatherName: json['fatherName'] as String?,
      lastDate:
          json['lastDate'] != null ? DateTime.parse(json['lastDate']) : null,
      memberCount: json['memberCount'] as String?,
      memberId: json['memberId'] as String?,
      name: json['name'] as String?,
      note: json['note'] as String?,
      nrc: json['nrc'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      gender: json['gender'] as String?,
      profileUrl: json['profileUrl'] as String?,
      registerDate: json['registerDate'] != null
          ? DateTime.parse(json['registerDate'])
          : null,
      totalCount: json['totalCount'] as String?,
      status: json['status'] as String?,
      ownerId: json['owner_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'birthDate': birthDate,
      'bloodBankCard': bloodBankCard,
      'bloodType': bloodType,
      'fatherName': fatherName,
      'lastDate': lastDate?.toIso8601String(),
      'memberCount': memberCount,
      'memberId': memberId,
      'name': name,
      'note': note,
      'nrc': nrc,
      'phone': phone,
      'address': address,
      'gender': gender,
      'profileUrl': profileUrl,
      'registerDate': registerDate?.toIso8601String(),
      'totalCount': totalCount,
      'status': status,
      'owner_id': ownerId,
    };
  }

  Member copyWith({
    String? id,
    String? birthDate,
    String? bloodBankCard,
    String? bloodType,
    String? fatherName,
    DateTime? lastDate,
    String? memberCount,
    String? memberId,
    String? name,
    String? note,
    String? nrc,
    String? phone,
    String? address,
    String? gender,
    String? profileUrl,
    DateTime? registerDate,
    String? totalCount,
    String? status,
    String? ownerId,
  }) {
    return Member(
      id: id ?? this.id,
      birthDate: birthDate ?? this.birthDate,
      bloodBankCard: bloodBankCard ?? this.bloodBankCard,
      bloodType: bloodType ?? this.bloodType,
      fatherName: fatherName ?? this.fatherName,
      lastDate: lastDate ?? this.lastDate,
      memberCount: memberCount ?? this.memberCount,
      memberId: memberId ?? this.memberId,
      name: name ?? this.name,
      note: note ?? this.note,
      nrc: nrc ?? this.nrc,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      profileUrl: profileUrl ?? this.profileUrl,
      registerDate: registerDate ?? this.registerDate,
      totalCount: totalCount ?? this.totalCount,
      status: status ?? this.status,
      ownerId: ownerId ?? this.ownerId,
    );
  }
}
