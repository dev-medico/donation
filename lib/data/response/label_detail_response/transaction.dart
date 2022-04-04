import 'package:json_annotation/json_annotation.dart';

part 'transaction.g.dart';

@JsonSerializable()
class Transaction {
  @JsonKey(name: 'branch_en')
  String? branchEn;
  @JsonKey(name: 'branch_mm')
  String? branchMm;
  @JsonKey(name: 'title_en')
  String? titleEn;
  @JsonKey(name: 'title_mm')
  String? titleMm;
  String? date;
  @JsonKey(name: 'action_at')
  String? actionAt;
  String? type;

  Transaction({
    this.branchEn,
    this.branchMm,
    this.titleEn,
    this.titleMm,
    this.date,
    this.actionAt,
    this.type,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return _$TransactionFromJson(json);
  }

  Map<String, dynamic> toJson() => _$TransactionToJson(this);
}
