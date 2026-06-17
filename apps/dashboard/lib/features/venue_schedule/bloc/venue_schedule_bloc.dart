import 'package:flutter_bloc/flutter_bloc.dart';

import '../model/models.dart';
import '../repository/schedule_repository.dart';
import '../repository/schedule_time_utils.dart';
import '../service/schedule_service.dart';
import '../util/schedule_format.dart';
import 'venue_schedule_event.dart';
import 'venue_schedule_state.dart';

export 'venue_schedule_event.dart';
export 'venue_schedule_state.dart';

/// Single state holder for the "Lịch sân" screen. Talks only to
/// [ScheduleService]; the screen is scoped to one court ([courtId]).
class VenueScheduleBloc extends Bloc<VenueScheduleEvent, VenueScheduleState> {
  VenueScheduleBloc({
    required ScheduleService service,
    // Unused by the Supabase repository (it scopes to the authenticated
    // owner's courts) until slots gain a real venue grouping.
    this.courtId = '',
    DateTime Function()? now,
  })  : _service = service,
        _now = now ?? DateTime.now,
        super(VenueScheduleState(
            focusedDate: _dateOnly((now ?? DateTime.now)()))) {
    on<VenueScheduleStarted>(_onStarted);
    on<VenueScheduleViewChanged>(_onViewChanged);
    on<VenueScheduleDateMoved>(_onDateMoved);
    on<VenueScheduleTodayPressed>(_onTodayPressed);
    on<VenueScheduleVenueSelected>(_onVenueSelected);
    on<VenueScheduleSportFilterToggled>(_onSportFilterToggled);
    on<VenueScheduleStateFilterToggled>(_onStateFilterToggled);
    on<VenueScheduleSlotTapped>(_onSlotTapped);
    on<VenueScheduleEmptyCellTapped>(_onEmptyCellTapped);
    on<VenueScheduleDragBlockRequested>(_onDragBlockRequested);
    on<VenueScheduleMonthDayTapped>(_onMonthDayTapped);
    on<VenueScheduleCreateSlotSubmitted>(_onCreateSlotSubmitted);
    on<VenueScheduleBlockSubmitted>(_onBlockSubmitted);
    on<VenueScheduleApproveRequested>(_onApproveRequested);
    on<VenueScheduleRejectRequested>(_onRejectRequested);
    on<VenueScheduleCancelRequested>(_onCancelRequested);
    on<VenueScheduleToastCleared>(_onToastCleared);
    on<VenueScheduleSheetClosed>(_onSheetClosed);
  }

  final ScheduleService _service;
  final String courtId;
  final DateTime Function() _now;

  /// Create/Block sheet type-card titles — used to compose the success
  /// toasts exactly like the prototype's `createKinds`/`blockKinds`.
  static const Map<SlotState, String> _kindLabels = {
    SlotState.empty: 'Slot trống',
    SlotState.open: 'Slot mở (ghép)',
    SlotState.private: 'Slot riêng',
    SlotState.locked: 'Khoá giờ',
    SlotState.maintenance: 'Bảo trì',
    SlotState.owner: 'Sân của tôi',
  };

  // ---------------------------------------------------------------------------
  // Loading & navigation
  // ---------------------------------------------------------------------------

  Future<void> _onStarted(
    VenueScheduleStarted event,
    Emitter<VenueScheduleState> emit,
  ) async {
    emit(state.copyWith(status: VenueScheduleStatus.loading));
    try {
      final venues = await _service.getVenues(courtId);
      final selectedVenueId =
          state.selectedVenueId ?? (venues.isEmpty ? null : venues.first.id);
      final daySlots = await _service.getDaySlots(courtId, state.focusedDate);
      final weekSlots = selectedVenueId == null
          ? const <Slot>[]
          : await _service.getWeekSlots(selectedVenueId, state.weekStart);
      final monthCells =
          await _service.getMonthOccupancy(courtId, state.focusedDate);
      emit(state.copyWith(
        venues: venues,
        selectedVenueId: selectedVenueId,
        daySlots: daySlots,
        weekSlots: weekSlots,
        monthCells: monthCells,
        status: VenueScheduleStatus.ready,
      ));
    } on Exception {
      emit(state.copyWith(status: VenueScheduleStatus.failure));
    }
  }

