// Bookings feature — Cubit states.
//
// States:
//   BookingsLoading     — initial / fetching.
//   BookingsLoaded      — list of upcoming bookings ready. Carries optional
//                         [selectedStatus] filter (null = "All").
//   BookingsError       — fetch or cancel failed.
//   BookingsCancelling  — a cancel request is in-flight for a specific booking.

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
  const BookingsLoaded(this.bookings, {this.selectedStatus});

  /// The full unfiltered list of bookings.
  final List<Booking> bookings;

  /// Currently selected status filter. `null` means "All" (no filter).
  final String? selectedStatus;

  /// Returns the bookings that match [selectedStatus]. When [selectedStatus]
  /// is null all bookings are returned (i.e. the "All" chip is active).
  List<Booking> get filteredBookings {
    if (selectedStatus == null) return bookings;
    return bookings.where((b) => b.status == selectedStatus).toList();
  }

  /// Returns a copy of this state with an updated [selectedStatus].
  BookingsLoaded copyWithFilter(String? status) =>
      BookingsLoaded(bookings, selectedStatus: status);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingsLoaded &&
          runtimeType == other.runtimeType &&
          selectedStatus == other.selectedStatus &&
          _listEquals(bookings, other.bookings);

  @override
  int get hashCode => Object.hash(Object.hashAll(bookings), selectedStatus);

  static bool _listEquals(List<Booking> a, List<Booking> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Emitted when fetching upcoming bookings fails.
class BookingsError extends BookingsState {
  const BookingsError(this.message);

  final String message;

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
