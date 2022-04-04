// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as int?,
      hash: json['hash'] as String?,
      role: json['role'] == null
          ? null
          : Role.fromJson(json['role'] as Map<String, dynamic>),
      owner: json['owner'] as bool?,
      banned: json['banned'] as bool?,
      name: json['name'] as String?,
      phones:
          (json['phones'] as List<dynamic>?)?.map((e) => e as String).toList(),
      email: json['email'],
      nrc: json['nrc'] as String?,
      nrcFront: json['nrc_front'],
      nrcBack: json['nrc_back'],
      serviceBranch: json['service_branch'],
      businessName: json['business_name'] as String?,
      businessPhones: (json['business_phones'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      companyType: json['company_type'],
      serviceType: json['service_type'] as String?,
      companyName: json['company_name'] as String?,
      merchantId: json['merchant_id'] as String?,
      licenseType: json['license_type'] as String?,
      licenseNo: json['license_no'],
      licenseExpireDate: json['license_expire_date'],
      licenseIssueTownship: json['license_issue_township'],
      licenseFront: json['license_front'],
      licenseCertificate: json['license_certificate'],
      paymentType: json['payment_type'] as String?,
      kbzBankHolder: json['kbz_bank_holder'],
      kbzBank: json['kbz_bank'],
      ayaBankHolder: json['aya_bank_holder'],
      ayaBank: json['aya_bank'],
      cbBankHolder: json['cb_bank_holder'],
      cbBank: json['cb_bank'],
      addresses: json['addresses'] == null
          ? null
          : Addresses.fromJson(json['addresses'] as Map<String, dynamic>),
      coPersonName: json['co_person_name'],
      coPersonNrc: json['co_person_nrc'],
      coPersonPhones: json['co_person_phones'] as List<dynamic>?,
      serviceCode: json['service_code'] == null
          ? null
          : ServiceCode.fromJson(json['service_code'] as Map<String, dynamic>),
      serviceClass: json['service_class'] as String?,
      deposit: json['deposit'] as String?,
      expense: json['expense'] as String?,
      createdAt: json['created_at'] as String?,
      businessCreatedAt: json['business_created_at'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'hash': instance.hash,
      'role': instance.role,
      'owner': instance.owner,
      'banned': instance.banned,
      'name': instance.name,
      'phones': instance.phones,
      'email': instance.email,
      'nrc': instance.nrc,
      'nrc_front': instance.nrcFront,
      'nrc_back': instance.nrcBack,
      'service_branch': instance.serviceBranch,
      'business_name': instance.businessName,
      'business_phones': instance.businessPhones,
      'company_type': instance.companyType,
      'service_type': instance.serviceType,
      'company_name': instance.companyName,
      'merchant_id': instance.merchantId,
      'license_type': instance.licenseType,
      'license_no': instance.licenseNo,
      'license_expire_date': instance.licenseExpireDate,
      'license_issue_township': instance.licenseIssueTownship,
      'license_front': instance.licenseFront,
      'license_certificate': instance.licenseCertificate,
      'payment_type': instance.paymentType,
      'kbz_bank_holder': instance.kbzBankHolder,
      'kbz_bank': instance.kbzBank,
      'aya_bank_holder': instance.ayaBankHolder,
      'aya_bank': instance.ayaBank,
      'cb_bank_holder': instance.cbBankHolder,
      'cb_bank': instance.cbBank,
      'addresses': instance.addresses,
      'co_person_name': instance.coPersonName,
      'co_person_nrc': instance.coPersonNrc,
      'co_person_phones': instance.coPersonPhones,
      'service_code': instance.serviceCode,
      'service_class': instance.serviceClass,
      'deposit': instance.deposit,
      'expense': instance.expense,
      'created_at': instance.createdAt,
      'business_created_at': instance.businessCreatedAt,
    };
