// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'label_count_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LabelCountResponse _$LabelCountResponseFromJson(Map<String, dynamic> json) =>
    LabelCountResponse(
      expense: json['expense'] as int?,
      receivable: json['receivable'] as int?,
      codPaid: json['cod_paid'] as int?,
      label: json['label'] == null
          ? null
          : Label.fromJson(json['label'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LabelCountResponseToJson(LabelCountResponse instance) =>
    <String, dynamic>{
      'expense': instance.expense,
      'receivable': instance.receivable,
      'cod_paid': instance.codPaid,
      'label': instance.label,
    };
