import 'package:flutter_bloc/flutter_bloc.dart';

import '../../setup/model/owner_court.dart';
import '../model/manual_booking_result.dart';
import '../repository/manual_booking_repository.dart';
import '../repository/owner_slot_repository.dart';
import '../schedule_logic.dart';
import 'schedule_event.dart';
import 'schedule_state.dart';

export 'schedule_event.dart';
export 'schedule_state.dart';

/// Loads the owner's courts (for the tab strip). Injected as a callback rather
/// than depending on the concrete `OwnerCourtRepository`, so the bloc stays
/// trivially fakeable in tests.
typedef CourtsLoader = Future<List<OwnerCourt>> Function();

/// Drives the weekly schedule screen: court tabs, week navigation, and owner
/// slot creation (OWNER-19).
class ScheduleBloc extends Bloc<ScheduleEvent, ScheduleState> {
  ScheduleBloc({
    required OwnerSlotRepository slotRepository,
    required ManualBookingRepository bookingRepository,
    required CourtsLoader loadCourts,
    DateTime Function()? now,
  })  : _slots = slotRepository,
        _bookings = bookingRepository,
        _loadCourts = loadCourts,
        _now = now ?? DateTime.now,
        super(const ScheduleInitial()) {
    on<ScheduleStarted>(_onStarted);
    on<ScheduleCourtSelected>(_onCourtSelected);
    on<ScheduleWeekChanged>(_onWeekChanged);
    on<ScheduleTodayPressed>(_onTodayPressed);
    on<ScheduleOwnerSlotCreated>(_onOwnerSlotCreated);
    on<ScheduleManualBookingCreated>(_onManualBookingCreated);
    on<ScheduleBookingResultCleared>(_onBookingResultCleared);
  }

  final OwnerSlotRepository _slots;
  final ManualBookingRepository _bookings;
  final CourtsLoader _loadCourts;
  final DateTime Function() _now;

  Future<void> _onStarted(
    ScheduleStarted event,
    Emitter<ScheduleState> emit,
  ) async {
    emit(const ScheduleLoading());
    try {
      final courts = await _loadCourts();
      final weekStart = mondayOf(_now());
      if (courts.isEmpty) {
        emit(ScheduleLoaded(
          courts: const [],
          activeCourtId: '',
          weekStart: weekStart,
          slots: const [],
        ));
        return;
      }
      final activeCourtId = courts.first.id;
      final slots = await _slots.fetchWeekSlots(
        courtId: activeCourtId,
        weekStart: weekStart,
      );
      emit(ScheduleLoaded(
        courts: courts,
        activeCourtId: activeCourtId,
        weekStart: weekStart,
        slots: slots,
      ));
    } catch (e, st) {
      emit(ScheduleFailure('Không thể tải lịch sân.', stackTrace: st));
    }
  }

  Future<void> _onCourtSelected(
    ScheduleCourtSelected event,
    Emitter<ScheduleState> emit,
  ) async {
    final s = state;
    if (s is! ScheduleLoaded || s.activeCourtId == event.courtId) return;
    await _reload(emit, s, courtId: event.courtId, weekStart: s.weekStart);
  }

  Future<void> _onWeekChanged(
    ScheduleWeekChanged event,
    Emitter<ScheduleState> emit,
  ) async {
    final s = state;
    if (s is! ScheduleLoaded) return;
    final ws = mondayOf(event.weekStart);
    // SfCalendar re-emits the current week on every view change; ignore those.
    if (ws == s.weekStart) return;
    await _reload(emit, s, courtId: s.activeCourtId, weekStart: ws);
  }

  Future<void> _onTodayPressed(
    ScheduleTodayPressed event,
    Emitter<ScheduleState> emit,
  ) async {
    final s = state;
    if (s is! ScheduleLoaded) return;
    await _reload(emit, s,
        courtId: s.activeCourtId, weekStart: mondayOf(_now()));
  }

  Future<void> _onOwnerSlotCreated(
    ScheduleOwnerSlotCreated event,
    Emitter<ScheduleState> emit,
  ) async {
    final s = state;
    if (s is! ScheduleLoaded || s.activeCourtId.isEmpty) return;
    // Guard against a conflicting write even if the form was bypassed.
    if (hasConflict(s.slots, event.startAt, event.endAt)) return;
    emit(s.copyWith(busy: true, bookingResult: null));
    try {
      await _slots.createOwnerSlot(
        courtId: s.activeCourtId,
        startAt: event.startAt,
        endAt: event.endAt,
      );
      final slots = await _slots.fetchWeekSlots(
        courtId: s.activeCourtId,
        weekStart: s.weekStart,
      );
      emit(s.copyWith(slots: slots, busy: false, bookingResult: null));
    } catch (e, st) {
      emit(ScheduleFailure('Không thể tạo slot. Vui lòng thử lại.',
          stackTrace: st));
    }
  }

