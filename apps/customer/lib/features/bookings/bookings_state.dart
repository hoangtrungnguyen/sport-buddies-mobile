// Bookings feature — Cubit states.
//
// States:
//   BookingsLoading     — initial / fetching.
//   BookingsLoaded      — list of upcoming bookings ready. Carries optional
//                         [selectedStatus] filter (null = "All").
//   BookingsError       — fetch or cancel failed.
//   BookingsCancelling  — a cancel request is in-flight for a specific booking.

import 'package:customer/core/mixins/app_exception_mixin.dart';
import 'package:flutter/foundation.dart';

import 'booking_model.dart';

/// Base class for all bookings states.
@immutable
sealed class BookingsState {
  const BookingsState();
}

/// Emitted while upcoming bookings are being fetched.
class BookingsLoading extends BookingsState {
  const BookingsLoading();
}

/// Emitted when the upcoming bookings list has been successfully loaded.
class BookingsLoaded extends BookingsState {
  const BookingsLoaded(
    this.bookings, {
    this.selectedStatus,
    this.joinRequests = const [],
  });

  /// The full unfiltered list of bookings.
  final List<Booking> bookings;

  /// The player's play-together join requests (any status). Shown in the
  /// pending tab alongside pending bookings.
  final List<JoinedSlotRequest> joinRequests;

  /// Currently selected status filter. `null` means "All" (no filter).
  final String? selectedStatus;

  /// Returns the bookings that match [selectedStatus]. When [selectedStatus]
  /// is null all bookings are returned (i.e. the "All" chip is active).
  List<Booking> get filteredBookings {
    if (selectedStatus == null) return bookings;
    return bookings.where((b) => b.status == selectedStatus).toList();
  }

  /// Returns a copy of this state with an updated [selectedStatus].
  BookingsLoaded copyWithFilter(String? status) => BookingsLoaded(
    bookings,
    selectedStatus: status,
    joinRequests: joinRequests,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingsLoaded &&
          runtimeType == other.runtimeType &&
          selectedStatus == other.selectedStatus &&
          _listEquals(bookings, other.bookings) &&
          _listEquals(joinRequests, other.joinRequests);

  @override
  int get hashCode => Object.hash(
    Object.hashAll(bookings),
    Object.hashAll(joinRequests),
    selectedStatus,
  );

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Emitted when fetching upcoming bookings fails.
class BookingsError extends BookingsState with AppExceptionMixin {
  const BookingsError(this.message, {this.stackTrace});

  @override
  final String message;
  @override
  final StackTrace? stackTrace;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingsError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

/// Emitted while a cancel request is in-flight for [bookingId].
class BookingsCancelling extends BookingsState {
  const BookingsCancelling(this.bookingId);

  final String bookingId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingsCancelling &&
          runtimeType == other.runtimeType &&
          bookingId == other.bookingId;

  @override
  int get hashCode => bookingId.hashCode;
}
