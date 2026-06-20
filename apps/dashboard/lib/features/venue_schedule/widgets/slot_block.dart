import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../model/models.dart';
import '../style/slot_state_style.dart';
import '../util/schedule_format.dart';

/// `.sc-slot:hover { filter: saturate(1.08) }` — colour-matrix equivalent
/// (CSS/SVG saturate with Rec. 709 luma weights, s = 1.08). Shared by the
/// Day [SlotBlock] and the Week view's compact slot block.
const List<double> slotHoverSaturationMatrix = [
  1.06296, -0.05720, -0.00576, 0, 0, //
  -0.01704, 1.02280, -0.00576, 0, 0, //
  -0.01704, -0.05720, 1.07424, 0, 0, //
  0, 0, 0, 1, 0,
];

/// The core repeated card of the Day & Week grids (`SlotBlock` / `.sc-slot`
/// in the handoff) — a coloured, rounded, state-styled box.
///
/// The CALLER positions it absolutely inside its venue/day column
/// (`top = (startHour − 6) × 60 + 2`, left/right inset 4px Day / 3px Week)
/// and passes the raw track [height] (`durationHours × 60`). Exactly like the
/// prototype, the widget clamps the rendered box to `max(height − 4, 22)` but
/// gates its contents on the RAW [height]:
/// - time row only if `height > 40`,
/// - subtitle only if `height > 56` (and not [compact]),
/// - capacity badge only if `height > 30`.
///
/// Hover: lifts 1px + `--shadow-md` + saturate(1.08); an `empty` slot
/// additionally swaps to the primary-tinted [emptySlotHoverStyle]
/// (`.st-empty:hover`).
class SlotBlock extends StatefulWidget {
  const SlotBlock({
    super.key,
    required this.slot,
    required this.height,
    this.compact = false,
    required this.onTap,
    this.onHoverChanged,
  });

  final Slot slot;

  /// Raw track height in logical px — `slot.durationHours × 60`.
  final double height;

  /// Week-view mode: 10.5px name / 9px time, subtitle line suppressed.
  final bool compact;

  /// Tap anywhere on the block — dispatch
  /// `VenueScheduleEvent.slotTapped(slot)`.
  final VoidCallback onTap;

  /// Hover enter/exit — lets the parent column raise the hovered block
  /// above its siblings (`.sc-slot:hover { z-index: 4 }`).
  final ValueChanged<bool>? onHoverChanged;

  @override
  State<SlotBlock> createState() => _SlotBlockState();
}

