import 'package:customer/core/debug/app_logger.dart';
import 'package:customer/features/booking/state/awaiting_confirmation_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AwaitingConfirmationCubit extends Cubit<AwaitingState> {
  AwaitingConfirmationCubit({required SupabaseClient client})
      : _client = client,
        super(const AwaitingState.initial());

  final SupabaseClient _client;
  RealtimeChannel? _channel;

  Future<void> load(String bookingId) async {
    emit(const AwaitingState.loading());

    try {
      final data = await _client
          .from('bookings')
          .select('id, status, courts!inner(name), slots!inner(id, start_at, end_at)')
          .eq('id', bookingId)
          .single();

      final courtName =
          (data['courts'] as Map<String, dynamic>)['name'] as String;
      final slot = data['slots'] as Map<String, dynamic>;
      final slotId = slot['id'] as String;
      final slotStart = DateTime.parse(slot['start_at'] as String).toLocal();
      final slotEnd = DateTime.parse(slot['end_at'] as String).toLocal();
      final status = data['status'] as String;

      emit(AwaitingState.loaded(
        bookingId: bookingId,
        slotId: slotId,
        courtName: courtName,
        slotStart: slotStart,
        slotEnd: slotEnd,
        status: status,
      ));

      _subscribeRealtime(bookingId, slotId);
    } catch (e, st) {
      appLogger.e('AwaitingConfirmationCubit.load', error: e, stackTrace: st);
      emit(AwaitingState.error(e.toString(), stackTrace: st));
    }
  }

  void _subscribeRealtime(String bookingId, String slotId) {
    _channel?.unsubscribe();
    _channel = _client
        .channel('booking_watch_$bookingId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'bookings',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: bookingId,
          ),
          callback: (payload) {
            final status = payload.newRecord['status'] as String?;
            if (status == 'confirmed') {
              emit(AwaitingState.confirmed(
                bookingId: bookingId,
                slotId: slotId,
              ));
            }
          },
        )
        .subscribe();
  }

  @override
  Future<void> close() {
    _channel?.unsubscribe();
    return super.close();
  }
}
