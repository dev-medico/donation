import 'package:json_annotation/json_annotation.dart';

import 'datum.dart';

part 'township_response.g.dart';

@JsonSerializable()
class TownshipResponse {
  List<Datum>? data;

  TownshipResponse({this.data});

  factory TownshipResponse.fromJson(Map<String, dynamic> json) {
    return _$TownshipResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$TownshipResponseToJson(this);
}
