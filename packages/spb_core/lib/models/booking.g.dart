// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Booking _$BookingFromJson(Map<String, dynamic> json) => _Booking(
      id: json['id'] as String,
      code: json['code'] as String?,
      userId: json['user_id'] as String?,
      status: json['status'] as String? ?? 'pending',
      accessPolicy: json['access_policy'] as String? ?? 'private',
      courtId: json['court_id'] as String?,
      courtName: json['court_name'] as String?,
      venueName: json['venue_name'] as String?,
      sportType: json['sport_type'] as String?,
      slots: (json['slots'] as List<dynamic>?)
              ?.map((e) => Slot.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Slot>[],
      totalPrice: (json['total_price'] as num?)?.toInt() ?? 0,
      maxPlayers: (json['max_players'] as num?)?.toInt() ?? 1,
      customerName: json['customer_name'] as String?,
      customerPhone: json['customer_phone'] as String?,
      note: json['note'] as String?,
      bookingType: json['booking_type'] as String? ?? 'oneOff',
      sessionNumber: (json['session_number'] as num?)?.toInt(),
      totalSessions: (json['total_sessions'] as num?)?.toInt(),
      isAutoApproved: json['is_auto_approved'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      confirmedAt: json['confirmed_at'] == null
          ? null
          : DateTime.parse(json['confirmed_at'] as String),
    );

Map<String, dynamic> _$BookingToJson(_Booking instance) => <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'user_id': instance.userId,
      'status': instance.status,
      'access_policy': instance.accessPolicy,
      'court_id': instance.courtId,
      'court_name': instance.courtName,
      'venue_name': instance.venueName,
      'sport_type': instance.sportType,
      'slots': instance.slots,
      'total_price': instance.totalPrice,
      'max_players': instance.maxPlayers,
      'customer_name': instance.customerName,
      'customer_phone': instance.customerPhone,
      'note': instance.note,
      'booking_type': instance.bookingType,
      'session_number': instance.sessionNumber,
      'total_sessions': instance.totalSessions,
      'is_auto_approved': instance.isAutoApproved,
      'created_at': instance.createdAt?.toIso8601String(),
      'confirmed_at': instance.confirmedAt?.toIso8601String(),
    };
