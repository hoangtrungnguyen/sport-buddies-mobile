// OpenSlot — grava-c9ca.5.2.
//
// Represents a time slot that is available for booking.
// An open slot has not yet been booked by any user.

import 'package:flutter/foundation.dart';

/// An open (available) time slot for a court.
///
/// Open slots are displayed to users for booking. Once a user books
/// a slot, it becomes a [Booking] and is no longer "open".
@immutable
class OpenSlot {
  const OpenSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.courtId,
    required this.courtName,
    required this.sportType,
    this.accessPolicy = 'open',
    this.maxPlayers = 4,
    this.currentPlayers = 0,
  });

  /// Unique identifier for this slot.
  final String id;

  /// When the slot starts.
  final DateTime startTime;

  /// When the slot ends.
  final DateTime endTime;

  /// ID of the court this slot belongs to.
  final String courtId;

  /// Display name of the court (e.g., "Sân A").
  final String courtName;

  /// Type of sport this court is for (e.g., "badminton", "football").
  final String sportType;

  /// Access policy: "open" for public play, "closed" for private groups.
  final String accessPolicy;

  /// Maximum number of players allowed in this slot.
  final int maxPlayers;

  /// Current number of players who have joined this slot.
  final int currentPlayers;

  /// Whether this slot is full (no more players can join).
  bool get isFull => currentPlayers >= maxPlayers;

  /// Constructs an [OpenSlot] from Supabase JSON.
  ///
  /// Expected JSON shape:
  /// ```json
  /// {
  ///   "id": "...",
  ///   "start_time": "2026-06-15T10:00:00+07:00",
  ///   "end_time": "2026-06-15T11:00:00+07:00",
  ///   "court_id": "...",
  ///   "court_name": "Sân A",
  ///   "sport_type": "badminton",
  ///   "access_policy": "open",
  ///   "max_players": 4,
  ///   "current_players": 2
  /// }
  /// ```
  factory OpenSlot.fromJson(Map<String, dynamic> json) {
    return OpenSlot(
      id: json['id'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      courtId: json['court_id'] as String,
      courtName: json['court_name'] as String,
      sportType: json['sport_type'] as String? ?? 'badminton',
      accessPolicy: json['access_policy'] as String? ?? 'open',
      maxPlayers: json['max_players'] as int? ?? 4,
      currentPlayers: json['current_players'] as int? ?? 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OpenSlot &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          startTime == other.startTime &&
          endTime == other.endTime &&
          courtId == other.courtId &&
          courtName == other.courtName &&
          sportType == other.sportType &&
          accessPolicy == other.accessPolicy &&
          maxPlayers == other.maxPlayers &&
          currentPlayers == other.currentPlayers;

  @override
  int get hashCode =>
      Object.hash(id, startTime, endTime, courtId, courtName, sportType,
          accessPolicy, maxPlayers, currentPlayers);
}
