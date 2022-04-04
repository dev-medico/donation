// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'township_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TownshipResponse _$TownshipResponseFromJson(Map<String, dynamic> json) =>
    TownshipResponse(
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => Datum.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TownshipResponseToJson(TownshipResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
    };
