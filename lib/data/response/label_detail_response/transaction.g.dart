// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) => Transaction(
      branchEn: json['branch_en'] as String?,
      branchMm: json['branch_mm'] as String?,
      titleEn: json['title_en'] as String?,
      titleMm: json['title_mm'] as String?,
      date: json['date'] as String?,
      actionAt: json['action_at'] as String?,
      type: json['type'] as String?,
    );

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'branch_en': instance.branchEn,
      'branch_mm': instance.branchMm,
      'title_en': instance.titleEn,
      'title_mm': instance.titleMm,
      'date': instance.date,
      'action_at': instance.actionAt,
      'type': instance.type,
    };