  Future<void> _onViewChanged(
    VenueScheduleViewChanged event,
    Emitter<VenueScheduleState> emit,
  ) async {
    if (event.view == state.view) return;
    emit(state.copyWith(view: event.view));
    // Refresh the dataset behind the new view — the focused date may have
    // moved while another view was active.
    await _refreshActiveView(emit);
  }

  Future<void> _onDateMoved(
    VenueScheduleDateMoved event,
    Emitter<VenueScheduleState> emit,
  ) async {
    final d = state.focusedDate;
    final moved = switch (state.view) {
      ScheduleView.day => DateTime(d.year, d.month, d.day + event.delta),
      ScheduleView.week => DateTime(d.year, d.month, d.day + event.delta * 7),
      ScheduleView.month => _stepMonth(d, event.delta),
    };
    emit(state.copyWith(focusedDate: moved));
    await _refreshActiveView(emit);
  }

  Future<void> _onTodayPressed(
    VenueScheduleTodayPressed event,
    Emitter<VenueScheduleState> emit,
  ) async {
    emit(state.copyWith(focusedDate: _dateOnly(_now())));
    await _refreshActiveView(emit);
  }

  Future<void> _onVenueSelected(
    VenueScheduleVenueSelected event,
    Emitter<VenueScheduleState> emit,
  ) async {
    if (event.venueId == state.selectedVenueId) return;
    emit(state.copyWith(selectedVenueId: event.venueId));
    try {
      final weekStart = state.weekStart;
      final weekSlots = await _service.getWeekSlots(event.venueId, weekStart);
      // Drop the payload if the selection/week moved while fetching.
      if (state.selectedVenueId != event.venueId ||
          state.weekStart != weekStart) {
        return;
      }
      emit(state.copyWith(
        weekSlots: weekSlots,
        status: VenueScheduleStatus.ready,
      ));
    } on Exception {
      emit(state.copyWith(status: VenueScheduleStatus.failure));
    }
  }

  // ---------------------------------------------------------------------------
  // Filters — live, client-side, no refetch
  // ---------------------------------------------------------------------------
  //
  // Prototype `toggleSet`: every chip starts ACTIVE (full set) and a tap
  // removes/adds one; an emptied set resets to "all". Our empty set ≡ "all",
  // so expand an empty set before toggling and normalise a full set back to
  // empty — the chips then render exactly like the jsx.

  void _onSportFilterToggled(
    VenueScheduleSportFilterToggled event,
    Emitter<VenueScheduleState> emit,
  ) {
    final next = state.sportFilter.isEmpty
        ? SportType.values.toSet()
        : Set<SportType>.of(state.sportFilter);
    next.contains(event.sport)
        ? next.remove(event.sport)
        : next.add(event.sport);
    if (next.length == SportType.values.length) next.clear();
    emit(state.copyWith(sportFilter: next));
  }

  void _onStateFilterToggled(
    VenueScheduleStateFilterToggled event,
    Emitter<VenueScheduleState> emit,
  ) {
    final next = state.stateFilter.isEmpty
        ? SlotState.values.toSet()
        : Set<SlotState>.of(state.stateFilter);
    next.contains(event.state)
        ? next.remove(event.state)
        : next.add(event.state);
    if (next.length == SlotState.values.length) next.clear();
    emit(state.copyWith(stateFilter: next));
  }

  // ---------------------------------------------------------------------------
  // Sheet openers
  // ---------------------------------------------------------------------------

  void _onSlotTapped(
    VenueScheduleSlotTapped event,
    Emitter<VenueScheduleState> emit,
  ) {
    emit(state.copyWith(
      activeSheet: VenueScheduleSheet.detail,
      detailSlot: event.slot,
    ));
  }

  void _onEmptyCellTapped(
    VenueScheduleEmptyCellTapped event,
    Emitter<VenueScheduleState> emit,
  ) {
    emit(state.copyWith(
      activeSheet: VenueScheduleSheet.create,
      createPrefill: CreateSlotRequest(
        venueId: event.venueId,
        startHour: event.startHour,
        durationHours: event.durationHours,
        date: _dateForWeekday(event.weekday),
        weekday: event.weekday,
      ),
    ));
  }

