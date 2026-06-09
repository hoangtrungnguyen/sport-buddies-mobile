import 'package:dashboard/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../bloc/venue_schedule_bloc.dart';
import '../model/models.dart';
import '../service/schedule_service.dart';
import '../widgets/create_slot_sheet.dart';
import '../widgets/schedule_filters.dart';
import '../widgets/schedule_header.dart';
import '../widgets/schedule_toolbar.dart';
import '../widgets/side_sheet.dart';
import '../widgets/slot_detail_sheet.dart';
import '../widgets/slot_legend.dart';
import 'day_view.dart';
import 'month_view.dart';
import 'week_view.dart';

/// Route entry of the new "Lịch sân" screen — provides [VenueScheduleBloc]
/// (scoped to the authenticated owner's courts) and renders the page body
/// below the app shell.
class VenueSchedulePage extends StatelessWidget {
  const VenueSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VenueScheduleBloc(service: sl<ScheduleService>())
        ..add(const VenueScheduleEvent.started()),
      child: const _VenueScheduleView(),
    );
  }
}

/// Page body: header → toolbar → filters → active view (cross-fade) → legend.
/// The overlay layer (detail / create / block sheet + toast) is hosted in
/// the ROOT [Overlay] — the handoff's `.overlay`/`.drawer`/`.toast` are
/// `position: fixed; inset: 0`, so the scrim must dim the whole viewport
/// (sidebar + topbar included), the 480px drawer must span full screen
/// height, and the toast centres on the viewport, not the content area.
class _VenueScheduleView extends StatefulWidget {
  const _VenueScheduleView();

  @override
  State<_VenueScheduleView> createState() => _VenueScheduleViewState();
}

class _VenueScheduleViewState extends State<_VenueScheduleView> {
  /// Not-yet-implemented detail actions ("Đặt sân", "Dời lịch", "Gọi") have
  /// no bloc event yet — they toast locally that the feature is coming.
  String? _localToast;

