import 'package:json_annotation/json_annotation.dart';

import 'destination_township.dart';

part 'datum.g.dart';

@JsonSerializable()
class Datum {
  int? id;
  @JsonKey(name: 'tracking_code')
  String? trackingCode;
  @JsonKey(name: 'tp_tracking_code')
  String? tpTrackingCode;
  @JsonKey(name: 'include_products')
  String? includeProducts;
  @JsonKey(name: 'destination_name')
  String? destinationName;
  @JsonKey(name: 'destination_phone')
  List<String>? destinationPhone;
  @JsonKey(name: 'destination_township')
  DestinationTownship? destinationTownship;
  String? status;
  @JsonKey(name: 'created_date')
  String? createdDate;
  @JsonKey(name: 'services_fee')
  int? servicesFee;

  Datum({
    this.id,
    this.trackingCode,
    this.tpTrackingCode,
    this.includeProducts,
    this.destinationName,
    this.destinationPhone,
    this.destinationTownship,
    this.status,
    this.createdDate,
    this.servicesFee,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => _$DatumFromJson(json);

  Map<String, dynamic> toJson() => _$DatumToJson(this);
}
