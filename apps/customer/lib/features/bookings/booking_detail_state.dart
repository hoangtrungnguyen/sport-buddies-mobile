// Booking detail feature — Cubit states.
//
// Three states:
//   BookingDetailLoading — initial / fetching.
//   BookingDetailLoaded  — booking details + join requests loaded.
//   BookingDetailError   — fetch failed.

import 'package:customer/core/mixins/app_exception_mixin.dart';
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
    final customer = (json['customers'] ?? json['profiles']) as Map<String, dynamic>?;
    return JoinRequest(
      id: json['id'] as String,
      slotId: json['slot_id'] as String,
      userId: json['user_id'] as String,
      status: json['status'] as String,
      createdAt: (json['requested_at'] ?? json['created_at']) as String,
      userName: customer?['full_name'] as String? ?? '',
      avatarUrl: customer?['avatar_url'] as String?,
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
    this.processing = const {},
    this.actionError,
  });

  /// The booking, or null if only join requests context is needed.
  final Booking? booking;
  final List<JoinRequest> joinRequests;

  /// Join-request ids with an approve/reject call in flight (controls
  /// per-row button spinners).
  final Set<String> processing;

  /// Transient error surfaced via snackbar (cleared on next reload).
  final String? actionError;

  BookingDetailLoaded copyWith({
    Set<String>? processing,
    String? actionError,
  }) =>
      BookingDetailLoaded(
        booking: booking,
        joinRequests: joinRequests,
        processing: processing ?? this.processing,
        actionError: actionError,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingDetailLoaded &&
          runtimeType == other.runtimeType &&
          booking == other.booking &&
          actionError == other.actionError &&
          setEquals(processing, other.processing) &&
          _listEquals(joinRequests, other.joinRequests);

  @override
  int get hashCode => Object.hash(
        booking,
        Object.hashAll(joinRequests),
        Object.hashAllUnordered(processing),
        actionError,
      );

  static bool _listEquals(List<JoinRequest> a, List<JoinRequest> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Emitted when fetching booking details fails.
class BookingDetailError extends BookingDetailState with AppExceptionMixin {
  const BookingDetailError(this.message, {this.stackTrace});

  @override
  final String message;
  @override
  final StackTrace? stackTrace;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingDetailError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}
