import 'package:dashboard/core/debug/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Predictable failure of an owner action (approve/reject/undo). [code] is a
/// stable key; the bloc maps any throw to a localized failure snackbar.
class BookingActionException implements Exception {
  const BookingActionException(this.code);

  /// e.g. `not_pending` (the guarded transition matched no row — the booking
  /// already moved on) or `network`.
  final String code;

  @override
  String toString() => 'BookingActionException($code)';
}

/// Write contract for owner actions on a booking request: approve, reject, and
/// undo (OWNER-28/29). An interface so the bloc can be driven by an in-memory
/// fake in tests; the concrete impl talks to Supabase.
abstract interface class BookingActionRepository {
  /// Approve a pending request: `bookings.status → confirmed`. Throws
  /// [BookingActionException] if the row was no longer pending.
  Future<void> approve({required String bookingId});

  /// Reject a pending request: `bookings.status → cancelled`. The slot is freed
  /// **server-side** (see class doc). [reason] is the optional owner note.
  /// Throws [BookingActionException] if the row was no longer pending.
  Future<void> reject({required String bookingId, String? reason});

  /// Revert a just-approved/rejected request back to pending within the grace
  /// period (the "Hoàn tác" undo): `bookings.status → pending` and, when
  /// [slotId] is known, re-book a slot that the reject had freed.
  Future<void> restorePending({required String bookingId, String? slotId});
}

/// Supabase-backed [BookingActionRepository].
///
/// Booking status transitions are written directly to Supabase, mirroring the
/// verified customer cancel path (`apps/customer/.../bookings_cubit.dart` does
/// `from('bookings').update({'status': 'cancelled'})`). Owner authorization is
/// enforced by RLS (the owner may only mutate bookings/slots on `courts.owner_id
/// = auth.uid()`), not by these queries.
///
/// **Slots are driven by a DB trigger, not by us.** The backend installs
/// `trg_sync_slot_status_from_booking` (snb-backend-core migration 0017): on a
/// booking INSERT the slot becomes `booked`; on a booking UPDATE → `cancelled`
/// the slot returns to `open` (when it was `booked`). The valid `slots.status`
/// vocabulary is `open | booked | blocked | maintenance` — there is **no**
/// `pending`/`confirmed` slot status. Consequences for each action:
/// - **approve** (→ confirmed): the trigger has no →confirmed branch, but a
///   pending booking already maps to a `booked` slot, so the slot is already
///   correct — no slot write.
/// - **reject** (→ cancelled): the trigger frees the slot (`booked` → `open`),
///   so we do NOT write the slot ourselves (avoids a redundant race and keeps
///   the cancel atomic server-side).
/// - **undo** (→ pending): the trigger has **no** →pending branch, so a slot the
///   reject freed stays `open`. We therefore re-book it explicitly, guarded on
///   `open` so an approve-undo (slot still `booked`) is a no-op and a slot that
///   another booking has since taken is never clobbered.
///
/// Remaining backend follow-up: the player in-app notification (OWNER-28/29) is
/// expected from a trigger/backend on the status change; the dashboard cannot
/// write another user's notification under RLS, so [reason] is forwarded for
/// when that path is wired rather than persisted to an unverified column.
class SupabaseBookingActionRepository implements BookingActionRepository {
  const SupabaseBookingActionRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<void> approve({required String bookingId}) async {
    try {
      await _guardedBookingUpdate(
        bookingId: bookingId,
        to: _BookingStatus.confirmed,
        from: _BookingStatus.pending,
      );
    } catch (e, st) {
      appLogger.e('BookingActionRepository.approve', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> reject({required String bookingId, String? reason}) async {
    try {
      await _guardedBookingUpdate(
        bookingId: bookingId,
        to: _BookingStatus.cancelled,
        from: _BookingStatus.pending,
      );
      // Slot is freed by the DB trigger (booked → open); no explicit slot write.
    } catch (e, st) {
      appLogger.e('BookingActionRepository.reject', error: e, stackTrace: st);
      rethrow;
    }
  }

  @override
  Future<void> restorePending({
    required String bookingId,
    String? slotId,
  }) async {
    try {
      await _client
          .from('bookings')
          .update({'status': _BookingStatus.pending})
          .eq('id', bookingId);
      if (slotId != null) {
        // Re-book only a slot the reject actually freed; a no-op when the slot is
        // still `booked` (approve-undo) or has been taken by another booking.
        await _client
            .from('slots')
            .update({'status': _SlotStatus.booked})
            .eq('id', slotId)
            .eq('status', _SlotStatus.open);
      }
    } catch (e, st) {
      appLogger.e('BookingActionRepository.restorePending',
          error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Updates `bookings.status` from [from] to [to] for [bookingId], returning
  /// the affected rows; throws [BookingActionException] when none matched (the
  /// guard failed — the row already moved on, or RLS hid it) so the caller never
  /// flips the UI on a silent no-op.
  Future<void> _guardedBookingUpdate({
    required String bookingId,
    required String to,
    required String from,
  }) async {
    final rows = await _client
        .from('bookings')
        .update({'status': to})
        .eq('id', bookingId)
        .eq('status', from)
        .select('id');
    if ((rows as List).isEmpty) {
      throw const BookingActionException('not_pending');
    }
  }
}

/// `bookings.status` literals (matches [BookingStatus] mapping + the customer
/// cancel path).
abstract final class _BookingStatus {
  static const String pending = 'pending';
  static const String confirmed = 'confirmed';
  static const String cancelled = 'cancelled';
}

/// `slots.status` literals — a distinct vocabulary from bookings
/// (`open | booked | blocked | maintenance`; never `pending`/`confirmed`).
abstract final class _SlotStatus {
  static const String open = 'open';
  static const String booked = 'booked';
}
