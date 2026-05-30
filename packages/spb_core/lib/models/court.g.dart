// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'court.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Court _$CourtFromJson(Map<String, dynamic> json) => _Court(
      id: json['id'] as String,
      name: json['name'] as String,
      ownerId: json['owner_id'] as String?,
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      sportTypes: (json['sport_types'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      address: json['address'] as String?,
      pricePerHour: (json['price_per_hour'] as num?)?.toDouble(),
      description: json['description'] as String?,
      amenities: (json['amenities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$CourtToJson(_Court instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'owner_id': instance.ownerId,
      'lat': instance.lat,
      'lng': instance.lng,
      'sport_types': instance.sportTypes,
      'address': instance.address,
      'price_per_hour': instance.pricePerHour,
      'description': instance.description,
      'amenities': instance.amenities,
      'photos': instance.photos,
    };
