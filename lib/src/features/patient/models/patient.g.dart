// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Patient _$PatientFromJson(Map<String, dynamic> json) => Patient(
      patientName: json['patient_name'] as String?,
      patientAge: json['patient_age'] as String?,
      patientAddress: json['patient_address'] as String?,
      patientDisease: json['patient_disease'] as String?,
      hospital: json['hospital'] as String?,
      bloodGroup: json['blood_group'] as String?,
      latestId: json['latest_id'] as int?,
      latestDonationDate: json['latest_donation_date'] as String?,
      donationCount: json['donation_count'] as int?,
    );

Map<String, dynamic> _$PatientToJson(Patient instance) => <String, dynamic>{
      'patient_name': instance.patientName,
      'patient_age': instance.patientAge,
      'patient_address': instance.patientAddress,
      'patient_disease': instance.patientDisease,
      'hospital': instance.hospital,
      'blood_group': instance.bloodGroup,
      'latest_id': instance.latestId,
      'latest_donation_date': instance.latestDonationDate,
      'donation_count': instance.donationCount,
    };