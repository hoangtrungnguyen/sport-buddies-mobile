// Booking detail feature — Cubit states.
//
// Three states:
//   BookingDetailLoading — initial / fetching.
//   BookingDetailLoaded  — booking details + join requests loaded.
//   BookingDetailError   — fetch failed.

import 'package:flutter/foundation.dart';

import 'booking_model.dart';

/// A join request from a user wanting to participate in a slot.
@immutable
class JoinRequest {
  const JoinRequest({
    required this.id,
    required this.slotId,
    required this.userId,
    required this.status,
    required this.userName,
    required this.avatarUrl,
    required this.createdAt,
  });

  final String id;
  final String slotId;
  final String userId;

  /// Request status: e.g. "pending", "approved", "rejected".
  final String status;
  final String userName;
  final String? avatarUrl;
  final String createdAt;

  factory JoinRequest.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    return JoinRequest(
      id: json['id'] as String,
      slotId: json['slot_id'] as String,
      userId: json['user_id'] as String,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
      userName: profile?['full_name'] as String? ?? '',
      avatarUrl: profile?['avatar_url'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JoinRequest &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          slotId == other.slotId &&
          userId == other.userId &&
          status == other.status &&
          userName == other.userName &&
          avatarUrl == other.avatarUrl &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      Object.hash(id, slotId, userId, status, userName, avatarUrl, createdAt);
}

/// Base class for all booking detail states.
@immutable
sealed class BookingDetailState {
  const BookingDetailState();
}

/// Emitted while booking details are being fetched.
class BookingDetailLoading extends BookingDetailState {
  const BookingDetailLoading();
}

/// Emitted when booking detail and join requests have been loaded.
class BookingDetailLoaded extends BookingDetailState {
  const BookingDetailLoaded({
    required this.booking,
    required this.joinRequests,
  });

  /// The booking, or null if only join requests context is needed.
  final Booking? booking;
  final List<JoinRequest> joinRequests;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingDetailLoaded &&
          runtimeType == other.runtimeType &&
          booking == other.booking &&
          _listEquals(joinRequests, other.joinRequests);

  @override
  int get hashCode => Object.hash(booking, Object.hashAll(joinRequests));

  static bool _listEquals(List<JoinRequest> a, List<JoinRequest> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Emitted when fetching booking details fails.
class BookingDetailError extends BookingDetailState {
  const BookingDetailError(this.message);

  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingDetailError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}
