// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppNotification _$AppNotificationFromJson(Map<String, dynamic> json) =>
    _AppNotification(
      id: json['id'] as String,
      type: json['type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      text: json['text'] as String? ?? '',
      meta: json['meta'] as String? ?? '',
      isRead: json['is_read'] as bool? ?? false,
      bookingId: json['booking_id'] as String?,
      slotId: json['slot_id'] as String?,
    );

Map<String, dynamic> _$AppNotificationToJson(_AppNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'created_at': instance.createdAt.toIso8601String(),
      'text': instance.text,
      'meta': instance.meta,
      'is_read': instance.isRead,
      'booking_id': instance.bookingId,
      'slot_id': instance.slotId,
    };
