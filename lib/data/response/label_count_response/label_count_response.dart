import 'package:json_annotation/json_annotation.dart';

import 'label.dart';

part 'label_count_response.g.dart';

@JsonSerializable()
class LabelCountResponse {
  int? expense;
  int? receivable;
  @JsonKey(name: 'cod_paid')
  int? codPaid;
  Label? label;

  LabelCountResponse({
    this.expense,
    this.receivable,
    this.codPaid,
    this.label,
  });

  factory LabelCountResponse.fromJson(Map<String, dynamic> json) {
    return _$LabelCountResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$LabelCountResponseToJson(this);
}
