import 'package:customer/core/debug/app_logger.dart';
import 'package:customer/features/booking/state/awaiting_confirmation_state.dart';
import 'package:customer/features/bookings/mock_booking.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AwaitingConfirmationCubit extends Cubit<AwaitingState> {
  AwaitingConfirmationCubit({required SupabaseClient client})
      : _client = client,
        super(const AwaitingState.initial());

  final SupabaseClient _client;

  static final _uuidRe = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  static final _fallbackTime = DateTime.now().add(const Duration(days: 1));
  RealtimeChannel? _channel;

  Future<void> load(String bookingId) async {
    emit(const AwaitingState.loading());

    // TODO: remove mock fallback once booking IDs are real UUIDs from Supabase
    if (!_uuidRe.hasMatch(bookingId)) {
      final all = [...mockUpcomingBookings, ...mockHistoryBookings];
      final mock = all.cast<MockBooking?>().firstWhere(
        (b) => b?.id == bookingId,
        orElse: () => all.isNotEmpty ? all.first : null,
      );
      if (mock != null) {
        final domain = mockBookingToDomain(mock);
        emit(AwaitingState.loaded(
          bookingId: bookingId,
          slotId: domain.slot.id,
          courtName: domain.slot.court.name,
          slotStart: domain.slot.startTime,
          slotEnd: domain.slot.endTime,
          status: domain.status,
        ));
      } else {
        emit(AwaitingState.loaded(
          bookingId: 'mock',
          slotId: 'mock-slot',
          courtName: 'Sân mẫu',
          slotStart: _fallbackTime,
          slotEnd: _fallbackTime,
        ));
      }
      return;
    }

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
