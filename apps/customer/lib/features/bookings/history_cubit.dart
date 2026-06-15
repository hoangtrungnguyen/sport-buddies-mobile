// CAPP-332 — Booking history cubit.
//
// Query: bookings where status IN (completed, cancelled),
// joined with slots and courts, ordered by slots.start_at DESC.

import 'package:customer/core/debug/app_logger.dart';
import 'package:customer/features/bookings/booking_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit(this._client) : super(const HistoryLoading());

  final SupabaseClient _client;

  Future<void> loadHistory() async {
    emit(const HistoryLoading());
    try {
      final userId = _client.auth.currentSession?.user.id;
      if (userId == null) {
        emit(const HistoryError('Vui lòng đăng nhập lại.'));
        return;
      }

      final rows = await _client
          .from('bookings')
          .select(
            'id, status, total_price, '
            'slots!inner(start_at, end_at, courts!inner(id, name, sport_types))',
          )
          .eq('user_id', userId)
          .inFilter('status', ['completed', 'cancelled'])
          .order('start_at', ascending: false, referencedTable: 'slots')
          as List<dynamic>;

      final items = rows.cast<Map<String, dynamic>>().map((row) {
        final slot = row['slots'] as Map<String, dynamic>;
        final court = slot['courts'] as Map<String, dynamic>;
        final sportTypes =
            (court['sport_types'] as List<dynamic>?)?.cast<String>() ?? [];

        return HistoryBookingItem(
          id: row['id'] as String,
          courtId: court['id'] as String,
          courtName: court['name'] as String,
          sport: _parseSport(sportTypes.isNotEmpty ? sportTypes.first : ''),
          startAt: DateTime.parse(slot['start_at'] as String).toLocal(),
          endAt: DateTime.parse(slot['end_at'] as String).toLocal(),
          dbStatus: row['status'] as String,
          totalPrice: (row['total_price'] as num?)?.toDouble(),
        );
      }).toList();

      emit(HistoryLoaded(items));
    } catch (e, st) {
      appLogger.e('HistoryCubit.loadHistory', error: e, stackTrace: st);
      emit(HistoryError(e.toString()));
    }
  }

  static SportType _parseSport(String raw) =>
      switch (raw.toLowerCase().trim()) {
        'football' || 'soccer' || 'bóng đá' => SportType.football,
        'badminton' || 'cầu lông' => SportType.badminton,
        'tennis' => SportType.tennis,
        _ => SportType.pickleball,
      };
}
