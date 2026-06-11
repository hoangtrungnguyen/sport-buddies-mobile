// Booking-wizard repository contract (handoff doc 04 §3/§4).
//
// The UI codes against this interface. The real implementation
// ([ApiBookingRepository]) writes through the core-engine booking API and
// listens for the owner's decision over Supabase Realtime.

import 'package:customer/features/booking/wizard/domain/booking.dart';
import 'package:customer/features/court/domain/booking_draft.dart';

abstract class BookingRepository {
  /// Atomically claims the draft's slot(s) and creates the booking.
  ///
  /// Throws [SlotTakenException] if any slot was claimed since selection,
  /// [BookingFailedException] for any other (recoverable) failure.
  Future<Booking> createBooking({
    required BookingDraft draft,
    required ContactInfo contact,
    required AccessPolicy access,
    required int maxPlayers,
  });

  /// Realtime status stream for one booking. Emits whenever the row's status
  /// changes; the wizard advances on [BookingStatus.confirmed] and shows the
  /// decline state on a terminal-negative status.
  Stream<Booking> watchBooking(Booking booking);
}

/// A slot lost the race — claimed by someone else since selection. Drives the
/// "Slot vừa được đặt" toast + pop-to-picker path (doc 03 §3.4).
class SlotTakenException implements Exception {
  const SlotTakenException(this.takenSlotIds);

  final List<String> takenSlotIds;

  @override
  String toString() => 'SlotTakenException($takenSlotIds)';
}

/// Generic recoverable failure (network/timeout/server) — stay on Step 2 and
/// offer retry (doc 03 §3.5). No booking was created.
class BookingFailedException implements Exception {
  const BookingFailedException([this.message]);

  final String? message;

  @override
  String toString() => 'BookingFailedException(${message ?? ''})';
}
