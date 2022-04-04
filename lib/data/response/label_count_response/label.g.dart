// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'label.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Label _$LabelFromJson(Map<String, dynamic> json) => Label(
      pending: json['pending'] as int?,
      complete: json['complete'] as int?,
      process: json['process'] as int?,
      ongoingReturn: json['ongoing_return'] as int?,
      returnLabel: json['return_label'] as int?,
      totalCount: json['total_count'] as int?,
    );

Map<String, dynamic> _$LabelToJson(Label instance) => <String, dynamic>{
      'pending': instance.pending,
      'complete': instance.complete,
      'process': instance.process,
      'ongoing_return': instance.ongoingReturn,
      'return_label': instance.returnLabel,
      'total_count': instance.totalCount,
    };
