import 'package:json_annotation/json_annotation.dart';

part 'destination_township.g.dart';

@JsonSerializable()
class DestinationTownship {
  int? id;
  @JsonKey(name: 'name_en')
  String? nameEn;
  @JsonKey(name: 'name_mm')
  String? nameMm;

  DestinationTownship({this.id, this.nameEn, this.nameMm});

  factory DestinationTownship.fromJson(Map<String, dynamic> json) {
    return _$DestinationTownshipFromJson(json);
  }

  Map<String, dynamic> toJson() => _$DestinationTownshipToJson(this);
}
