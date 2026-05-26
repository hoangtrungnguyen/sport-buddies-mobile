// Bookings feature — Cubit.
//
// Fetches upcoming bookings for the current authenticated user from Supabase
// and allows cancelling a pending booking.
//
// Load query:
//   supabase.from('bookings')
//     .select('*, slots(*, courts(*))')
//     .eq('user_id', userId)
//     .gte('slots.start_time', now())
//     .order('slots.start_time')
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

      final now = DateTime.now().toIso8601String();

      final response = await client
          .from('bookings')
          .select('*, slots(*, courts(*))')
          .eq('user_id', userId)
          .gte('slots.start_time', now)
          .order('slots.start_time', referencedTable: 'slots') as List<dynamic>;

      final bookings = response
          .cast<Map<String, dynamic>>()
          // Filter out bookings where the nested slot join returned null
          // (Supabase returns null for the join key when the filter on the
          // related table excludes all rows).
          .where((json) => json['slots'] != null)
          .map(Booking.fromJson)
          .toList();

      emit(BookingsLoaded(bookings));
    } catch (e) {
      emit(BookingsError(e.toString()));
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
    } catch (e) {
      emit(BookingsError(e.toString()));
    }
  }
}
