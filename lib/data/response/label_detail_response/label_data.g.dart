// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'label_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LabelData _$LabelDataFromJson(Map<String, dynamic> json) => LabelData(
      id: json['id'] as int?,
      type: json['type'] as String?,
      currentStateEn: json['current_state_en'] as String?,
      currentStateMm: json['current_state_mm'] as String?,
      trackingCode: json['tracking_code'] as String?,
      serviceType: json['service_type'] as String?,
      itemType: json['item_type'] as String?,
      weight: json['weight'] as String?,
      shippingFee: json['shipping_fee'] as int?,
      claimAmount: json['claim_amount'] as int?,
      purchaseType: json['purchase_type'] as String?,
      remarks: (json['remarks'] as List<dynamic>?)
          ?.map((e) => Remark.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] as String?,
      sourceName: json['source_name'] as String?,
      sourcePhone: (json['source_phone'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      sourceAddress: json['source_address'] as String?,
      destinationName: json['destination_name'] as String?,
      destinationPhone: (json['destination_phone'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      destinationAddress: json['destination_address'] as String?,
    );

Map<String, dynamic> _$LabelDataToJson(LabelData instance) => <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'current_state_en': instance.currentStateEn,
      'current_state_mm': instance.currentStateMm,
      'tracking_code': instance.trackingCode,
      'service_type': instance.serviceType,
      'item_type': instance.itemType,
      'weight': instance.weight,
      'shipping_fee': instance.shippingFee,
      'claim_amount': instance.claimAmount,
      'purchase_type': instance.purchaseType,
      'remarks': instance.remarks,
      'created_at': instance.createdAt,
      'source_name': instance.sourceName,
      'source_phone': instance.sourcePhone,
      'source_address': instance.sourceAddress,
      'destination_name': instance.destinationName,
      'destination_phone': instance.destinationPhone,
      'destination_address': instance.destinationAddress,
    };
