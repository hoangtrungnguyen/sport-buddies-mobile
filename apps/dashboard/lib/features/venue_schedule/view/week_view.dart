import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../model/models.dart';
import '../style/slot_state_style.dart';
import '../util/schedule_format.dart';
import '../widgets/mouse_vertical_drag.dart';
import '../widgets/slot_block.dart' show slotHoverSaturationMatrix;
import '../widgets/sticky_grid_header.dart';

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

// ---------------------------------------------------------------------------
// Grid constants (`schedule-styles.css` `:root` + `SC_HOURS`)
// ---------------------------------------------------------------------------

/// `--hour-px` — row height per hour.
const double _hourPx = 60;

/// `--time-gutter`.
const double _gutterWidth = 64;

/// Operating hours 06:00–22:00 inclusive (`SC_HOURS` = 17 labels).
const int _firstHour = 6;
const int _hourCount = 17;

/// Body height = `SC_HOURS.length × HPX` = 1020px.
const double _bodyHeight = _hourCount * _hourPx;

/// `.week-head, .week-body { min-width: 760px; }` under the 1024px breakpoint.
const double _minGridWidth = 760;

/// `.week-col.today` faint wash — `rgba(34,197,94,.03)`.
const Color _todayColumnWash = Color(0x0822C55E);

/// `--shadow-md: 0 4px 12px rgba(17,24,39,.06)` — slot hover elevation.
const BoxShadow _shadowMd = BoxShadow(
  color: Color(0x0F111827),
  offset: Offset(0, 4),
  blurRadius: 12,
);

/// Pointer y (local to a column) → decimal hour snapped DOWN to 30 minutes.
/// Replicates `hourFromY`: `6 + Math.floor(clamp(y/HPX, 0, 17) * 2) / 2`.
double _hourFromDy(double dy) {
  final rel = (dy / _hourPx).clamp(0.0, _hourCount.toDouble());
  return _firstHour + (rel * 2).floorToDouble() / 2;
}

class _WeekViewState extends State<WeekView> {
  /// Live drag-to-block range, while the pointer is down on a column.
  ({int weekday, double startHour, double curHour})? _drag;

