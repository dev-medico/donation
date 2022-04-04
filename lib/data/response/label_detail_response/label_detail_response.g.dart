// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'label_detail_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LabelDetailResponse _$LabelDetailResponseFromJson(Map<String, dynamic> json) =>
    LabelDetailResponse(
      points: (json['points'] as List<dynamic>?)
          ?.map((e) => Point.fromJson(e as Map<String, dynamic>))
          .toList(),
      transactions: (json['transactions'] as List<dynamic>?)
          ?.map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      labelData: json['label_data'] == null
          ? null
          : LabelData.fromJson(json['label_data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LabelDetailResponseToJson(
        LabelDetailResponse instance) =>
    <String, dynamic>{
      'points': instance.points,
      'transactions': instance.transactions,
      'label_data': instance.labelData,
    };
