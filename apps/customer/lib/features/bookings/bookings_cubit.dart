// Bookings feature — Cubit.
//
// Fetches upcoming bookings for the current authenticated user from Supabase
// and allows cancelling a pending booking.
//
// "Upcoming" = bookings whose slot start_at is in the future AND whose status
// is not completed/cancelled (i.e. pending or confirmed).
//
// Load query:
//   supabase.from('bookings')
//     .select('*, slots!inner(*, courts(*))')
//     .eq('user_id', userId)
//     .inFilter('status', ['pending', 'confirmed'])
//     .gte('slots.start_at', now())
//     .order('slots.start_at')
//
// Cancel query (only for status == 'pending'):
//   supabase.from('bookings')
//     .update({'status': 'cancelled'})
//     .eq('id', bookingId)
//     .eq('status', 'pending')
//
// States emitted:
//   BookingsLoading      — on loadUpcoming() call start
//   BookingsLoaded       — on success (may be empty list)
//   BookingsError        — on any exception
//   BookingsCancelling   — while a cancel request is in-flight

import 'package:customer/core/debug/app_logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'booking_model.dart';
import 'bookings_state.dart';

class BookingsCubit extends Cubit<BookingsState> {
  BookingsCubit(this._client) : super(const BookingsLoading());

  /// Fake constructor for tests — allows starting from an arbitrary initial
  /// state without requiring a real [SupabaseClient].
  BookingsCubit.fake(super.initial) : _client = null;

  // Nullable so the fake constructor can leave it unset.
  final SupabaseClient? _client;

  /// Loads upcoming bookings for the currently authenticated user.
  Future<void> loadUpcoming() async {
    emit(const BookingsLoading());
    try {
      final client = _client;
      if (client == null) {
        // Stub path: used in tests when no real client is provided.
        emit(const BookingsLoaded([]));
        return;
      }

      final userId = client.auth.currentSession?.user.id;
      if (userId == null) {
        emit(const BookingsError('No authenticated user found.'));
        return;
      }

      final now = DateTime.now().toUtc().toIso8601String();

      final response = await client
          .from('bookings')
          .select('*, slots!inner(*, courts(*))')
          .eq('user_id', userId)
          .inFilter('status', ['pending', 'confirmed'])
          .gte('slots.start_at', now)
          .order('start_at', referencedTable: 'slots') as List<dynamic>;

      final bookings = response
          .cast<Map<String, dynamic>>()
          // Filter out bookings where the nested slot join returned null
          // (Supabase returns null for the join key when the filter on the
          // related table excludes all rows).
          .where((json) => json['slots'] != null)
          .map(Booking.fromJson)
          .toList();

      final joinRequests = await _loadJoinRequests(client, userId);

      emit(BookingsLoaded(bookings, joinRequests: joinRequests));
    } catch (e, st) {
      emit(BookingsError(e.toString(), stackTrace: st));
    }
  }

  /// Loads the player's play-together join requests (any status) for the
  /// pending tab. Best-effort: a failure here returns an empty list rather
  /// than failing the whole bookings load.
  Future<List<JoinedSlotRequest>> _loadJoinRequests(
    SupabaseClient client,
    String userId,
  ) async {
    try {
      final response = await client
          .from('slot_join_requests')
          .select('id, status, requested_at, slots!inner(*, courts(*))')
          .eq('user_id', userId)
          .order('requested_at', ascending: false) as List<dynamic>;

      return response
          .cast<Map<String, dynamic>>()
          .where((json) => json['slots'] != null)
          .map(JoinedSlotRequest.fromJson)
          .toList();
    } catch (e, st) {
      appLogger.w('BookingsCubit._loadJoinRequests failed',
          error: e, stackTrace: st);
      return const [];
    }
  }

  /// Updates the status filter applied to the loaded bookings.
  ///
  /// [status] — the booking status string to filter by (e.g. `'pending'`,
  /// `'confirmed'`, `'completed'`, `'cancelled'`). Pass `null` to clear the
  /// filter and show all bookings (the "All" chip).
  ///
  /// Does nothing if the current state is not [BookingsLoaded].
  void filterByStatus(String? status) {
    final current = state;
    if (current is BookingsLoaded) {
      emit(current.copyWithFilter(status));
    }
  }

  /// Cancels a booking by [bookingId].
  ///
  /// Only acts on bookings whose current state in the loaded list has
  /// status == 'pending'. If the booking is not pending (or not found in the
  /// current state), this method is a no-op.
  ///
  /// On success the upcoming-bookings list is reloaded.
  /// On failure [BookingsError] is emitted with the exception message.
  Future<void> cancelBooking(String bookingId) async {
    final currentState = state;
    if (currentState is BookingsLoaded) {
      final match = currentState.bookings
          .where((b) => b.id == bookingId)
          .firstOrNull;
      if (match == null || match.status != 'pending') return;
    }

    emit(BookingsCancelling(bookingId));

    try {
      final client = _client;
      if (client == null) {
        await loadUpcoming();
        return;
      }

      await client
          .from('bookings')
          .update({'status': 'cancelled'})
          .eq('id', bookingId)
          .eq('status', 'pending');

      await loadUpcoming();
    } catch (e, st) {
      emit(BookingsError(e.toString(), stackTrace: st));
    }
  }
}
