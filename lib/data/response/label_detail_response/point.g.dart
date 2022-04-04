// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'point.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Point _$PointFromJson(Map<String, dynamic> json) => Point(
      label: json['label'] as String?,
      title: json['title'] as String?,
      currentPoint: json['current_point'] as bool?,
      done: json['done'] as bool?,
      date: json['date'] as String?,
      branch: json['branch'] as String?,
    );

Map<String, dynamic> _$PointToJson(Point instance) => <String, dynamic>{
      'label': instance.label,
      'title': instance.title,
      'current_point': instance.currentPoint,
      'done': instance.done,
      'date': instance.date,
      'branch': instance.branch,
    };