  Future<void> _onManualBookingCreated(
    ScheduleManualBookingCreated event,
    Emitter<ScheduleState> emit,
  ) async {
    final s = state;
    if (s is! ScheduleLoaded || s.activeCourtId.isEmpty) return;
    // Client-side overlap guard against the active court's loaded slots — the
    // server's check only catches an exact-window match (OWNER-20 decision:
    // client-side now; server hardening filed separately). The compose dialog
    // already disables submit on a conflict, so this is a safety net; surface a
    // failure result rather than returning silently so a waiting dialog never
    // hangs.
    if (hasConflict(s.slots, event.startAt, event.endAt)) {
      emit(s.copyWith(
        bookingResult: ManualBookingFailed(_bookingErrorMessage('overlap')),
      ));
      return;
    }
    // Spinner on; clear any stale result so the dialog reacts only to this one.
    emit(s.copyWith(busy: true, bookingResult: null));
    try {
      await _bookings.createManualBooking(
        courtId: s.activeCourtId,
        startAt: event.startAt,
        endAt: event.endAt,
        customerName: event.customerName,
        customerPhone: event.customerPhone,
        notes: event.notes,
        pricePerHourOverride: event.pricePerHourOverride,
      );
      final slots = await _slots.fetchWeekSlots(
        courtId: s.activeCourtId,
        weekStart: s.weekStart,
      );
      emit(s.copyWith(
        slots: slots,
        busy: false,
        bookingResult: ManualBookingSucceeded(
          startAt: event.startAt,
          endAt: event.endAt,
          customerName: event.customerName,
        ),
      ));
    } on ManualBookingException catch (e) {
      // A predictable server rejection (overlap, invalid input, …) — keep the
      // schedule loaded and surface the reason so the owner can fix + retry
      // from the still-open dialog instead of losing the whole view.
      emit(s.copyWith(
        busy: false,
        bookingResult: ManualBookingFailed(_bookingErrorMessage(e.code)),
      ));
    } catch (_) {
      emit(s.copyWith(
        busy: false,
        bookingResult: const ManualBookingFailed(
            'Không thể tạo booking. Vui lòng thử lại.'),
      ));
    }
  }

  Future<void> _onBookingResultCleared(
    ScheduleBookingResultCleared event,
    Emitter<ScheduleState> emit,
  ) async {
    final s = state;
    if (s is ScheduleLoaded && s.bookingResult != null) {
      emit(s.copyWith(bookingResult: null));
    }
  }

  /// Maps a [ManualBookingException] code to a localized, user-facing message.
  static String _bookingErrorMessage(String code) => switch (code) {
        'overlap' => 'Khung giờ này đã có người đặt. Hãy chọn giờ khác.',
        'invalid_input' =>
          'Thông tin chưa hợp lệ. Kiểm tra lại số điện thoại hoặc thời gian.',
        'not_owner' => 'Bạn không có quyền đặt sân này.',
        'court_not_found' => 'Không tìm thấy sân.',
        'unauthorized' => 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
        'service_unavailable' ||
        'network' =>
          'Không kết nối được máy chủ. Vui lòng thử lại.',
        _ => 'Không thể tạo booking. Vui lòng thử lại.',
      };

  /// Re-fetches slots for [courtId]/[weekStart], surfacing a [busy] spinner on
  /// the existing loaded view while the request is in flight.
  Future<void> _reload(
    Emitter<ScheduleState> emit,
    ScheduleLoaded current, {
    required String courtId,
    required DateTime weekStart,
  }) async {
    emit(current.copyWith(
      activeCourtId: courtId,
      weekStart: weekStart,
      busy: true,
      bookingResult: null,
    ));
    try {
      final slots = await _slots.fetchWeekSlots(
        courtId: courtId,
        weekStart: weekStart,
      );
      emit(current.copyWith(
        activeCourtId: courtId,
        weekStart: weekStart,
        slots: slots,
        busy: false,
        bookingResult: null,
      ));
    } catch (e, st) {
      emit(ScheduleFailure('Không thể tải lịch sân.', stackTrace: st));
    }
  }
}
