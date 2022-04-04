import 'package:json_annotation/json_annotation.dart';

part 'point.g.dart';

@JsonSerializable()
class Point {
  String? label;
  String? title;
  @JsonKey(name: 'current_point')
  bool? currentPoint;
  bool? done;
  String? date;
  String? branch;

  Point({
    this.label,
    this.title,
    this.currentPoint,
    this.done,
    this.date,
    this.branch,
  });

  factory Point.fromJson(Map<String, dynamic> json) => _$PointFromJson(json);

  Map<String, dynamic> toJson() => _$PointToJson(this);
}
