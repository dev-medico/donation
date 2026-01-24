import 'package:json_annotation/json_annotation.dart';

part 'patient.g.dart';

@JsonSerializable()
class Patient {
  final int? id;
  final String? name;
  final String? phone;
  final String? address;
  final String? age;
  final String? gender;
  @JsonKey(name: 'medical_notes')
  final String? medicalNotes;
  @JsonKey(name: 'donation_count')
  final int? donationCount;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  Patient({
    this.id,
    this.name,
    this.phone,
    this.address,
    this.age,
    this.gender,
    this.medicalNotes,
    this.donationCount,
    this.createdAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) => _$PatientFromJson(json);

  Map<String, dynamic> toJson() => _$PatientToJson(this);
}
