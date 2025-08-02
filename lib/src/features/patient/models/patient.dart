import 'package:json_annotation/json_annotation.dart';

part 'patient.g.dart';

@JsonSerializable()
class Patient {
  @JsonKey(name: 'patient_name')
  final String? patientName;
  
  @JsonKey(name: 'patient_age')
  final String? patientAge;
  
  @JsonKey(name: 'patient_address')
  final String? patientAddress;
  
  @JsonKey(name: 'patient_disease')
  final String? patientDisease;
  
  final String? hospital;
  
  @JsonKey(name: 'blood_group')
  final String? bloodGroup;
  
  @JsonKey(name: 'latest_id')
  final int? latestId;
  
  @JsonKey(name: 'latest_donation_date')
  final String? latestDonationDate;
  
  @JsonKey(name: 'donation_count')
  final int? donationCount;

  Patient({
    this.patientName,
    this.patientAge,
    this.patientAddress,
    this.patientDisease,
    this.hospital,
    this.bloodGroup,
    this.latestId,
    this.latestDonationDate,
    this.donationCount,
  });

  factory Patient.fromJson(Map<String, dynamic> json) => _$PatientFromJson(json);
  Map<String, dynamic> toJson() => _$PatientToJson(this);
}