// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'datum.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Datum _$DatumFromJson(Map<String, dynamic> json) => Datum(
      id: json['id'] as int?,
      trackingCode: json['tracking_code'] as String?,
      tpTrackingCode: json['tp_tracking_code'] as String?,
      includeProducts: json['include_products'] as String?,
      destinationName: json['destination_name'] as String?,
      destinationPhone: (json['destination_phone'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      destinationTownship: json['destination_township'] == null
          ? null
          : DestinationTownship.fromJson(
              json['destination_township'] as Map<String, dynamic>),
      status: json['status'] as String?,
      createdDate: json['created_date'] as String?,
      servicesFee: json['services_fee'] as int?,
    );

Map<String, dynamic> _$DatumToJson(Datum instance) => <String, dynamic>{
      'id': instance.id,
      'tracking_code': instance.trackingCode,
      'tp_tracking_code': instance.tpTrackingCode,
      'include_products': instance.includeProducts,
      'destination_name': instance.destinationName,
      'destination_phone': instance.destinationPhone,
      'destination_township': instance.destinationTownship,
      'status': instance.status,
      'created_date': instance.createdDate,
      'services_fee': instance.servicesFee,
    };
