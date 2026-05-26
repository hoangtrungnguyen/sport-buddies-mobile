// Bookings feature — domain models.
//
// These are plain Dart value types constructed from Supabase JSON.
// No code-gen — manual fromJson factory for simplicity.
//
// Supabase join shape expected:
//   bookings.select('*, slots(*, courts(*))')
//
// JSON structure:
//   {
//     "id": "...",
//     "user_id": "...",
//     "status": "confirmed",
//     "slots": {
//       "id": "...",
//       "start_time": "2026-06-15T10:00:00+07:00",
//       "end_time":   "2026-06-15T11:00:00+07:00",
//       "courts": {
//         "id": "...",
//         "name": "Sân A"
//       }
//     }
//   }

import 'package:flutter/foundation.dart';

/// Represents a badminton / sports court.
@immutable
class Court {
  const Court({required this.id, required this.name});

  final String id;
  final String name;

  factory Court.fromJson(Map<String, dynamic> json) {
    return Court(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Court &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => Object.hash(id, name);
}

/// Represents a time slot for a court.
@immutable
class Slot {
  const Slot({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.court,
  });

  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final Court court;

  factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(
      id: json['id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      court: Court.fromJson(json['courts'] as Map<String, dynamic>),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Slot &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          court == other.court;

  @override
  int get hashCode => Object.hash(id, startTime, endTime, court);
}

/// Represents a user booking.
@immutable
class Booking {
  const Booking({
    required this.id,
    required this.userId,
    required this.status,
    required this.slot,
  });

  final String id;
  final String userId;

  /// Booking status: e.g. "confirmed", "pending", "cancelled".
  final String status;
  final Slot slot;

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      status: json['status'] as String,
      slot: Slot.fromJson(json['slots'] as Map<String, dynamic>),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Booking &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          status == other.status &&
          slot == other.slot;

  @override
  int get hashCode => Object.hash(id, userId, status, slot);
}
