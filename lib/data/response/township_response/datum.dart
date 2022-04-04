import 'package:json_annotation/json_annotation.dart';

part 'datum.g.dart';

@JsonSerializable()
class Datum {
  String? region;
  @JsonKey(name: 'region_en')
  String? regionEn;
  String? town;
  @JsonKey(name: 'town_en')
  String? townEn;
  String? township;
  @JsonKey(name: 'township_en')
  String? townshipEn;

  Datum({
    this.region,
    this.regionEn,
    this.town,
    this.townEn,
    this.township,
    this.townshipEn,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => _$DatumFromJson(json);

  Map<String, dynamic> toJson() => _$DatumToJson(this);
}
