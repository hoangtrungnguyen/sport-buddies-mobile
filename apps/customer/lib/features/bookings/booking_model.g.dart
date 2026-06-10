// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Court _$CourtFromJson(Map<String, dynamic> json) => _Court(
  id: json['id'] as String,
  name: json['name'] as String,
  sportTypes:
      (json['sport_types'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
);

Map<String, dynamic> _$CourtToJson(_Court instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'sport_types': instance.sportTypes,
};

_Slot _$SlotFromJson(Map<String, dynamic> json) => _Slot(
  id: json['id'] as String,
  startTime: DateTime.parse(json['start_at'] as String),
  endTime: DateTime.parse(json['end_at'] as String),
  court: Court.fromJson(json['courts'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SlotToJson(_Slot instance) => <String, dynamic>{
  'id': instance.id,
  'start_at': instance.startTime.toIso8601String(),
  'end_at': instance.endTime.toIso8601String(),
  'courts': instance.court,
};

_Booking _$BookingFromJson(Map<String, dynamic> json) => _Booking(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  status: json['status'] as String,
  slot: Slot.fromJson(json['slots'] as Map<String, dynamic>),
  bookingType: json['booking_type'] as String? ?? 'one_off',
  sessionNumber: (json['session_number'] as num?)?.toInt(),
  totalSessions: (json['total_sessions'] as num?)?.toInt(),
  totalPrice: (json['total_price'] as num?)?.toDouble(),
);

Map<String, dynamic> _$BookingToJson(_Booking instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'status': instance.status,
  'slots': instance.slot,
  'booking_type': instance.bookingType,
  'session_number': instance.sessionNumber,
  'total_sessions': instance.totalSessions,
  'total_price': instance.totalPrice,
};

_JoinedSlotRequest _$JoinedSlotRequestFromJson(Map<String, dynamic> json) =>
    _JoinedSlotRequest(
      id: json['id'] as String,
      status: json['status'] as String,
      slot: Slot.fromJson(json['slots'] as Map<String, dynamic>),
      requestedAt: json['requested_at'] == null
          ? null
          : DateTime.parse(json['requested_at'] as String),
    );

Map<String, dynamic> _$JoinedSlotRequestToJson(_JoinedSlotRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'slots': instance.slot,
      'requested_at': instance.requestedAt?.toIso8601String(),
    };
