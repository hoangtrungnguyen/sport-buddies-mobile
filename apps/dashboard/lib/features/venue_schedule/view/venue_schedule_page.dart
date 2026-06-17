import 'package:dashboard/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
import 'schedule_active_view.dart';

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
            child: ScheduleActiveView(bloc: bloc, state: state),
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
