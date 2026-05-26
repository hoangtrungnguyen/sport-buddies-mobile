// Bookings feature — Cubit states.
//
// Three states:
//   BookingsLoading — initial / fetching.
//   BookingsLoaded  — list of upcoming bookings ready.
//   BookingsError   — fetch failed.

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
  const BookingsLoaded(this.bookings);

  final List<Booking> bookings;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingsLoaded &&
          runtimeType == other.runtimeType &&
          _listEquals(bookings, other.bookings);

  @override
  int get hashCode => Object.hashAll(bookings);

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
