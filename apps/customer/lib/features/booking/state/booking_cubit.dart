import 'package:customer/core/debug/app_logger.dart';
import 'package:customer/core/mixins/app_exception_mixin.dart';
import 'package:customer/core/services/booking_api_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spb_core/spb_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  BookingCubit({
    required SlotRepository slotRepository,
    required CourtRepository courtRepository,
    required SupabaseClient client,
    required BookingApiClient apiClient,
  })  : _slotRepo = slotRepository,
        _courtRepo = courtRepository,
        _client = client,
        _api = apiClient,
        super(const BookingInitial());

  final SlotRepository _slotRepo;
  final CourtRepository _courtRepo;
  final SupabaseClient _client;
  final BookingApiClient _api;

  Future<void> load(String slotId) async {
    emit(const BookingLoading());

    final slotResult = await _slotRepo.fetchSlotById(slotId);
    if (slotResult is! Success<Slot>) {
      emit(const BookingError('Không thể tải thông tin khung giờ.'));
      return;
    }
    final slot = slotResult.value;

    final courtResult = await _courtRepo.fetchCourtById(slot.courtId);
    final court = courtResult is Success<Court> ? courtResult.value : null;
    final pricePerHour = court?.pricePerHour;
    final courtAddress = court?.address;

    final userId = _client.auth.currentSession?.user.id;
    String name = '';
    String phone = '';
    if (userId != null) {
      try {
        final row = await _client
            .from('customers')
            .select('full_name, phone')
            .eq('id', userId)
            .maybeSingle();
        name = (row?['full_name'] as String?) ?? '';
        phone = (row?['phone'] as String?) ?? '';
      } catch (e, st) {
        appLogger.w(
          'BookingCubit.load: customers query failed, falling back to metadata',
          error: e,
          stackTrace: st,
        );
        final meta = _client.auth.currentSession?.user.userMetadata ?? {};
        name = (meta['full_name'] as String?) ?? '';
        phone = (meta['phone'] as String?) ?? '';
      }
    }

    emit(BookingLoaded(
      slot: slot,
      pricePerHour: pricePerHour,
      name: name,
      phone: phone,
      courtAddress: courtAddress,
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

      // Server computes price/duration from the slot — only identity +
      // contact details travel over the wire.
      final bookingId = await _api.createBooking(
        slotId: slotId,
        customerName: name.trim(),
        customerPhone: phone.trim(),
        notes: notes?.trim(),
      );

      emit(BookingSubmitted(bookingId: bookingId));
    } on SlotUnavailableException {
      emit(const BookingSlotTaken());
    } catch (e, st) {
      appLogger.e('BookingCubit.submit', error: e, stackTrace: st);
      emit(BookingError(e.toString(), stackTrace: st));
    }
  }
}
