import 'package:json_annotation/json_annotation.dart';

import 'label_data.dart';
import 'point.dart';
import 'transaction.dart';

part 'label_detail_response.g.dart';

@JsonSerializable()
class LabelDetailResponse {
  List<Point>? points;
  List<Transaction>? transactions;
  @JsonKey(name: 'label_data')
  LabelData? labelData;

  LabelDetailResponse({this.points, this.transactions, this.labelData});

  factory LabelDetailResponse.fromJson(Map<String, dynamic> json) {
    return _$LabelDetailResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$LabelDetailResponseToJson(this);
}
