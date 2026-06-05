// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Slot _$SlotFromJson(Map<String, dynamic> json) => _Slot(
      id: json['id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      courtId: json['court_id'] as String,
      courtName: json['court_name'] as String,
      sportType: json['sport_type'] as String,
      accessPolicy: json['access_policy'] as String? ?? 'open',
      maxPlayers: (json['max_players'] as num?)?.toInt() ?? 4,
      currentPlayers: (json['current_players'] as num?)?.toInt() ?? 0,
      hostId: json['host_id'] as String?,
    );

Map<String, dynamic> _$SlotToJson(_Slot instance) => <String, dynamic>{
      'id': instance.id,
      'start_time': instance.startTime.toIso8601String(),
      'end_time': instance.endTime.toIso8601String(),
      'court_id': instance.courtId,
      'court_name': instance.courtName,
      'sport_type': instance.sportType,
      'access_policy': instance.accessPolicy,
      'max_players': instance.maxPlayers,
      'current_players': instance.currentPlayers,
      'host_id': instance.hostId,
    };
