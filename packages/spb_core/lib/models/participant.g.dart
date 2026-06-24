// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Participant _$ParticipantFromJson(Map<String, dynamic> json) => _Participant(
      id: json['id'] as String,
      name: json['name'] as String,
      userId: json['user_id'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isHost: json['is_host'] as bool? ?? false,
      bookingStatus: json['booking_status'] as String? ?? 'confirmed',
      paymentStatus: json['payment_status'] as String? ?? 'unknown',
      paymentMethod: json['payment_method'] as String?,
      expectedPrice: (json['expected_price'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ParticipantToJson(_Participant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'user_id': instance.userId,
      'avatar_url': instance.avatarUrl,
      'is_host': instance.isHost,
      'booking_status': instance.bookingStatus,
      'payment_status': instance.paymentStatus,
      'payment_method': instance.paymentMethod,
      'expected_price': instance.expectedPrice,
    };

_JoinRequest _$JoinRequestFromJson(Map<String, dynamic> json) => _JoinRequest(
      id: json['id'] as String,
      slotId: json['slot_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      status: json['status'] as String? ?? 'pending',
      note: json['note'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$JoinRequestToJson(_JoinRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slot_id': instance.slotId,
      'user_id': instance.userId,
      'user_name': instance.userName,
      'avatar_url': instance.avatarUrl,
      'status': instance.status,
      'note': instance.note,
      'created_at': instance.createdAt?.toIso8601String(),
    };
