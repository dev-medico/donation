import 'package:json_annotation/json_annotation.dart';

part 'service_code.g.dart';

@JsonSerializable()
class ServiceCode {
  String? mer;

  ServiceCode({this.mer});

  factory ServiceCode.fromJson(Map<String, dynamic> json) {
    return _$ServiceCodeFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ServiceCodeToJson(this);
}
