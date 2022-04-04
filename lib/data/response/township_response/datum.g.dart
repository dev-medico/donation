// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'datum.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Datum _$DatumFromJson(Map<String, dynamic> json) => Datum(
      region: json['region'] as String?,
      regionEn: json['region_en'] as String?,
      town: json['town'] as String?,
      townEn: json['town_en'] as String?,
      township: json['township'] as String?,
      townshipEn: json['township_en'] as String?,
    );

Map<String, dynamic> _$DatumToJson(Datum instance) => <String, dynamic>{
      'region': instance.region,
      'region_en': instance.regionEn,
      'town': instance.town,
      'town_en': instance.townEn,
      'township': instance.township,
      'township_en': instance.townshipEn,
    };
