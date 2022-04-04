import 'package:json_annotation/json_annotation.dart';

part 'addresses.g.dart';

@JsonSerializable()
class Addresses {
  dynamic address;
  @JsonKey(name: 'address_mm')
  String? addressMm;
  dynamic no;
  @JsonKey(name: 'no_mm')
  String? noMm;
  dynamic street;
  @JsonKey(name: 'street_mm')
  String? streetMm;
  dynamic floor;
  dynamic ward;
  @JsonKey(name: 'ward_mm')
  String? wardMm;
  dynamic housing;
  dynamic town;
  int? township;
  int? region;
  @JsonKey(name: 'default')
  bool? addressesDefault;

  Addresses({
    this.address,
    this.addressMm,
    this.no,
    this.noMm,
    this.street,
    this.streetMm,
    this.floor,
    this.ward,
    this.wardMm,
    this.housing,
    this.town,
    this.township,
    this.region,
    this.addressesDefault,
  });

  factory Addresses.fromJson(Map<String, dynamic> json) {
    return _$AddressesFromJson(json);
  }

  Map<String, dynamic> toJson() => _$AddressesToJson(this);
}