  /// Full-viewport sheet/toast layer, inserted above the app shell.
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    // Insert after the first frame — the root Overlay can't be mutated
    // while the tree is still building.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _overlayEntry != null) return;
      final bloc = context.read<VenueScheduleBloc>();
      final entry = OverlayEntry(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: BlocBuilder<VenueScheduleBloc, VenueScheduleState>(
            builder: (context, state) =>
                _overlayLayer(context.read<VenueScheduleBloc>(), state),
          ),
        ),
      );
      _overlayEntry = entry;
      Overlay.of(context, rootOverlay: true).insert(entry);
    });
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
    super.dispose();
  }

  /// Updates the prototype-only local toast — the overlay entry lives
  /// outside this subtree, so it must be repainted explicitly.
  void _setLocalToast(String? message) {
    setState(() => _localToast = message);
    _overlayEntry?.markNeedsBuild();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VenueScheduleBloc, VenueScheduleState>(
      builder: (context, state) =>
          _body(context.read<VenueScheduleBloc>(), state),
    );
  }

  // ---------------------------------------------------------------------------
  // Overlay layer — `.overlay` + `.drawer` + `.toast` (full viewport)
  // ---------------------------------------------------------------------------

  Widget _overlayLayer(VenueScheduleBloc bloc, VenueScheduleState state) {
    // Transparent Material so the sheets' text fields/ink work in the raw
    // overlay; the Stack itself is hit-transparent while nothing is open.
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // Sheets render their own scrim + 480px right panel
          // (ScheduleSideSheet) — drop them straight into the stack.
          if (state.activeSheet == VenueScheduleSheet.detail &&
              state.detailSlot != null)
            Positioned.fill(child: _detailSheet(bloc, state)),
          if (state.activeSheet == VenueScheduleSheet.create ||
              state.activeSheet == VenueScheduleSheet.block)
            Positioned.fill(child: _createSheet(bloc, state)),
          Positioned.fill(
            child: ScheduleToast(
              message: state.toast ?? _localToast,
              onCleared: () {
                if (_localToast != null) _setLocalToast(null);
                bloc.add(const VenueScheduleEvent.toastCleared());
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Page column
  // ---------------------------------------------------------------------------

  Widget _body(VenueScheduleBloc bloc, VenueScheduleState state) {
    return SingleChildScrollView(
      // `.page { padding: 26px 28px 60px; max-width: 1440px }` — cap and
      // left-align the content column on very wide viewports.
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 26, 28, 60),
            child: _pageColumn(bloc, state),
          ),
        ),
      ),
    );
  }

  Widget _pageColumn(VenueScheduleBloc bloc, VenueScheduleState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ScheduleHeader(
          onBlockPressed: () => _openBlockSheet(bloc, state),
          onCreatePressed: () => _openCreateSheet(bloc, state),
        ),
        const SizedBox(height: 22),
        ScheduleToolbar(
          state: state,
          onPrev: () => bloc.add(const VenueScheduleEvent.dateMoved(-1)),
          onNext: () => bloc.add(const VenueScheduleEvent.dateMoved(1)),
          onToday: () => bloc.add(const VenueScheduleEvent.todayPressed()),
          onViewChanged: (view) =>
              bloc.add(VenueScheduleEvent.viewChanged(view)),
        ),
        const SizedBox(height: 16),
        ScheduleFilters(
          state: state,
          onSportToggled: (sport) =>
              bloc.add(VenueScheduleEvent.sportFilterToggled(sport)),
          onVenueSelected: (venueId) =>
              bloc.add(VenueScheduleEvent.venueSelected(venueId)),
          onStateToggled: (slotState) =>
              bloc.add(VenueScheduleEvent.stateFilterToggled(slotState)),
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 120),
          child: KeyedSubtree(
            key: ValueKey(state.view),
            child: _activeView(bloc, state),
          ),
        ),
        // Legend under Day & Week only (not Month).
        if (state.view != ScheduleView.month) ...[
          const SizedBox(height: 14),
          const SlotLegend(),
        ],
      ],
    );
  }

  Widget _activeView(VenueScheduleBloc bloc, VenueScheduleState state) {
    if (state.status == VenueScheduleStatus.failure) {
      return _StatusCard(
        message: 'Không tải được dữ liệu lịch sân.',
        onRetry: () => bloc.add(const VenueScheduleEvent.started()),
      );
    }
    if (state.status == VenueScheduleStatus.loading && state.venues.isEmpty) {
      return const _StatusCard.loading();
    }
    // Loaded fine but the owner has no active courts — explain the blank
    // grid instead of rendering a bare time gutter with no columns.
    if (state.venues.isEmpty) {
      return const _StatusCard(
        message: 'Chưa có sân nào — thêm sân trong mục "Sân của tôi" '
            'để bắt đầu xếp lịch.',
      );
    }
    switch (state.view) {
      case ScheduleView.day:
        return const VenueScheduleDayView();
      case ScheduleView.week:
        return WeekView(
          venue: state.selectedVenue,
          slots: state.visibleWeekSlots,
          weekStart: state.weekStart,
          onSlotTapped: (slot) => bloc.add(VenueScheduleEvent.slotTapped(slot)),
          onEmptyCellTapped: (venueId, startHour, weekday) => bloc.add(
            VenueScheduleEvent.emptyCellTapped(
              venueId,
              startHour,
              weekday: weekday,
            ),
          ),
          onDragBlockRequested: (venueId, startHour, endHour, weekday) =>
              bloc.add(
            VenueScheduleEvent.dragBlockRequested(
              venueId,
              startHour,
              endHour,
              weekday: weekday,
            ),
          ),
        );
      case ScheduleView.month:
        return ScheduleMonthView(
          cells: state.monthCells,
          onDayTapped: (date) =>
              bloc.add(VenueScheduleEvent.monthDayTapped(date)),
        );
    }
  }

  // ---------------------------------------------------------------------------
  // Header buttons — the bloc opens sheets only via grid events, so the
  // header reuses them with the prototype's CreateDrawer defaults: venue
  // `view === 'week' ? courtId : 'c1'` (the selected venue in Week view,
  // the first venue otherwise), 18:00 start, 1.5h duration.
  // ---------------------------------------------------------------------------

  String? _headerVenueId(VenueScheduleState state) {
    if (state.venues.isEmpty) return null;
    return state.view == ScheduleView.week
        ? (state.selectedVenueId ?? state.venues.first.id)
        : state.venues.first.id;
  }

  void _openCreateSheet(VenueScheduleBloc bloc, VenueScheduleState state) {
    final venueId = _headerVenueId(state);
    if (venueId == null) {
      // Zero courts — say why nothing opens instead of a silent no-op.
      _setLocalToast('Chưa có sân nào — hãy thêm sân trước.');
      return;
    }
    bloc.add(
      VenueScheduleEvent.emptyCellTapped(venueId, 18.0, durationHours: 1.5),
    );
  }

  void _openBlockSheet(VenueScheduleBloc bloc, VenueScheduleState state) {
    final venueId = _headerVenueId(state);
    if (venueId == null) {
      _setLocalToast('Chưa có sân nào — hãy thêm sân trước.');
      return;
    }
    bloc.add(VenueScheduleEvent.dragBlockRequested(venueId, 18.0, 19.5));
  }

  // ---------------------------------------------------------------------------
  // Sheets
  // ---------------------------------------------------------------------------

  Widget _detailSheet(VenueScheduleBloc bloc, VenueScheduleState state) {
    final slot = state.detailSlot!;
    String? venueName;
    for (final v in state.venues) {
      if (v.id == slot.venueId) venueName = v.name;
    }
    return SlotDetailSheet(
      slot: slot,
      venueName: venueName,
      onClose: () => bloc.add(const VenueScheduleEvent.sheetClosed()),
      onApprove: () => bloc.add(VenueScheduleEvent.approveRequested(slot.id)),
      onReject: () => bloc.add(VenueScheduleEvent.rejectRequested(slot.id)),
      onCancel: () => bloc.add(VenueScheduleEvent.cancelRequested(slot.id)),
      // Real-data honesty: none of these actions are backed by the DB yet,
      // so they announce themselves instead of faking a success.
      // TODO(BCORE-321/326): wire "Mở ghép" once matchmaking slots exist
      // (the button is gated behind kMatchmakingEnabled meanwhile).
      onOpenForMatchmaking: () =>
          _setLocalToast('Tính năng đang phát triển'),
      onBookAtCounter: () => _setLocalToast('Tính năng đang phát triển'),
      onReschedule: () => _setLocalToast('Tính năng đang phát triển'),
      onCall: () => _setLocalToast('Tính năng đang phát triển'),
    );
  }

  Widget _createSheet(VenueScheduleBloc bloc, VenueScheduleState state) {
    final mode = state.activeSheet == VenueScheduleSheet.block
        ? CreateSlotSheetMode.block
        : CreateSlotSheetMode.create;
    return CreateSlotSheet(
      // Re-key per sheet kind so prefill state reinitialises on open.
      key: ValueKey(state.activeSheet),
      mode: mode,
      venues: state.venues,
      createPrefill: state.createPrefill,
      blockPrefill: state.blockPrefill,
      onClose: () => bloc.add(const VenueScheduleEvent.sheetClosed()),
      onCreateSubmitted: (request,
          {required repeat, required weekdays, required weeks}) {
        bloc.add(VenueScheduleEvent.createSlotSubmitted(
          request,
          repeat: repeat,
          weekdays: weekdays,
          weeks: weeks,
        ));
      },
      onBlockSubmitted: (request,
          {required repeat, required weekdays, required weeks}) {
        bloc.add(VenueScheduleEvent.blockSubmitted(
          request,
          repeat: repeat,
          weekdays: weekdays,
          weeks: weeks,
        ));
      },
    );
  }
}

/// Placeholder card occupying the grid area while the first load is in
/// flight, after a failure (with a retry button), or for the zero-courts
/// empty state (message only).
class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.message, this.onRetry}) : loading = false;

  const _StatusCard.loading()
      : loading = true,
        message = null,
        onRetry = null;

  final bool loading;
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.neutral200),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: loading
            ? const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.primary,
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      color: AppColors.neutral500,
                    ),
                  ),
                  if (onRetry != null) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: onRetry,
                      child: Text(
                        'Thử lại',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
