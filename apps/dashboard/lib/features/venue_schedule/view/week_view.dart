import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../model/models.dart';
import '../util/schedule_format.dart';
import '../widgets/mouse_vertical_drag.dart';
import '../widgets/sticky_grid_header.dart';
import '../widgets/week_grid_metrics.dart';
import '../widgets/week_slot_block.dart';

/// Week view of the "Lịch sân" screen — ONE venue across a Monday-based week
/// (`WeekView` in `schedule-views.jsx`, `.week-grid` in `schedule-styles.css`).
///
/// Pure presentational: pass state slices + callbacks.
/// - [venue]     → `state.selectedVenue` (renders nothing while null)
/// - [slots]     → `state.visibleWeekSlots` (state filter already applied)
/// - [weekStart] → `state.weekStart` (Monday, date-only)
///
/// Interactions (wire to `VenueScheduleBloc` events):
/// - tap a slot block        → [onSlotTapped] → `slotTapped(slot)`
/// - tap empty grid area     → [onEmptyCellTapped] →
///   `emptyCellTapped(venueId, snappedHour, weekday: weekday)`
/// - vertical drag ≥ 0.5h    → [onDragBlockRequested] →
///   `dragBlockRequested(venueId, startHour, endHour, weekday: weekday)`
///
/// Below 1024px the grid scrolls horizontally (min content width 760px).
class WeekView extends StatefulWidget {
  const WeekView({
    super.key,
    required this.venue,
    required this.slots,
    required this.weekStart,
    required this.onSlotTapped,
    required this.onEmptyCellTapped,
    required this.onDragBlockRequested,
    this.now,
  });

  /// The venue the week is scoped to (`state.selectedVenue`).
  final Venue? venue;

  /// The venue's week slots, state-filtered (`state.visibleWeekSlots`).
  /// Positioned by [Slot.weekday] (0 = Mon … 6 = Sun).
  final List<Slot> slots;

  /// Monday midnight of the shown week (`state.weekStart`).
  final DateTime weekStart;

  final ValueChanged<Slot> onSlotTapped;

  /// `(venueId, snappedHour, weekday)` — empty grid area tapped.
  final void Function(String venueId, double startHour, int weekday)
      onEmptyCellTapped;

  /// `(venueId, startHour, endHour, weekday)` — drag-to-block released.
  final void Function(
    String venueId,
    double startHour,
    double endHour,
    int weekday,
  ) onDragBlockRequested;

  /// Injectable clock for the today highlight; defaults to `DateTime.now()`.
  final DateTime? now;

