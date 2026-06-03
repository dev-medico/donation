// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Patient _$PatientFromJson(Map<String, dynamic> json) => Patient(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      township: json['township'] as String?,
      ward: json['ward'] as String?,
      village: json['village'] as String?,
      age: json['age'] as String?,
      birthDate: json['birth_date'] as String?,
      gender: json['gender'] as String?,
      medicalNotes: json['medical_notes'] as String?,
      donationCount: (json['donation_count'] as num?)?.toInt(),
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$PatientToJson(Patient instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'address': instance.address,
      'township': instance.township,
      'ward': instance.ward,
      'village': instance.village,
      'age': instance.age,
      'birth_date': instance.birthDate,
      'gender': instance.gender,
      'medical_notes': instance.medicalNotes,
      'donation_count': instance.donationCount,
      'created_at': instance.createdAt,
    };