  void _onDragBlockRequested(
    VenueScheduleDragBlockRequested event,
    Emitter<VenueScheduleState> emit,
  ) {
    emit(state.copyWith(
      activeSheet: VenueScheduleSheet.block,
      blockPrefill: BlockTimeRequest(
        venueId: event.venueId,
        startHour: event.startHour,
        durationHours: event.endHour - event.startHour,
        date: _dateForWeekday(event.weekday),
        weekday: event.weekday,
      ),
    ));
  }

  Future<void> _onMonthDayTapped(
    VenueScheduleMonthDayTapped event,
    Emitter<VenueScheduleState> emit,
  ) async {
    emit(state.copyWith(
      view: ScheduleView.day,
      focusedDate: _dateOnly(event.date),
    ));
    await _refreshActiveView(emit);
  }

  // ---------------------------------------------------------------------------
  // Mutations — call the service, close the sheet, refresh, toast
  // ---------------------------------------------------------------------------

  Future<void> _onCreateSlotSubmitted(
    VenueScheduleCreateSlotSubmitted event,
    Emitter<VenueScheduleState> emit,
  ) async {
    final req = event.request;
    final kind = _kindLabels[req.slotType] ?? 'Slot trống';
    final venue = _venueName(req.venueId);
    try {
      final String toast;
      if (event.repeat && event.weekdays.isNotEmpty) {
        // `created` is the server-reported insert count (the API's required
        // `created` field) — NOT the length of the optional echoed slot
        // array, which a schema-conformant backend may omit.
        final created = await _service.createRecurringSlots(
            req, event.weekdays, event.weeks);
        toast = 'Đã tạo $created slot · $kind · $venue';
      } else {
        await _service.createSlot(req);
        toast = 'Đã tạo $kind · $venue · ${hourLabel(req.startHour)}';
      }
      await _finishMutation(emit, toast);
    } on ScheduleRepositoryException catch (e) {
      // Predictable rejection — surface the reason, keep the sheet open.
      // Still refresh the grids: a recurrence may have created part of its
      // sessions before failing, and those slots are real now.
      emit(state.copyWith(status: VenueScheduleStatus.ready, toast: e.message));
      await _refreshSlotsKeepingSheet(emit);
    } on Exception {
      emit(state.copyWith(status: VenueScheduleStatus.failure));
    }
  }

  Future<void> _onBlockSubmitted(
    VenueScheduleBlockSubmitted event,
    Emitter<VenueScheduleState> emit,
  ) async {
    final req = event.request;
    final kind = _kindLabels[req.blockType] ?? 'Khoá giờ';
    final venue = _venueName(req.venueId);
    try {
      final String toast;
      if (event.repeat && event.weekdays.isNotEmpty) {
        // Prototype parity: recurrence applies to block mode too — one
        // block per selected weekday × week, anchored on the prefill week.
        // Same rules as `createRecurringSlots`: sessions already in the
        // past are skipped, and a failed session doesn't abort the rest —
        // the shortfall surfaces as one predictable rejection below.
        final sessions = recurringBlockSessions(
          anchorWeek: mondayOf(req.date ?? state.focusedDate),
          weekdays: event.weekdays,
          weeks: event.weeks,
          startHour: req.startHour,
          now: _now(),
        );
        var done = 0;
        var failures = 0;
        String? failureMessage;
        for (final session in sessions) {
          try {
            await _service.blockTime(
              req.copyWith(date: session.date, weekday: session.weekday),
            );
            done++;
          } on ScheduleRepositoryException catch (e) {
            failures++;
            failureMessage ??= e.message;
          } on Exception {
            // Already logged by the repository; counted in the summary.
            failures++;
          }
        }
        if (failures > 0) {
          throw ScheduleRepositoryException(done == 0
              ? (failureMessage ??
                  'Không khoá được khung giờ nào — vui lòng thử lại.')
              : 'Chỉ khoá được $done/${done + failures} phiên — '
                  '${failureMessage ?? 'một số phiên bị lỗi'}.');
        }
        toast = 'Đã tạo $done slot · $kind · $venue';
      } else {
        await _service.blockTime(req);
        toast = 'Đã tạo $kind · $venue · ${hourLabel(req.startHour)}';
      }
      await _finishMutation(emit, toast);
    } on ScheduleRepositoryException catch (e) {
      // Predictable rejection (e.g. the range overlaps a booking) — surface
      // the reason as a toast and keep the sheet open so the user adjusts.
      // The grids still refresh so any sessions that DID get blocked show.
      emit(state.copyWith(status: VenueScheduleStatus.ready, toast: e.message));
      await _refreshSlotsKeepingSheet(emit);
    } on Exception {
      emit(state.copyWith(status: VenueScheduleStatus.failure));
    }
  }

