// Booking History feature — Cubit.
//
// Fetches past (completed/cancelled) bookings for the current authenticated
// user from Supabase.
//
// Query:
//   supabase.from('bookings')
//     .select('*, slots!inner(*, courts(*))')
//     .eq('user_id', userId)
//     .inFilter('status', ['completed', 'cancelled'])
//     .order('start_at', ascending: false, referencedTable: 'slots')
//
// States emitted:
//   BookingsLoading  — on loadHistory() call start
//   BookingsLoaded   — on success (may be empty list)
//   BookingsError    — on any exception

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'booking_model.dart';
import 'bookings_state.dart';

class BookingHistoryCubit extends Cubit<BookingsState> {
  BookingHistoryCubit(this._client) : super(const BookingsLoading());

  /// Fake constructor for tests — allows starting from an arbitrary initial
  /// state without requiring a real [SupabaseClient].
  BookingHistoryCubit.fake(super.initial) : _client = null;

  // Nullable so the fake constructor can leave it unset.
  final SupabaseClient? _client;

  /// Loads past (completed/cancelled) bookings for the currently
  /// authenticated user, ordered by start time descending.
  Future<void> loadHistory() async {
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

      final response = await client
          .from('bookings')
          .select('*, slots!inner(*, courts(*))')
          .eq('user_id', userId)
          .inFilter('status', ['completed', 'cancelled'])
          .order('start_at', ascending: false, referencedTable: 'slots')
          as List<dynamic>;

      final bookings = response
          .cast<Map<String, dynamic>>()
          // Filter out rows where the nested slot join returned null.
          .where((json) => json['slots'] != null)
          .map(Booking.fromJson)
          .toList();

      emit(BookingsLoaded(bookings));
    } catch (e, st) {
      emit(BookingsError(e.toString(), stackTrace: st));
    }
  }
}
