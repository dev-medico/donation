import 'package:json_annotation/json_annotation.dart';

import 'addresses.dart';
import 'role.dart';
import 'service_code.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  int? id;
  String? hash;
  Role? role;
  bool? owner;
  bool? banned;
  String? name;
  List<String>? phones;
  dynamic email;
  String? nrc;
  @JsonKey(name: 'nrc_front')
  dynamic nrcFront;
  @JsonKey(name: 'nrc_back')
  dynamic nrcBack;
  @JsonKey(name: 'service_branch')
  dynamic serviceBranch;
  @JsonKey(name: 'business_name')
  String? businessName;
  @JsonKey(name: 'business_phones')
  List<String>? businessPhones;
  @JsonKey(name: 'company_type')
  dynamic companyType;
  @JsonKey(name: 'service_type')
  String? serviceType;
  @JsonKey(name: 'company_name')
  String? companyName;
  @JsonKey(name: 'donation_id')
  String? donationId;
  @JsonKey(name: 'license_type')
  String? licenseType;
  @JsonKey(name: 'license_no')
  dynamic licenseNo;
  @JsonKey(name: 'license_expire_date')
  dynamic licenseExpireDate;
  @JsonKey(name: 'license_issue_township')
  dynamic licenseIssueTownship;
  @JsonKey(name: 'license_front')
  dynamic licenseFront;
  @JsonKey(name: 'license_certificate')
  dynamic licenseCertificate;
  @JsonKey(name: 'payment_type')
  String? paymentType;
  @JsonKey(name: 'kbz_bank_holder')
  dynamic kbzBankHolder;
  @JsonKey(name: 'kbz_bank')
  dynamic kbzBank;
  @JsonKey(name: 'aya_bank_holder')
  dynamic ayaBankHolder;
  @JsonKey(name: 'aya_bank')
  dynamic ayaBank;
  @JsonKey(name: 'cb_bank_holder')
  dynamic cbBankHolder;
  @JsonKey(name: 'cb_bank')
  dynamic cbBank;
  Addresses? addresses;
  @JsonKey(name: 'co_person_name')
  dynamic coPersonName;
  @JsonKey(name: 'co_person_nrc')
  dynamic coPersonNrc;
  @JsonKey(name: 'co_person_phones')
  List<dynamic>? coPersonPhones;
  @JsonKey(name: 'service_code')
  ServiceCode? serviceCode;
  @JsonKey(name: 'service_class')
  String? serviceClass;
  String? deposit;
  String? expense;
  @JsonKey(name: 'created_at')
  String? createdAt;
  @JsonKey(name: 'business_created_at')
  String? businessCreatedAt;

  User({
    this.id,
    this.hash,
    this.role,
    this.owner,
    this.banned,
    this.name,
    this.phones,
    this.email,
    this.nrc,
    this.nrcFront,
    this.nrcBack,
    this.serviceBranch,
    this.businessName,
    this.businessPhones,
    this.companyType,
    this.serviceType,
    this.companyName,
    this.donationId,
    this.licenseType,
    this.licenseNo,
    this.licenseExpireDate,
    this.licenseIssueTownship,
    this.licenseFront,
    this.licenseCertificate,
    this.paymentType,
    this.kbzBankHolder,
    this.kbzBank,
    this.ayaBankHolder,
    this.ayaBank,
    this.cbBankHolder,
    this.cbBank,
    this.addresses,
    this.coPersonName,
    this.coPersonNrc,
    this.coPersonPhones,
    this.serviceCode,
    this.serviceClass,
    this.deposit,
    this.expense,
    this.createdAt,
    this.businessCreatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