  @override
  State<WeekView> createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView> {
  /// Live drag-to-block range, while the pointer is down on a column.
  ({int weekday, double startHour, double curHour})? _drag;

  void _startDrag(int weekday, DragStartDetails details) {
    final h = hourFromDy(details.localPosition.dy);
    setState(
      () => _drag = (weekday: weekday, startHour: h, curHour: h + 0.5),
    );
  }

  void _updateDrag(DragUpdateDetails details) {
    final drag = _drag;
    if (drag == null) return;
    // Band only extends downward, min 0.5h — `Math.max(startH + 0.5, …)`.
    final h = math.max(
      drag.startHour + 0.5,
      hourFromDy(details.localPosition.dy),
    );
    setState(
      () => _drag =
          (weekday: drag.weekday, startHour: drag.startHour, curHour: h),
    );
  }

  void _endDrag() {
    final drag = _drag;
    if (drag == null) return;
    setState(() => _drag = null);
    final a = math.min(drag.startHour, drag.curHour);
    final b = math.max(drag.startHour, drag.curHour);
    if (b - a >= 0.5) {
      widget.onDragBlockRequested(widget.venue!.id, a, b, drag.weekday);
    }
  }

  void _cancelDrag() {
    if (_drag != null) setState(() => _drag = null);
  }

  @override
  Widget build(BuildContext context) {
    final venue = widget.venue;
    if (venue == null) return const SizedBox.shrink();

    final now = widget.now ?? DateTime.now();
    final dates = List.generate(
      7,
      (i) => DateTime(
        widget.weekStart.year,
        widget.weekStart.month,
        widget.weekStart.day + i,
      ),
    );

    bool isToday(DateTime d) =>
        d.year == now.year && d.month == now.month && d.day == now.day;

    // Header + body with `.week-head { position: sticky; top: 0 }` — the
    // day-cells row pins to the viewport top while the page scrolls the
    // 1020px grid.
    final grid = StickyGridHeader(
      maxStick: kBodyHeight,
      header: _weekHeader(dates, isToday),
      body: _weekBody(venue, dates, isToday),
    );

    // `.week-grid` card; under 1024px it scrolls horizontally (min 760px).
    return LayoutBuilder(
      builder: (context, constraints) {
        final needsScroll = constraints.maxWidth < 1024;
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.neutral200),
            borderRadius: BorderRadius.circular(14),
          ),
          child: needsScroll
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: math.max(kMinGridWidth, constraints.maxWidth - 2),
                    child: grid,
                  ),
                )
              : grid,
        );
      },
    );
  }

  /// Sticky header: [64px corner] + 7 day cells (`.week-head`).
  Widget _weekHeader(List<DateTime> dates, bool Function(DateTime) isToday) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.neutral50,
        border: Border(bottom: BorderSide(color: AppColors.neutral200)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: kGutterWidth,
              decoration: const BoxDecoration(
                border:
                    Border(right: BorderSide(color: AppColors.neutral200)),
              ),
            ),
            for (var i = 0; i < 7; i++)
              Expanded(
                child: _WeekDayHeaderCell(
                  dow: weekdayShortLabels[i],
                  dayOfMonth: dates[i].day,
                  isToday: isToday(dates[i]),
                  isLast: i == 6,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Scrollable body: [64px gutter] + 7 day columns (`.week-body`).
  Widget _weekBody(
    Venue venue,
    List<DateTime> dates,
    bool Function(DateTime) isToday,
  ) {
    return SizedBox(
      height: kBodyHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _TimeGutter(),
          for (var i = 0; i < 7; i++)
            Expanded(
              child: _WeekDayColumn(
                isToday: isToday(dates[i]),
                isLast: i == 6,
                slots: widget.slots
                    .where((s) => s.weekday == i)
                    .toList(growable: false),
                drag: _drag != null && _drag!.weekday == i
                    ? (startHour: _drag!.startHour, curHour: _drag!.curHour)
                    : null,
                onSlotTapped: widget.onSlotTapped,
                onEmptyTapped: (h) => widget.onEmptyCellTapped(venue.id, h, i),
                onDragStart: (d) => _startDrag(i, d),
                onDragUpdate: _updateDrag,
                onDragEnd: (_) => _endDrag(),
                onDragCancel: _cancelDrag,
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header day cell (`.week-dcell`)
// ---------------------------------------------------------------------------

class _WeekDayHeaderCell extends StatelessWidget {
  const _WeekDayHeaderCell({
    required this.dow,
    required this.dayOfMonth,
    required this.isToday,
    required this.isLast,
  });

  final String dow;
  final int dayOfMonth;
  final bool isToday;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: isToday ? AppColors.primaryLight : null,
        border: isLast
            ? null
            : const Border(right: BorderSide(color: AppColors.neutral200)),
      ),
      child: Column(
        children: [
          Text(
            dow,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.44, // .04em
              color: isToday ? AppColors.primaryDark : AppColors.neutral500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$dayOfMonth',
            style: GoogleFonts.sora(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: isToday ? AppColors.primaryDark : AppColors.neutral900,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Time gutter (`.day-gutter` — shared mechanics with Day view)
// ---------------------------------------------------------------------------

class _TimeGutter extends StatelessWidget {
  const _TimeGutter();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: kGutterWidth,
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: AppColors.neutral200)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < kHourCount; i++)
            Container(
              height: kHourPx,
              alignment: Alignment.topRight,
              padding: const EdgeInsets.fromLTRB(8, 3, 8, 0),
              decoration: i == 0
                  ? null
                  : const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppColors.neutral100),
                      ),
                    ),
              child: Text(
                '${'${kFirstHour + i}'.padLeft(2, '0')}:00',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10.5,
                  color: AppColors.neutral400,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Weekday column (`.week-col`)
// ---------------------------------------------------------------------------

class _WeekDayColumn extends StatefulWidget {
  const _WeekDayColumn({
    required this.isToday,
    required this.isLast,
    required this.slots,
    required this.drag,
    required this.onSlotTapped,
    required this.onEmptyTapped,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onDragCancel,
  });

  final bool isToday;
  final bool isLast;

  /// This weekday's slots only.
  final List<Slot> slots;

  /// Live drag range when the drag started on this column.
  final ({double startHour, double curHour})? drag;

  final ValueChanged<Slot> onSlotTapped;
  final ValueChanged<double> onEmptyTapped;
  final GestureDragStartCallback onDragStart;
  final GestureDragUpdateCallback onDragUpdate;
  final GestureDragEndCallback onDragEnd;
  final VoidCallback onDragCancel;

  @override
  State<_WeekDayColumn> createState() => _WeekDayColumnState();
}

class _WeekDayColumnState extends State<_WeekDayColumn> {
  /// Hovered slot id — its block is reordered last so it paints above
  /// siblings (`.sc-slot:hover { z-index: 4 }`).
  String? _hoveredSlotId;

  @override
  Widget build(BuildContext context) {
    final drag = widget.drag;
    final ordered = [...widget.slots];
    final hoveredIndex = ordered.indexWhere((s) => s.id == _hoveredSlotId);
    if (hoveredIndex != -1) ordered.add(ordered.removeAt(hoveredIndex));
    // Drag-to-block is mouse-only so touch pans keep scrolling the page.
    return MouseVerticalDrag(
      onStart: widget.onDragStart,
      onUpdate: widget.onDragUpdate,
      onEnd: widget.onDragEnd,
      onCancel: widget.onDragCancel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (d) => widget.onEmptyTapped(hourFromDy(d.localPosition.dy)),
        child: Container(
          // Keep children off the 1px right border (CSS border-box).
          padding: widget.isLast ? null : const EdgeInsets.only(right: 1),
          decoration: BoxDecoration(
            color: widget.isToday ? kTodayColumnWash : null,
            border: widget.isLast
                ? null
                : const Border(right: BorderSide(color: AppColors.neutral200)),
          ),
          child: CustomPaint(
            painter: const _HourLinesPainter(),
            child: Stack(
              children: [
                for (final slot in ordered)
                  Positioned(
                    key: ValueKey(slot.id),
                    // `top = (start − 6) × HPX + 2` — inset 3px in Week view.
                    left: 3,
                    right: 3,
                    top: (slot.startHour - kFirstHour) * kHourPx + 2,
                    // `height = max(dur × HPX − 4, 22)`.
                    height: math.max(slot.durationHours * kHourPx - 4, 22),
                    child: WeekSlotBlock(
                      slot: slot,
                      onTap: () => widget.onSlotTapped(slot),
                      onHoverChanged: (hovered) => setState(() {
                        if (hovered) {
                          _hoveredSlotId = slot.id;
                        } else if (_hoveredSlotId == slot.id) {
                          _hoveredSlotId = null;
                        }
                      }),
                    ),
                  ),
                if (drag != null)
                  Positioned(
                    left: 4,
                    right: 4,
                    top: (math.min(drag.startHour, drag.curHour) - kFirstHour) *
                        kHourPx,
                    height: (drag.curHour - drag.startHour).abs() * kHourPx,
                    child: DragBand(
                      startHour: math.min(drag.startHour, drag.curHour),
                      endHour: math.max(drag.startHour, drag.curHour),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints the 1px `--n-100` gridline closing each 60px hour row
/// (the `repeating-linear-gradient` background of `.week-col`).
class _HourLinesPainter extends CustomPainter {
  const _HourLinesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.neutral100;
    for (var k = 1; k <= kHourCount; k++) {
      canvas.drawRect(
        Rect.fromLTWH(0, k * kHourPx - 1, size.width, 1),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_HourLinesPainter oldDelegate) => false;
}
