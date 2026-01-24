// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'money_donor.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MoneyDonor _$MoneyDonorFromJson(Map<String, dynamic> json) => MoneyDonor(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      note: json['note'] as String?,
      isOrganization: json['is_organization'] as bool?,
      donationCount: (json['donation_count'] as num?)?.toInt(),
      totalAmount: (json['total_amount'] as num?)?.toDouble(),
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$MoneyDonorToJson(MoneyDonor instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'address': instance.address,
      'note': instance.note,
      'is_organization': instance.isOrganization,
      'donation_count': instance.donationCount,
      'total_amount': instance.totalAmount,
      'created_at': instance.createdAt,
    };
