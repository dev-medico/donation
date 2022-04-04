// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remark.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Remark _$RemarkFromJson(Map<String, dynamic> json) => Remark(
      id: json['id'] as int?,
      remark: json['remark'] as String?,
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$RemarkToJson(Remark instance) => <String, dynamic>{
      'id': instance.id,
      'remark': instance.remark,
      'created_at': instance.createdAt,
    };
