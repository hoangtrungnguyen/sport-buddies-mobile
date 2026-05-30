import 'package:customer/core/mixins/app_exception_mixin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spb_core/spb_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  BookingCubit({
    required SlotRepository slotRepository,
    required CourtRepository courtRepository,
    required SupabaseClient client,
  })  : _slotRepo = slotRepository,
        _courtRepo = courtRepository,
        _client = client,
        super(const BookingInitial());

  final SlotRepository _slotRepo;
  final CourtRepository _courtRepo;
  final SupabaseClient _client;

  Future<void> load(String slotId) async {
    emit(const BookingLoading());

    final slotResult = await _slotRepo.fetchSlotById(slotId);
    if (slotResult is! Success<Slot>) {
      emit(const BookingError('Không thể tải thông tin khung giờ.'));
      return;
    }
    final slot = slotResult.value;

    final courtResult = await _courtRepo.fetchCourtById(slot.courtId);
    final pricePerHour = courtResult is Success<Court>
        ? courtResult.value.pricePerHour
        : null;

    final meta = _client.auth.currentSession?.user.userMetadata ?? {};
    final name = (meta['full_name'] as String?) ?? '';
    final phone = (meta['phone'] as String?) ?? '';

    emit(BookingLoaded(
      slot: slot,
      pricePerHour: pricePerHour,
      name: name,
      phone: phone,
    ));
  }

  Future<void> submit({
    required String slotId,
    required String name,
    required String phone,
    String? notes,
  }) async {
    final s = state;
    if (s is! BookingLoaded) return;
    emit(const BookingSubmitting());

    try {
      final userId = _client.auth.currentSession?.user.id;
      if (userId == null) {
        emit(const BookingError('Vui lòng đăng nhập lại.'));
        return;
      }

      final slot = s.slot;
      final durationMinutes =
          slot.endTime.difference(slot.startTime).inMinutes;
      final pricePerHour = s.pricePerHour;
      final totalPrice =
          pricePerHour != null ? pricePerHour * durationMinutes / 60 : null;
      final notesVal = notes?.trim().isEmpty == true ? null : notes?.trim();

      final response = await _client.from('bookings').insert({
        'slot_id': slotId,
        'user_id': userId,
        'court_id': slot.courtId,
        'customer_name': name.trim(),
        'customer_phone': phone.trim(),
        if (notesVal != null) 'notes': notesVal,
        'status': 'pending',
        if (pricePerHour != null) 'price_per_hour': pricePerHour,
        'duration_minutes': durationMinutes,
        if (totalPrice != null) 'total_price': totalPrice,
        'is_owner_slot': false,
        'is_walk_in': false,
        'is_auto_approved': false,
      }).select('id').single();

      emit(BookingSubmitted(bookingId: response['id'] as String));
    } catch (e, st) {
      emit(BookingError(e.toString(), stackTrace: st));
    }
  }
}
