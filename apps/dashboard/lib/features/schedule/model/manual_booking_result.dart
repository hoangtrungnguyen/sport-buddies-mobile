/// One-shot outcome of a manual walk-in booking (OWNER-23 confirm/cancel flow).
///
/// Carried transiently on [ScheduleLoaded.bookingResult]: the bloc sets it when
/// the `POST /api/bookings/manual` call resolves, the compose dialog reacts to
/// it (navigate-on-success / show-error-on-reject), then dispatches
/// `ScheduleEvent.bookingResultCleared` so it never re-fires.
///
/// Intentionally uses identity equality (no value `==`): each booking attempt
/// emits a fresh instance, which is exactly the "changed → react once" signal
/// the dialog's `listenWhen` needs.
sealed class ManualBookingResult {
  const ManualBookingResult();
}

/// The booking was confirmed by the backend. Carries enough to navigate the
/// schedule to the new entry ("today's list") and name it in the confirmation.
class ManualBookingSucceeded extends ManualBookingResult {
  const ManualBookingSucceeded({
    required this.startAt,
    required this.endAt,
    this.customerName,
  });

  /// Local start instant of the confirmed booking.
  final DateTime startAt;

  /// Local end instant of the confirmed booking.
  final DateTime endAt;

  /// Optional customer name, for the success confirmation copy.
  final String? customerName;
}

/// The backend rejected the booking (overlap, invalid input, …). [message] is
/// already localized for direct display in the dialog's inline error banner.
class ManualBookingFailed extends ManualBookingResult {
  const ManualBookingFailed(this.message);

  /// Localized, user-facing failure reason.
  final String message;
}
