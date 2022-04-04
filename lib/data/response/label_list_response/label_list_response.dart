import 'package:json_annotation/json_annotation.dart';

import 'datum.dart';
import 'meta.dart';

part 'label_list_response.g.dart';

@JsonSerializable()
class LabelListResponse {
  List<Datum>? data;
  Meta? meta;

  LabelListResponse({this.data, this.meta});

  factory LabelListResponse.fromJson(Map<String, dynamic> json) {
    return _$LabelListResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$LabelListResponseToJson(this);
}
