import 'package:customer/features/booking/state/payment_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit({required SupabaseClient client})
      : _client = client,
        super(const PaymentState.loading());

  final SupabaseClient _client;

  Future<void> load(String slotId) async {
    emit(const PaymentState.loading());
    try {
      final data = await _client
          .from('bookings')
          .select(
            'id, total_price, slots!inner(start_at, end_at, courts!inner(name))',
          )
          .eq('slot_id', slotId)
          .eq('status', 'confirmed')
          .order('created_at', ascending: false)
          .limit(1)
          .single();

      final slot = data['slots'] as Map<String, dynamic>;
      final court = slot['courts'] as Map<String, dynamic>;

      emit(PaymentState.loaded(
        bookingId: data['id'] as String,
        courtName: court['name'] as String,
        slotStart: DateTime.parse(slot['start_at'] as String).toLocal(),
        slotEnd: DateTime.parse(slot['end_at'] as String).toLocal(),
        totalPrice: (data['total_price'] as num?)?.toDouble() ?? 0.0,
      ));
    } catch (e, st) {
      emit(PaymentState.error(e.toString(), stackTrace: st));
    }
  }
}
