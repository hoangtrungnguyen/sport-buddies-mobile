import 'package:customer/core/mixins/app_exception_mixin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'awaiting_confirmation_state.dart';

class AwaitingConfirmationCubit extends Cubit<AwaitingState> {
  AwaitingConfirmationCubit({required SupabaseClient client})
      : _client = client,
        super(const AwaitingInitial());

  final SupabaseClient _client;
  RealtimeChannel? _channel;

  Future<void> load(String bookingId) async {
    emit(const AwaitingLoading());

    try {
      final data = await _client
          .from('bookings')
          .select('id, status, courts!inner(name), slots!inner(start_at, end_at)')
          .eq('id', bookingId)
          .single();

      final courtName =
          (data['courts'] as Map<String, dynamic>)['name'] as String;
      final slot = data['slots'] as Map<String, dynamic>;
      final slotStart = DateTime.parse(slot['start_at'] as String).toLocal();
      final slotEnd = DateTime.parse(slot['end_at'] as String).toLocal();
      final status = data['status'] as String;

      emit(AwaitingLoaded(
        bookingId: bookingId,
        courtName: courtName,
        slotStart: slotStart,
        slotEnd: slotEnd,
        status: status,
      ));

      _subscribeRealtime(bookingId);
    } catch (e, st) {
      emit(AwaitingError(e.toString(), stackTrace: st));
    }
  }

  void _subscribeRealtime(String bookingId) {
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
              emit(AwaitingConfirmed(bookingId: bookingId));
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