  Future<void> _onApproveRequested(
    VenueScheduleApproveRequested event,
    Emitter<VenueScheduleState> emit,
  ) async {
    final label = _slotById(event.slotId)?.label ?? 'slot';
    try {
      await _service.approveSlot(event.slotId);
      await _finishMutation(emit, 'Đã duyệt $label');
    } on ScheduleRepositoryException catch (e) {
      emit(state.copyWith(status: VenueScheduleStatus.ready, toast: e.message));
    } on Exception {
      emit(state.copyWith(status: VenueScheduleStatus.failure));
    }
  }

  Future<void> _onRejectRequested(
    VenueScheduleRejectRequested event,
    Emitter<VenueScheduleState> emit,
  ) async {
    final label = _slotById(event.slotId)?.label ?? 'slot';
    try {
      await _service.rejectSlot(event.slotId);
      await _finishMutation(emit, 'Đã từ chối $label');
    } on ScheduleRepositoryException catch (e) {
      emit(state.copyWith(status: VenueScheduleStatus.ready, toast: e.message));
    } on Exception {
      emit(state.copyWith(status: VenueScheduleStatus.failure));
    }
  }

  Future<void> _onCancelRequested(
    VenueScheduleCancelRequested event,
    Emitter<VenueScheduleState> emit,
  ) async {
    // "Huỷ" on a booking vs "Mở khoá giờ này" on a block — same event, the
    // toast follows the prototype wording for each.
    final slot = _slotById(event.slotId);
    final isBlock = const {
      SlotState.locked,
      SlotState.maintenance,
      SlotState.owner,
    }.contains(slot?.state);
    try {
      await _service.cancelSlot(event.slotId);
      await _finishMutation(emit, isBlock ? 'Đã mở khoá giờ' : 'Đã huỷ slot');
    } on ScheduleRepositoryException catch (e) {
      emit(state.copyWith(status: VenueScheduleStatus.ready, toast: e.message));
    } on Exception {
      emit(state.copyWith(status: VenueScheduleStatus.failure));
    }
  }

  void _onToastCleared(
    VenueScheduleToastCleared event,
    Emitter<VenueScheduleState> emit,
  ) {
    emit(state.copyWith(toast: null));
  }

