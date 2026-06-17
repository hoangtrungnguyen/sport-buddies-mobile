import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../bloc/venue_schedule_bloc.dart';
import '../model/models.dart';
import '../util/schedule_format.dart';
import '../widgets/day_grid_internals.dart';
import '../widgets/day_grid_metrics.dart';
import '../widgets/mouse_vertical_drag.dart';
import '../widgets/slot_block.dart';
import '../widgets/sticky_grid_header.dart';

/// "Ngày" view — every venue of the court side-by-side as resource columns
/// for [VenueScheduleState.focusedDate] (`DayView` / `.day-grid` in the
/// handoff).
///
/// Reads [VenueScheduleBloc] from context; drop it straight into the page
/// body. Columns are [VenueScheduleState.visibleVenues] (sport filter), slot
/// blocks are [VenueScheduleState.visibleDaySlots] (state filter).
///
/// Interactions (dispatched as bloc events):
/// - tap a slot block → `slotTapped(slot)`;
/// - tap empty grid → `emptyCellTapped(venueId, snappedHour)` (30-min snap);
/// - press-drag vertically on empty grid → indigo drag band with a live
///   `HH:MM–HH:MM` label; on release a range ≥ 0.5h dispatches
///   `dragBlockRequested(venueId, startHour, endHour)`.
class VenueScheduleDayView extends StatefulWidget {
  const VenueScheduleDayView({super.key, this.now});

  /// Injectable clock for the "now" line; defaults to [DateTime.now].
  final DateTime Function()? now;

  @override
  State<VenueScheduleDayView> createState() => _VenueScheduleDayViewState();
}

class _VenueScheduleDayViewState extends State<VenueScheduleDayView> {
  /// In-flight drag-to-block, or null.
  DayDrag? _drag;

  /// Hovered slot id — its block is reordered last in its column's Stack so
  /// it paints above siblings (`.sc-slot:hover { z-index: 4 }`).
  String? _hoveredSlotId;

  /// Keeps the "now" line moving while the page stays open.
  Timer? _nowTimer;

  @override
  void initState() {
    super.initState();
    _nowTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _nowTimer?.cancel();
    super.dispose();
  }

  DateTime _now() => (widget.now ?? DateTime.now)();

  @override
  Widget build(BuildContext context) {
    final viewportWidth = MediaQuery.sizeOf(context).width;
    return BlocBuilder<VenueScheduleBloc, VenueScheduleState>(
      builder: (context, state) {
        final venues = state.visibleVenues;
        final slots = state.visibleDaySlots;
        // White card, 1px n-200, radius 14, clipped (`.day-grid`).
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.neutral200),
            borderRadius: BorderRadius.circular(14),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final grid = _grid(venues, slots, state.focusedDate);
              // ≤1024px: horizontal scroll, grid keeps a 720px floor.
              if (viewportWidth >= kHScrollBreakpoint) return grid;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: math.max(kMinGridWidth, constraints.maxWidth),
                  child: grid,
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Header + body with the handoff's `.day-head { position: sticky }` —
  /// while the page scrolls through the 1020px grid the venue-head row stays
  /// pinned at the viewport top.
  Widget _grid(List<Venue> venues, List<Slot> slots, DateTime focusedDate) {
    return StickyGridHeader(
      header: _header(venues, slots),
      body: _body(venues, slots, focusedDate),
      maxStick: kBodyHeight,
    );
  }

  // ---------------------------------------------------------------------
  // Header row — [64px corner] + N venue heads (`.day-head`)
  // ---------------------------------------------------------------------

  Widget _header(List<Venue> venues, List<Slot> slots) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.neutral50,
        border: Border(bottom: BorderSide(color: AppColors.neutral200)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Corner cell over the time gutter.
            Container(
              width: kGutterWidth,
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: AppColors.neutral200)),
              ),
            ),
            for (var i = 0; i < venues.length; i++)
              Expanded(
                child: _venueHead(
                  venues[i],
                  slots,
                  isLast: i == venues.length - 1,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 9px venue dot + name (Sora 14/700) + sport (11 n-500) + `<N> slot`
  /// (mono 11/700) — `.day-col-head`.
  Widget _venueHead(Venue venue, List<Slot> slots, {required bool isLast}) {
    final count = slots
        .where(
          (s) => s.venueId == venue.id && kBookedStates.contains(s.state),
        )
        .length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: isLast
          ? null
          : const BoxDecoration(
              border: Border(right: BorderSide(color: AppColors.neutral200)),
            ),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: Color(venue.colorValue),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  venue.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.sora(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.14, // -.01em
                    color: AppColors.neutral900,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  venue.sportLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.neutral500,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count slot',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral600,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Body — time gutter + venue columns + now line (`.day-body`)
  // ---------------------------------------------------------------------

  Widget _body(List<Venue> venues, List<Slot> slots, DateTime focusedDate) {
    return SizedBox(
      height: kBodyHeight,
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _timeGutter(),
              for (var i = 0; i < venues.length; i++)
                Expanded(
                  child: _venueColumn(
                    venues[i],
                    slots,
                    isLast: i == venues.length - 1,
                  ),
                ),
            ],
          ),
          ..._nowLine(focusedDate),
        ],
      ),
    );
  }

