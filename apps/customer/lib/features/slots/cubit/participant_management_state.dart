import 'package:flutter/material.dart';

// ── Data classes ───────────────────────────────────────────────────────────────

class SlotSummary {
  const SlotSummary({
    required this.courtName,
    required this.sportType,
    required this.startTime,
    required this.endTime,
  });

  final String courtName;
  final String sportType;
  final DateTime startTime;
  final DateTime endTime;
}

class SlotParticipant {
  const SlotParticipant({
    required this.id,
    required this.name,
    required this.avatarColor,
    required this.initials,
    this.subtitle,
    this.isHost = false,
  });

  final String id;
  final String name;
  final Color avatarColor;
  final String initials;
  final String? subtitle;
  final bool isHost;
}

class JoinRequest {
  const JoinRequest({
    required this.id,
    required this.name,
    required this.avatarColor,
    required this.initials,
    required this.rating,
    required this.gamesPlayed,
    required this.timeAgo,
    this.note,
  });

  final String id;
  final String name;
  final Color avatarColor;
  final String initials;
  final double rating;
  final int gamesPlayed;
  final String timeAgo;
  final String? note;
}

// ── States ─────────────────────────────────────────────────────────────────────

sealed class ParticipantManagementState {}

final class ParticipantManagementLoading extends ParticipantManagementState {}

final class ParticipantManagementError extends ParticipantManagementState {
  ParticipantManagementError(this.message);
  final String message;
}

final class ParticipantManagementLoaded extends ParticipantManagementState {
  ParticipantManagementLoaded({
    required this.confirmed,
    required this.pending,
    required this.maxPlayers,
    required this.slot,
    this.toastMessage,
    this.toastDanger = false,
  });

  final List<SlotParticipant> confirmed;
  final List<JoinRequest> pending;
  final int maxPlayers;
  final SlotSummary slot;
  final String? toastMessage;
  final bool toastDanger;

  ParticipantManagementLoaded copyWith({
    List<SlotParticipant>? confirmed,
    List<JoinRequest>? pending,
    int? maxPlayers,
    SlotSummary? slot,
    Object? toastMessage = _sentinel,
    bool? toastDanger,
  }) {
    return ParticipantManagementLoaded(
      confirmed: confirmed ?? this.confirmed,
      pending: pending ?? this.pending,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      slot: slot ?? this.slot,
      toastMessage: toastMessage == _sentinel
          ? this.toastMessage
          : toastMessage as String?,
      toastDanger: toastDanger ?? this.toastDanger,
    );
  }
}

// Sentinel value for copyWith nullable fields.
const Object _sentinel = Object();
