import 'package:json_annotation/json_annotation.dart';

import 'remark.dart';

part 'label_data.g.dart';

@JsonSerializable()
class LabelData {
  int? id;
  String? type;
  @JsonKey(name: 'current_state_en')
  String? currentStateEn;
  @JsonKey(name: 'current_state_mm')
  String? currentStateMm;
  @JsonKey(name: 'tracking_code')
  String? trackingCode;
  @JsonKey(name: 'service_type')
  String? serviceType;
  @JsonKey(name: 'item_type')
  String? itemType;
  String? weight;
  @JsonKey(name: 'shipping_fee')
  int? shippingFee;
  @JsonKey(name: 'claim_amount')
  int? claimAmount;
  @JsonKey(name: 'purchase_type')
  String? purchaseType;
  List<Remark>? remarks;
  @JsonKey(name: 'created_at')
  String? createdAt;
  @JsonKey(name: 'source_name')
  String? sourceName;
  @JsonKey(name: 'source_phone')
  List<String>? sourcePhone;
  @JsonKey(name: 'source_address')
  String? sourceAddress;
  @JsonKey(name: 'destination_name')
  String? destinationName;
  @JsonKey(name: 'destination_phone')
  List<String>? destinationPhone;
  @JsonKey(name: 'destination_address')
  String? destinationAddress;

  LabelData({
    this.id,
    this.type,
    this.currentStateEn,
    this.currentStateMm,
    this.trackingCode,
    this.serviceType,
    this.itemType,
    this.weight,
    this.shippingFee,
    this.claimAmount,
    this.purchaseType,
    this.remarks,
    this.createdAt,
    this.sourceName,
    this.sourcePhone,
    this.sourceAddress,
    this.destinationName,
    this.destinationPhone,
    this.destinationAddress,
  });

  factory LabelData.fromJson(Map<String, dynamic> json) {
    return _$LabelDataFromJson(json);
  }

  Map<String, dynamic> toJson() => _$LabelDataToJson(this);
}
