import 'package:json_annotation/json_annotation.dart';

part 'money_donor.g.dart';

@JsonSerializable()
class MoneyDonor {
  final int? id;
  final String? name;
  final String? phone;
  final String? address;
  final String? note;
  @JsonKey(name: 'is_organization')
  final bool? isOrganization;
  @JsonKey(name: 'donation_count')
  final int? donationCount;
  @JsonKey(name: 'total_amount')
  final double? totalAmount;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  MoneyDonor({
    this.id,
    this.name,
    this.phone,
    this.address,
    this.note,
    this.isOrganization,
    this.donationCount,
    this.totalAmount,
    this.createdAt,
  });

  factory MoneyDonor.fromJson(Map<String, dynamic> json) => _$MoneyDonorFromJson(json);

  Map<String, dynamic> toJson() => _$MoneyDonorToJson(this);
}
