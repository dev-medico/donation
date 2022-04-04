import 'package:json_annotation/json_annotation.dart';

part 'remark.g.dart';

@JsonSerializable()
class Remark {
  int? id;
  String? remark;
  @JsonKey(name: 'created_at')
  String? createdAt;

  Remark({this.id, this.remark, this.createdAt});

  factory Remark.fromJson(Map<String, dynamic> json) {
    return _$RemarkFromJson(json);
  }

  Map<String, dynamic> toJson() => _$RemarkToJson(this);
}