  void _startDrag(int weekday, DragStartDetails details) {
    final h = _hourFromDy(details.localPosition.dy);
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
      _hourFromDy(details.localPosition.dy),
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
      maxStick: _bodyHeight,
      // ---- Header: [64px corner] + 7 day cells (`.week-head`) ------------
      header: Container(
        decoration: const BoxDecoration(
          color: AppColors.neutral50,
          border: Border(bottom: BorderSide(color: AppColors.neutral200)),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: _gutterWidth,
                decoration: const BoxDecoration(
                  border: Border(
                    right: BorderSide(color: AppColors.neutral200),
                  ),
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
      ),
      // ---- Body: [64px gutter] + 7 columns (`.week-body`) ----------------
      body: SizedBox(
        height: _bodyHeight,
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
                  onEmptyTapped: (h) =>
                      widget.onEmptyCellTapped(venue.id, h, i),
                  onDragStart: (d) => _startDrag(i, d),
                  onDragUpdate: _updateDrag,
                  onDragEnd: (_) => _endDrag(),
                  onDragCancel: _cancelDrag,
                ),
              ),
          ],
        ),
      ),
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
                    width: math.max(_minGridWidth, constraints.maxWidth - 2),
                    child: grid,
                  ),
                )
              : grid,
        );
      },
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
      width: _gutterWidth,
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: AppColors.neutral200)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < _hourCount; i++)
            Container(
              height: _hourPx,
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
                '${'${_firstHour + i}'.padLeft(2, '0')}:00',
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
        onTapUp: (d) => widget.onEmptyTapped(_hourFromDy(d.localPosition.dy)),
        child: Container(
          // Keep children off the 1px right border (CSS border-box).
          padding: widget.isLast ? null : const EdgeInsets.only(right: 1),
          decoration: BoxDecoration(
            color: widget.isToday ? _todayColumnWash : null,
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
                    top: (slot.startHour - _firstHour) * _hourPx + 2,
                    // `height = max(dur × HPX − 4, 22)`.
                    height: math.max(slot.durationHours * _hourPx - 4, 22),
                    child: _WeekSlotBlock(
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
                    top: (math.min(drag.startHour, drag.curHour) - _firstHour) *
                        _hourPx,
                    height: (drag.curHour - drag.startHour).abs() * _hourPx,
                    child: _DragBand(
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
    for (var k = 1; k <= _hourCount; k++) {
      canvas.drawRect(
        Rect.fromLTWH(0, k * _hourPx - 1, size.width, 1),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_HourLinesPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Slot block — compact Week variant (`.week-col .sc-slot`)
// ---------------------------------------------------------------------------

class _WeekSlotBlock extends StatefulWidget {
  const _WeekSlotBlock({
    required this.slot,
    required this.onTap,
    this.onHoverChanged,
  });

  final Slot slot;
  final VoidCallback onTap;

  /// Hover enter/exit — lets the column raise the hovered block above its
  /// siblings (`.sc-slot:hover { z-index: 4 }`).
  final ValueChanged<bool>? onHoverChanged;

  @override
  State<_WeekSlotBlock> createState() => _WeekSlotBlockState();
}

class _WeekSlotBlockState extends State<_WeekSlotBlock> {
  bool _hovered = false;

  /// `filter: saturate(1.08)` on hover (`.sc-slot:hover`).
  Widget _saturateOnHover(Widget child) => _hovered
      ? ColorFiltered(
          colorFilter: const ColorFilter.matrix(slotHoverSaturationMatrix),
          child: child,
        )
      : child;

  @override
  Widget build(BuildContext context) {
    final slot = widget.slot;
    // Content thresholds use the raw (unclamped) `dur × HPX`, like the jsx.
    final rawHeight = slot.durationHours * _hourPx;
    final style = _hovered && slot.state == SlotState.empty
        ? emptySlotHoverStyle
        : slotStateStyles[slot.state]!;
    final showTime = rawHeight > 40;
    final showCap = slot.capacity != null && rawHeight > 30;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => _hovered = true);
        widget.onHoverChanged?.call(true);
      },
      onExit: (_) {
        setState(() => _hovered = false);
        widget.onHoverChanged?.call(false);
      },
      // Absorb MOUSE drags so drag-to-block never starts on a slot
      // (`if (e.target.closest('.sc-slot')) return` in the jsx); touch
      // pans fall through so the page stays scrollable.
      child: MouseVerticalDrag(
        onStart: (_) {},
        onUpdate: (_) {},
        child: GestureDetector(
          onTap: widget.onTap,
          child: Transform.translate(
            offset: _hovered ? const Offset(0, -1) : Offset.zero,
            child: Container(
              decoration: _hovered
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [_shadowMd],
                    )
                  : null,
              child: _saturateOnHover(CustomPaint(
                painter: _SlotDecorationPainter.fromStyle(style),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Unbounded height + clip = CSS `overflow: hidden`.
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    slotStateIcons[slot.state],
                                    size: 12,
                                    color: style.text.withValues(alpha: 0.85),
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      slot.label,
                                      style: GoogleFonts.sora(
                                        // Compact: 10.5px name (`.week-col`).
                                        fontSize: 10.5,
                                        fontWeight:
                                            slot.state == SlotState.empty
                                                ? FontWeight.w600
                                                : FontWeight.w700,
                                        height: 1.25,
                                        color: style.text,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (showTime)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    '${hourLabel(slot.startHour)}–'
                                    '${hourLabel(slot.endHour)}',
                                    style: GoogleFonts.jetBrainsMono(
                                      // Compact: 9px time (`.week-col .s-time`).
                                      fontSize: 9,
                                      height: 1.25,
                                      color: style.text.withValues(alpha: 0.85),
                                    ),
                                  ),
                                ),
                              // Compact mode: no subtitle line in Week view.
                            ],
                          ),
                        ),
                      ),
                      if (showCap)
                        Positioned(
                          right: 6,
                          bottom: 5,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xB3FFFFFF),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              // Never "0/N" — joined count has no DB column.
                              slot.capacityLabel!,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: style.text,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              )),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Drag-to-block band (`.drag-band`)
// ---------------------------------------------------------------------------

class _DragBand extends StatelessWidget {
  const _DragBand({required this.startHour, required this.endHour});

  final double startHour;
  final double endHour;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: const _SlotDecorationPainter(
          bg: Color(0x00000000),
          border: Color(0xFF6366F1),
          dashed: true,
          // 45° indigo stripes — rgba(99,102,241,.18) / rgba(99,102,241,.3).
          stripeA: Color(0x2E6366F1),
          stripeB: Color(0x4D6366F1),
          stripeBand: 6,
          stripeAngleDeg: 45,
        ),
        child: Center(
          child: Text(
            '${hourLabel(startHour)}–${hourLabel(endHour)}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF3730A3),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Slot-chrome painter — rounded 8px box, 1.5px solid/dashed border, optional
// diagonal stripes (CSS `repeating-linear-gradient`) and 3px left accent bar.
// ---------------------------------------------------------------------------

class _SlotDecorationPainter extends CustomPainter {
  const _SlotDecorationPainter({
    required this.bg,
    required this.border,
    this.dashed = false,
    this.stripeA,
    this.stripeB,
    this.stripeBand = 0,
    this.stripeAngleDeg = 0,
    this.accentLeft,
  });

  _SlotDecorationPainter.fromStyle(SlotStateStyle style)
      : this(
          bg: style.bg,
          border: style.border,
          dashed: style.dashed,
          stripeA: style.striped.colorA,
          stripeB: style.striped.colorB,
          stripeBand: style.striped.bandWidth,
          stripeAngleDeg: style.striped.angleDeg,
          accentLeft: style.accentLeft,
        );

  final Color bg;
  final Color border;
  final bool dashed;
  final Color? stripeA;
  final Color? stripeB;
  final double stripeBand;
  final double stripeAngleDeg;
  final Color? accentLeft;

  static const double _radius = 8;
  static const double _strokeWidth = 1.5;
  static const double _dashLength = 4;
  static const double _gapLength = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(_radius),
    );

    canvas.drawRRect(rrect, Paint()..color = bg);

    final stripeA = this.stripeA;
    final stripeB = this.stripeB;
    if (stripeA != null && stripeB != null && stripeBand > 0) {
      // CSS gradient angle: 0deg = up, clockwise → direction (sin a, −cos a).
      final rad = stripeAngleDeg * math.pi / 180;
      final period = Offset(math.sin(rad), -math.cos(rad)) * (stripeBand * 2);
      final paint = Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          period,
          [stripeA, stripeA, stripeB, stripeB],
          [0, 0.5, 0.5, 1],
          TileMode.repeated,
        );
      canvas.save();
      canvas.clipRRect(rrect);
      canvas.drawRect(Offset.zero & size, paint);
      canvas.restore();
    }

    final accentLeft = this.accentLeft;
    if (accentLeft != null) {
      // `.st-fixed::before` — 3px solid bar hugging the left edge.
      canvas.save();
      canvas.clipRRect(rrect);
      canvas.drawRect(
        Rect.fromLTWH(0, 0, 3, size.height),
        Paint()..color = accentLeft,
      );
      canvas.restore();
    }

    // Border strokes inside the bounds (CSS border-box).
    final borderRRect = rrect.deflate(_strokeWidth / 2);
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..color = border;
    if (!dashed) {
      canvas.drawRRect(borderRRect, borderPaint);
    } else {
      final path = Path()..addRRect(borderRRect);
      for (final metric in path.computeMetrics()) {
        var distance = 0.0;
        while (distance < metric.length) {
          canvas.drawPath(
            metric.extractPath(distance, distance + _dashLength),
            borderPaint,
          );
          distance += _dashLength + _gapLength;
        }
      }
    }
  }

  @override
  bool shouldRepaint(_SlotDecorationPainter oldDelegate) =>
      bg != oldDelegate.bg ||
      border != oldDelegate.border ||
      dashed != oldDelegate.dashed ||
      stripeA != oldDelegate.stripeA ||
      stripeB != oldDelegate.stripeB ||
      stripeBand != oldDelegate.stripeBand ||
      stripeAngleDeg != oldDelegate.stripeAngleDeg ||
      accentLeft != oldDelegate.accentLeft;
}
