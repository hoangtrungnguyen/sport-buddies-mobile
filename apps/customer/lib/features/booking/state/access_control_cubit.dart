import 'package:customer/core/debug/app_logger.dart';
import 'package:customer/features/booking/state/access_control_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccessControlCubit extends Cubit<AccessControlState> {
  AccessControlCubit({required SupabaseClient client})
      : _client = client,
        super(const AccessControlState.idle());

  final SupabaseClient _client;

  Future<void> submitAndSave({
    required String slotId,
    required String name,
    required String phone,
    String? notes,
    required String courtId,
    double? pricePerHour,
    required int durationMinutes,
    double? totalPrice,
    required String policy,
    required int maxPlayers,
  }) async {
    emit(const AccessControlState.saving());

    final userId = _client.auth.currentSession?.user.id;
    if (userId == null) {
      emit(const AccessControlState.failure('Vui lòng đăng nhập lại.'));
      return;
    }

    try {
      final bookingId = await _client.rpc('place_booking', params: {
        'p_slot_id': slotId,
        'p_user_id': userId,
        'p_court_id': courtId,
        'p_customer_name': name,
        'p_customer_phone': phone,
        if (notes != null) 'p_notes': notes,
        if (pricePerHour != null) 'p_price_per_hour': pricePerHour,
        'p_duration_minutes': durationMinutes,
        if (totalPrice != null) 'p_total_price': totalPrice,
      }) as String;

      if (policy == 'open') {
        await _client.from('slots').update({
          'access_policy': policy,
          'max_players': maxPlayers,
        }).eq('id', slotId);
      }

      emit(AccessControlState.saved(bookingId: bookingId));
    } catch (e, st) {
      final msg = e.toString();
      appLogger.e('AccessControlCubit.submitAndSave', error: e, stackTrace: st);
      if (msg.contains('SLOT_TAKEN')) {
        // Slot already booked — check if it belongs to this user (e.g. retry
        // after a crash or a previous test run). If so, recover gracefully.
        try {
          final existing = await _client
              .from('bookings')
              .select('id')
              .eq('slot_id', slotId)
              .eq('user_id', userId)
              .maybeSingle();
          if (existing != null) {
            appLogger.i(
              'AccessControlCubit: recovered existing booking ${existing['id']}',
            );
            emit(AccessControlState.saved(
              bookingId: existing['id'] as String,
            ));
            return;
          }
        } catch (inner, innerSt) {
          appLogger.e(
            'AccessControlCubit: recovery query failed',
            error: inner,
            stackTrace: innerSt,
          );
        }
        emit(const AccessControlState.slotTaken());
      } else {
        emit(AccessControlState.failure(msg, stackTrace: st));
      }
    }
  }
}
