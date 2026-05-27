// Booking detail feature — Cubit.
//
// Fetches a booking and its associated slot join requests from Supabase.
//
// Queries:
//   Booking detail:
//     supabase.from('bookings')
//       .select('*, slots(*, courts(*))')
//       .eq('id', bookingId)
//       .single()
//
//   Join requests:
//     supabase.from('slot_join_requests')
//       .select('*, profiles(*)')
//       .eq('slot_id', slotId)
//       .order('created_at')
//
// States emitted:
//   BookingDetailLoading  — on initial load
//   BookingDetailLoaded   — on success (joinRequests may be empty)
//   BookingDetailError    — on any exception

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'booking_model.dart';
import 'booking_detail_state.dart';

class BookingDetailCubit extends Cubit<BookingDetailState> {
  BookingDetailCubit(this._client) : super(const BookingDetailLoading());

  /// Fake constructor for tests — allows starting from an arbitrary initial
  /// state without requiring a real [SupabaseClient].
  BookingDetailCubit.fake(super.initial) : _client = null;

  // Nullable so the fake constructor can leave it unset.
  final SupabaseClient? _client;

  /// Loads the booking detail for [bookingId] and its slot's join requests.
  Future<void> loadBookingDetail(String bookingId) async {
    emit(const BookingDetailLoading());
    try {
      final client = _client;
      if (client == null) {
        emit(const BookingDetailLoaded(booking: null, joinRequests: []));
        return;
      }

      final bookingJson = await client
          .from('bookings')
          .select('*, slots(*, courts(*))')
          .eq('id', bookingId)
          .single();

      final booking = Booking.fromJson(bookingJson);
      final slotId = booking.slot.id;

      await loadJoinRequests(slotId, existingBooking: booking);
    } catch (e, st) {
      emit(BookingDetailError(e.toString(), stackTrace: st));
    }
  }

  /// Loads join requests for [slotId].
  ///
  /// When called independently (without [existingBooking]), the current
  /// booking in state is preserved if already loaded.
  Future<void> loadJoinRequests(
    String slotId, {
    Booking? existingBooking,
  }) async {
    // Preserve existing booking from loaded state if not provided.
    final currentBooking = existingBooking ??
        (state is BookingDetailLoaded
            ? (state as BookingDetailLoaded).booking
            : null);

    if (existingBooking == null) {
      emit(const BookingDetailLoading());
    }

    try {
      final client = _client;
      if (client == null) {
        emit(BookingDetailLoaded(
          booking: currentBooking,
          joinRequests: const [],
        ));
        return;
      }

      final response = await client
          .from('slot_join_requests')
          .select('*, profiles(*)')
          .eq('slot_id', slotId)
          .order('created_at') as List<dynamic>;

      final requests = response
          .cast<Map<String, dynamic>>()
          .map(JoinRequest.fromJson)
          .toList();

      emit(BookingDetailLoaded(
        booking: currentBooking,
        joinRequests: requests,
      ));
    } catch (e, st) {
      emit(BookingDetailError(e.toString(), stackTrace: st));
    }
  }
}