  void _onSheetClosed(
    VenueScheduleSheetClosed event,
    Emitter<VenueScheduleState> emit,
  ) {
    emit(state.copyWith(
      activeSheet: VenueScheduleSheet.none,
      detailSlot: null,
      createPrefill: null,
      blockPrefill: null,
    ));
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Reloads the dataset behind the active view for the current focused date.
  ///
  /// Handlers of different event subtypes run concurrently (each `on<…>`
  /// registration has its own stream), so the request key (view / date /
  /// venue) is captured before the await and stale payloads are dropped —
  /// otherwise e.g. › then "Hôm nay" could leave day+1 slots under today's
  /// label when the first fetch resolves last.
  Future<void> _refreshActiveView(Emitter<VenueScheduleState> emit) async {
    final view = state.view;
    final date = state.focusedDate;
    try {
      switch (view) {
        case ScheduleView.day:
          final daySlots = await _service.getDaySlots(courtId, date);
          if (state.view != view || state.focusedDate != date) return;
          emit(state.copyWith(
            daySlots: daySlots,
            status: VenueScheduleStatus.ready,
          ));
        case ScheduleView.week:
          final venueId = state.selectedVenueId;
          if (venueId == null) return;
          final weekStart = state.weekStart;
          final weekSlots = await _service.getWeekSlots(venueId, weekStart);
          if (state.view != view ||
              state.selectedVenueId != venueId ||
              state.weekStart != weekStart) {
            return;
          }
          emit(state.copyWith(
            weekSlots: weekSlots,
            status: VenueScheduleStatus.ready,
          ));
        case ScheduleView.month:
          final monthCells = await _service.getMonthOccupancy(courtId, date);
          if (state.view != view ||
              state.focusedDate.year != date.year ||
              state.focusedDate.month != date.month) {
            return;
          }
          emit(state.copyWith(
            monthCells: monthCells,
            status: VenueScheduleStatus.ready,
          ));
      }
    } on Exception {
      emit(state.copyWith(status: VenueScheduleStatus.failure));
    }
  }

  /// After a successful mutation: reload day + week slots (the datasets
  /// mutations land in), close any open sheet, and show [toast]. If the user
  /// navigated while the refetch was in flight the (stale) lists are kept
  /// as-is — only the sheet close + toast apply.
  Future<void> _finishMutation(
    Emitter<VenueScheduleState> emit,
    String toast,
  ) async {
    final date = state.focusedDate;
    final venueId = state.selectedVenueId;
    final daySlots = await _service.getDaySlots(courtId, date);
    final weekSlots = venueId == null
        ? state.weekSlots
        : await _service.getWeekSlots(venueId, mondayOf(date));
    final fresh = state.focusedDate == date && state.selectedVenueId == venueId;
    emit(state.copyWith(
      daySlots: fresh ? daySlots : state.daySlots,
      weekSlots: fresh ? weekSlots : state.weekSlots,
      status: VenueScheduleStatus.ready,
      toast: toast,
      activeSheet: VenueScheduleSheet.none,
      detailSlot: null,
      createPrefill: null,
      blockPrefill: null,
    ));
  }

  /// Refreshes Day + Week slots WITHOUT closing the open sheet — used after
  /// a predictable mutation rejection that may still have written rows (a
  /// partially-created recurrence) so the calendar reflects what actually
  /// exists while the user adjusts the sheet. A refresh failure keeps the
  /// stale lists; the rejection toast is already showing.
  Future<void> _refreshSlotsKeepingSheet(
    Emitter<VenueScheduleState> emit,
  ) async {
    final date = state.focusedDate;
    final venueId = state.selectedVenueId;
    try {
      final daySlots = await _service.getDaySlots(courtId, date);
      final weekSlots = venueId == null
          ? state.weekSlots
          : await _service.getWeekSlots(venueId, mondayOf(date));
      if (state.focusedDate != date || state.selectedVenueId != venueId) {
        return;
      }
      emit(state.copyWith(daySlots: daySlots, weekSlots: weekSlots));
    } on Exception {
      // Keep the stale lists.
    }
  }

  /// The concrete date a tapped/dragged cell refers to: Week view passes a
  /// weekday (0=Mon..6=Sun) within the focused week, Day view means the
  /// focused date itself.
  DateTime _dateForWeekday(int? weekday) {
    if (weekday == null) return state.focusedDate;
    final ws = state.weekStart;
    return DateTime(ws.year, ws.month, ws.day + weekday);
  }

  Slot? _slotById(String slotId) {
    if (state.detailSlot?.id == slotId) return state.detailSlot;
    for (final s in [...state.daySlots, ...state.weekSlots]) {
      if (s.id == slotId) return s;
    }
    return null;
  }

  String _venueName(String venueId) {
    for (final v in state.venues) {
      if (v.id == venueId) return v.name;
    }
    return venueId;
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Steps [d] by [delta] months, clamping the day-of-month so e.g. Jan 31
  /// +1 month lands on Feb 28/29 instead of overflowing into March.
  static DateTime _stepMonth(DateTime d, int delta) {
    final first = DateTime(d.year, d.month + delta);
    final lastDay = DateTime(first.year, first.month + 1, 0).day;
    return DateTime(first.year, first.month, d.day > lastDay ? lastDay : d.day);
  }
}
