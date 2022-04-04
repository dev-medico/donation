import 'package:json_annotation/json_annotation.dart';

part 'label.g.dart';

@JsonSerializable()
class Label {
  int? pending;
  int? complete;
  int? process;
  @JsonKey(name: 'ongoing_return')
  int? ongoingReturn;
  @JsonKey(name: 'return_label')
  int? returnLabel;
  @JsonKey(name: 'total_count')
  int? totalCount;

  Label({
    this.pending,
    this.complete,
    this.process,
    this.ongoingReturn,
    this.returnLabel,
    this.totalCount,
  });

  factory Label.fromJson(Map<String, dynamic> json) => _$LabelFromJson(json);

  Map<String, dynamic> toJson() => _$LabelToJson(this);
}
