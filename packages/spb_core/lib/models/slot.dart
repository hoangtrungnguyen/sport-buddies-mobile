import 'package:flutter/foundation.dart';

/// A time slot available for booking at a court.
@immutable
class Slot {
  const Slot({
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

  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final String courtId;
  final String courtName;
  final String sportType;
  final String accessPolicy;
  final int maxPlayers;
  final int currentPlayers;

  bool get isFull => currentPlayers >= maxPlayers;

  factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(
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
      other is Slot &&
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