  /// 17 stacked `06:00..22:00` labels, mono 10.5 n-400, right-aligned, 60px
  /// rows with a top hairline (`.day-gutter .ghr`).
  Widget _timeGutter() {
    return Container(
      width: kGutterWidth,
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: AppColors.neutral200)),
      ),
      child: Column(
        children: [
          for (var h = kFirstHour; h <= kLastHour; h++)
            Container(
              height: kHourPx,
              alignment: Alignment.topRight,
              padding: const EdgeInsets.fromLTRB(8, 3, 8, 0),
              decoration: h == kFirstHour
                  ? null
                  : const BoxDecoration(
                      border:
                          Border(top: BorderSide(color: AppColors.neutral100)),
                    ),
              child: Text(
                hourLabel(h.toDouble()),
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10.5,
                  color: AppColors.neutral400,
                  height: 1.25,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// One venue's resource column: hour gridlines + absolutely positioned
  /// slot blocks + tap-to-create / drag-to-block (`.day-col`).
  ///
  /// Drag-to-block recognises MOUSE drags only ([MouseVerticalDrag]) so
  /// touch pans keep scrolling the page over the 1020px grid.
  Widget _venueColumn(
    Venue venue,
    List<Slot> allSlots, {
    required bool isLast,
  }) {
    final slots =
        allSlots.where((s) => s.venueId == venue.id).toList(growable: false);
    final drag = _drag;
    final dragging = drag != null && drag.venueId == venue.id;
    // Hovered block last → painted above its siblings (CSS z-index: 4).
    final ordered = [...slots];
    final hoveredIndex = ordered.indexWhere((s) => s.id == _hoveredSlotId);
    if (hoveredIndex != -1) ordered.add(ordered.removeAt(hoveredIndex));
    return MouseVerticalDrag(
      onStart: (details) =>
          _onDragStart(venue, slots, details.localPosition.dy),
      onUpdate: _onDragUpdate,
      onEnd: (_) => _onDragEnd(),
      onCancel: _onDragCancel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (details) => _onColumnTap(venue, details.localPosition.dy),
        child: Container(
          decoration: BoxDecoration(
            // `.drop-active` — rgba(22,163,74,.06) wash while dragging here.
            color: dragging ? const Color(0x0F16A34A) : null,
            border: isLast
                ? null
                : const Border(right: BorderSide(color: AppColors.neutral200)),
          ),
          child: Stack(
            children: [
              const Positioned.fill(
                child: CustomPaint(painter: HourLinesPainter()),
              ),
              for (final slot in ordered)
                Positioned(
                  key: ValueKey(slot.id),
                  top: (slot.startHour - kFirstHour) * kHourPx + 2,
                  left: 4,
                  right: 4,
                  child: SlotBlock(
                    slot: slot,
                    height: slot.durationHours * kHourPx,
                    onHoverChanged: (hovered) => setState(() {
                      if (hovered) {
                        _hoveredSlotId = slot.id;
                      } else if (_hoveredSlotId == slot.id) {
                        _hoveredSlotId = null;
                      }
                    }),
                    onTap: () => context
                        .read<VenueScheduleBloc>()
                        .add(VenueScheduleEvent.slotTapped(slot)),
                  ),
                ),
              if (dragging) _dragBand(drag),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Interactions — snap math replicated from `schedule-views.jsx`
  // ---------------------------------------------------------------------

  /// `hourFromY`: 30-minute snap — `6 + floor(relY / 60 × 2) / 2`.
  double _hourFromY(double dy) {
    final rel = (dy / kHourPx).clamp(0.0, kRowCount.toDouble());
    return kFirstHour + (rel * 2).floor() / 2;
  }

  /// Whether a press at [dy] lands on an existing slot block — the prototype
  /// only starts a drag from EMPTY grid (`closest('.sc-slot')` guard). Taps
  /// need no guard: the block's own recognizer wins the gesture arena.
  bool _hitsSlot(List<Slot> venueSlots, double dy) {
    for (final slot in venueSlots) {
      final top = (slot.startHour - kFirstHour) * kHourPx + 2;
      final height = math.max(slot.durationHours * kHourPx - 4, 22.0);
      if (dy >= top && dy <= top + height) return true;
    }
    return false;
  }

  /// Tap empty grid → Create sheet prefilled with venue + snapped hour
  /// (default 1h duration comes from [CreateSlotRequest]).
  void _onColumnTap(Venue venue, double dy) {
    context.read<VenueScheduleBloc>().add(
          VenueScheduleEvent.emptyCellTapped(venue.id, _hourFromY(dy)),
        );
  }

  void _onDragStart(Venue venue, List<Slot> venueSlots, double dy) {
    if (_hitsSlot(venueSlots, dy)) return;
    final startHour = _hourFromY(dy);
    setState(() {
      _drag = DayDrag(
        venueId: venue.id,
        startHour: startHour,
        currentHour: startHour + 0.5,
      );
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final drag = _drag;
    if (drag == null) return;
    // Grows downward only, ≥ 0.5h — `max(startH + 0.5, hourFromY(y))`.
    final hour =
        math.max(drag.startHour + 0.5, _hourFromY(details.localPosition.dy));
    if (hour != drag.currentHour) {
      setState(() => drag.currentHour = hour);
    }
  }

  void _onDragEnd() {
    final drag = _drag;
    if (drag == null) return;
    setState(() => _drag = null);
    final start = math.min(drag.startHour, drag.currentHour);
    final end = math.max(drag.startHour, drag.currentHour);
    if (end - start >= 0.5) {
      context.read<VenueScheduleBloc>().add(
            VenueScheduleEvent.dragBlockRequested(drag.venueId, start, end),
          );
    }
  }

  void _onDragCancel() {
    if (_drag != null) setState(() => _drag = null);
  }

  /// Translucent indigo band with a live `HH:MM–HH:MM` label (`.drag-band`).
  Widget _dragBand(DayDrag drag) {
    final start = math.min(drag.startHour, drag.currentHour);
    final end = math.max(drag.startHour, drag.currentHour);
    return Positioned(
      top: (start - kFirstHour) * kHourPx,
      left: 4,
      right: 4,
      height: (end - start) * kHourPx,
      child: IgnorePointer(
        child: CustomPaint(
          painter: const DragBandPainter(),
          child: Center(
            child: Text(
              '${hourLabel(start)}–${hourLabel(end)}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF3730A3),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Now line — 2px danger across the venue columns (`.day-now`)
  // ---------------------------------------------------------------------

  List<Widget> _nowLine(DateTime focusedDate) {
    final now = _now();
    final isToday = now.year == focusedDate.year &&
        now.month == focusedDate.month &&
        now.day == focusedDate.day;
    if (!isToday) return const [];
    final nowHour = now.hour + now.minute / 60;
    if (nowHour < kFirstHour || nowHour > kLastHour) return const [];
    final top = (nowHour - kFirstHour) * kHourPx;
    return [
      Positioned(
        left: kGutterWidth,
        right: 0,
        top: top,
        height: 2,
        child: const IgnorePointer(
          child: ColoredBox(color: AppColors.danger),
        ),
      ),
      // 8px dot hanging off the gutter edge (`.day-now::before`).
      Positioned(
        left: kGutterWidth - 4,
        top: top - 3,
        width: 8,
        height: 8,
        child: const IgnorePointer(
          child: DecoratedBox(
            decoration:
                BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
          ),
        ),
      ),
    ];
  }
}
