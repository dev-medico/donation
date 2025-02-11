// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'addresses.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Addresses _$AddressesFromJson(Map<String, dynamic> json) => Addresses(
      address: json['address'],
      addressMm: json['address_mm'] as String?,
      no: json['no'],
      noMm: json['no_mm'] as String?,
      street: json['street'],
      streetMm: json['street_mm'] as String?,
      floor: json['floor'],
      ward: json['ward'],
      wardMm: json['ward_mm'] as String?,
      housing: json['housing'],
      town: json['town'],
      township: (json['township'] as num?)?.toInt(),
      region: (json['region'] as num?)?.toInt(),
      addressesDefault: json['default'] as bool?,
    );

Map<String, dynamic> _$AddressesToJson(Addresses instance) => <String, dynamic>{
      'address': instance.address,
      'address_mm': instance.addressMm,
      'no': instance.no,
      'no_mm': instance.noMm,
      'street': instance.street,
      'street_mm': instance.streetMm,
      'floor': instance.floor,
      'ward': instance.ward,
      'ward_mm': instance.wardMm,
      'housing': instance.housing,
      'town': instance.town,
      'township': instance.township,
      'region': instance.region,
      'default': instance.addressesDefault,
    };
