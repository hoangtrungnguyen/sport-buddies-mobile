// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owner_court.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_OwnerCourt _$OwnerCourtFromJson(Map<String, dynamic> json) => _OwnerCourt(
      id: json['id'] as String,
      name: json['name'] as String,
      isActive: _activeFromStatus(json['status'] as String?),
      operatingHours: json['operating_hours'] as Map<String, dynamic>?,
      address: json['address'] as String?,
      description: json['description'] as String?,
      amenities: (json['amenities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      autoApproveSingle: json['auto_approve_single'] as bool? ?? false,
      additionalInfo:
          json['additional_info'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$OwnerCourtToJson(_OwnerCourt instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'status': _statusFromActive(instance.isActive),
      'operating_hours': instance.operatingHours,
      'address': instance.address,
      'description': instance.description,
      'amenities': instance.amenities,
      'lat': instance.lat,
      'lng': instance.lng,
      'auto_approve_single': instance.autoApproveSingle,
      'additional_info': instance.additionalInfo,
    };
