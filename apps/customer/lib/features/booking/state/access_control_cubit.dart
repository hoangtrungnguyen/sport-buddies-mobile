import 'package:customer/features/booking/state/access_control_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccessControlCubit extends Cubit<AccessControlState> {
  AccessControlCubit({required SupabaseClient client})
      : _client = client,
        super(const AccessControlState.idle());

  final SupabaseClient _client;

  Future<void> save(
    String slotId, {
    required String policy,
    required int maxPlayers,
  }) async {
    emit(const AccessControlState.saving());
    try {
      await _client.from('slots').update({
        'access_policy': policy,
        'max_players': maxPlayers,
      }).eq('id', slotId);
      emit(const AccessControlState.saved());
    } catch (e, st) {
      emit(AccessControlState.failure(e.toString(), stackTrace: st));
    }
  }
}
