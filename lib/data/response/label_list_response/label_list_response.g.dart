// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'label_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LabelListResponse _$LabelListResponseFromJson(Map<String, dynamic> json) =>
    LabelListResponse(
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => Datum.fromJson(e as Map<String, dynamic>))
          .toList(),
      meta: json['meta'] == null
          ? null
          : Meta.fromJson(json['meta'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LabelListResponseToJson(LabelListResponse instance) =>
    <String, dynamic>{
      'data': instance.data,
      'meta': instance.meta,
    };
