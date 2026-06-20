import 'package:customer/core/debug/app_logger.dart';
import 'package:customer/core/services/booking_api_client.dart';
import 'package:customer/features/booking/state/access_control_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccessControlCubit extends Cubit<AccessControlState> {
  AccessControlCubit({
    required SupabaseClient client,
    required BookingApiClient apiClient,
  }) : _client = client,
       _api = apiClient,
       super(const AccessControlState.idle());

  final SupabaseClient _client;
  final BookingApiClient _api;

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
      emit(const AccessControlState.failure('relogin'));
      return;
    }

    try {
      // Server computes price/duration from the slot — only identity +
      // contact details travel over the wire.
      final bookingId = await _api.createBooking(
        slotId: slotId,
        customerName: name,
        customerPhone: phone,
        notes: notes,
      );

      if (policy == 'open') {
        await _api.updateSlotAccess(
          slotId: slotId,
          accessPolicy: policy,
          maxPlayers: maxPlayers,
        );
      }

      emit(AccessControlState.saved(bookingId: bookingId));
    } on NoConnectionException {
      emit(const AccessControlState.failure('network'));
    } on SlotUnavailableException catch (e, st) {
      appLogger.e('AccessControlCubit.submitAndSave', error: e, stackTrace: st);
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
          emit(AccessControlState.saved(bookingId: existing['id'] as String));
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
    } catch (e, st) {
      appLogger.e('AccessControlCubit.submitAndSave', error: e, stackTrace: st);
      emit(AccessControlState.failure(e.toString(), stackTrace: st));
    }
  }
}