class _SlotBlockState extends State<SlotBlock> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final slot = widget.slot;
    // `.st-empty:hover` swaps the whole palette to primary tints.
    final style = slot.state == SlotState.empty && _hovered
        ? emptySlotHoverStyle
        : slotStateStyles[slot.state]!;
    final boxHeight = math.max(widget.height - 4, 22.0);
    final showTime = widget.height > 40;
    final showSubtitle =
        !widget.compact && widget.height > 56 && slot.subtitle != null;
    final showCapacity = slot.capacity != null && widget.height > 30;

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
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        // transform/box-shadow transition 90ms ease.
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          curve: Curves.ease,
          height: boxHeight,
          transform: Matrix4.translationValues(0, _hovered ? -1 : 0, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: _hovered
                ? const [
                    // --shadow-md: 0 4px 12px rgba(17,24,39,.06)
                    BoxShadow(
                      color: Color(0x0F111827),
                      offset: Offset(0, 4),
                      blurRadius: 12,
                    ),
                  ]
                : const <BoxShadow>[],
          ),
          child: _saturateOnHover(CustomPaint(
            painter: SlotDecorationPainter.fromStyle(style),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  _content(slot, style,
                      showTime: showTime, showSubtitle: showSubtitle),
                  if (showCapacity) _capacityBadge(slot, style),
                ],
              ),
            ),
          )),
        ),
      ),
    );
  }

  /// `filter: saturate(1.08)` on hover — wrapped conditionally so the
  /// colour-filter layer only exists while hovering.
  Widget _saturateOnHover(Widget child) => _hovered
      ? ColorFiltered(
          colorFilter: const ColorFilter.matrix(slotHoverSaturationMatrix),
          child: child,
        )
      : child;

  /// Natural-height content (name + optional time + optional subtitle),
  /// clipped by the box (`overflow: hidden`) instead of erroring when the
  /// slot is short.
  Widget _content(
    Slot slot,
    SlotStateStyle style, {
    required bool showTime,
    required bool showSubtitle,
  }) {
    return Positioned.fill(
      child: OverflowBox(
        alignment: Alignment.topLeft,
        minHeight: 0,
        maxHeight: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _nameRow(slot, style),
              if (showTime)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    '${hourLabel(slot.startHour)}–${hourLabel(slot.endHour)}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: widget.compact ? 9 : 10,
                      color: style.text.withValues(alpha: 0.85),
                      height: 1.25,
                    ),
                  ),
                ),
              if (showSubtitle)
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Text(
                    slot.subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      color: style.text.withValues(alpha: 0.8),
                      height: 1.25,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bottom-right capacity pill ("tối đa N" — never "0/N").
  Widget _capacityBadge(Slot slot, SlotStateStyle style) {
    return Positioned(
      right: 6,
      bottom: 5,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          // rgba(255,255,255,.7)
          color: const Color(0xB3FFFFFF),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          slot.capacityLabel!,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            color: style.text,
            height: 1.25,
          ),
        ),
      ),
    );
  }

  /// State icon (12px, 0.85 opacity) + slot label.
  Widget _nameRow(Slot slot, SlotStateStyle style) {
    return Row(
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
              fontSize: widget.compact ? 10.5 : 11.5,
              // `.st-empty .s-name { font-weight: 600 }` — lighter than the
              // 700 of every other state.
              fontWeight: slot.state == SlotState.empty
                  ? FontWeight.w600
                  : FontWeight.w700,
              color: style.text,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}

/// Paints slot chrome: a tinted (or diagonally striped) fill, a 1.5px
/// solid/dashed border, and an optional 3px left accent bar — all inside a
/// rounded rect of [radius]. THE canonical slot painter, shared by the Day
/// [SlotBlock], the Week view's compact block, the drag-to-block band, and the
/// legend swatches.
///
/// Two ways to build it: raw colours (the drag band passes its own indigo
/// stripes) or [SlotDecorationPainter.fromStyle] for a [SlotStateStyle]. The
/// stripes replicate CSS `repeating-linear-gradient(<angle>, A 0..w, B w..2w)`
/// via a repeated linear-gradient shader — both A and B bands are painted, so
/// styles where A == bg (every striped slot state) and the two-tone drag band
/// both render correctly.
class SlotDecorationPainter extends CustomPainter {
  const SlotDecorationPainter({
    required this.bg,
    required this.border,
    this.dashed = false,
    this.stripeA,
    this.stripeB,
    this.stripeBand = 0,
    this.stripeAngleDeg = 0,
    this.accentLeft,
    this.radius = 8,
    this.borderWidth = 1.5,
  });

  /// Build from a [SlotStateStyle]; [radius]/[borderWidth] override the box
  /// metrics (e.g. the 4px legend swatches).
  SlotDecorationPainter.fromStyle(
    SlotStateStyle style, {
    double radius = 8,
    double borderWidth = 1.5,
  }) : this(
          bg: style.bg,
          border: style.border,
          dashed: style.dashed,
          stripeA: style.striped.colorA,
          stripeB: style.striped.colorB,
          stripeBand: style.striped.bandWidth,
          stripeAngleDeg: style.striped.angleDeg,
          accentLeft: style.accentLeft,
          radius: radius,
          borderWidth: borderWidth,
        );

  final Color bg;
  final Color border;
  final bool dashed;
  final Color? stripeA;
  final Color? stripeB;
  final double stripeBand;
  final double stripeAngleDeg;
  final Color? accentLeft;
  final double radius;
  final double borderWidth;

  static const double _dashLength = 4;
  static const double _gapLength = 3;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    canvas.drawRRect(rrect, Paint()..color = bg);
    _paintStripes(canvas, rrect, size);
    _paintAccent(canvas, rrect, size);
    _paintBorder(canvas, rrect);
  }

  /// Diagonal two-tone stripe overlay (CSS `repeating-linear-gradient`),
  /// clipped to the rounded rect. No-op unless both stripe colours and a band
  /// width are set.
  void _paintStripes(Canvas canvas, RRect rrect, Size size) {
    final stripeA = this.stripeA;
    final stripeB = this.stripeB;
    if (stripeA == null || stripeB == null || stripeBand <= 0) return;
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
    canvas
      ..save()
      ..clipRRect(rrect)
      ..drawRect(Offset.zero & size, paint)
      ..restore();
  }

  /// 3px left accent bar (`.st-fixed::before`), clipped by the radius.
  void _paintAccent(Canvas canvas, RRect rrect, Size size) {
    final accentLeft = this.accentLeft;
    if (accentLeft == null) return;
    canvas
      ..save()
      ..clipRRect(rrect)
      ..drawRect(
        Rect.fromLTWH(0, 0, 3, size.height),
        Paint()..color = accentLeft,
      )
      ..restore();
  }

  /// Solid or dashed rounded border, inset by half the stroke so it sits
  /// inside the fill.
  void _paintBorder(Canvas canvas, RRect rrect) {
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..color = border;
    final borderRRect = rrect.deflate(borderWidth / 2);
    if (!dashed) {
      canvas.drawRRect(borderRRect, borderPaint);
      return;
    }
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

  @override
  bool shouldRepaint(SlotDecorationPainter oldDelegate) =>
      bg != oldDelegate.bg ||
      border != oldDelegate.border ||
      dashed != oldDelegate.dashed ||
      stripeA != oldDelegate.stripeA ||
      stripeB != oldDelegate.stripeB ||
      stripeBand != oldDelegate.stripeBand ||
      stripeAngleDeg != oldDelegate.stripeAngleDeg ||
      accentLeft != oldDelegate.accentLeft ||
      radius != oldDelegate.radius ||
      borderWidth != oldDelegate.borderWidth;
}
