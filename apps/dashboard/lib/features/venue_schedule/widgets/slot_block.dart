import 'dart:math' as math;

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
            painter: SlotDecorationPainter(style: style),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  // Natural-height content, clipped by the box (`overflow:
                  // hidden`) instead of erroring when the slot is short.
                  Positioned.fill(
                    child: OverflowBox(
                      alignment: Alignment.topLeft,
                      minHeight: 0,
                      maxHeight: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 8,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _nameRow(slot, style),
                            if (showTime)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  '${hourLabel(slot.startHour)}–'
                                  '${hourLabel(slot.endHour)}',
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
                  ),
                  if (showCapacity)
                    Positioned(
                      right: 6,
                      bottom: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          // rgba(255,255,255,.7)
                          color: const Color(0xB3FFFFFF),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          // Never "0/N" — joined count has no DB column yet.
                          slot.capacityLabel!,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: style.text,
                            height: 1.25,
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

/// Paints a [SlotStateStyle] box: tinted (or diagonally striped) fill, 1.5px
/// solid/dashed border, optional 3px left accent bar — all inside a rounded
/// rect of [radius]. Shared by [SlotBlock] and the legend swatches.
class SlotDecorationPainter extends CustomPainter {
  const SlotDecorationPainter({
    required this.style,
    this.radius = 8,
    this.borderWidth = 1.5,
  });

  final SlotStateStyle style;
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

    // Base coat — for striped states this is the lighter band colour.
    canvas.drawRRect(rrect, Paint()..color = style.bg);

    if (style.striped != SlotStripe.none) {
      _paintStripes(canvas, rrect, style.striped);
    }

    // 3px left accent bar (`.st-fixed::before`), clipped by the radius.
    final accent = style.accentLeft;
    if (accent != null) {
      canvas
        ..save()
        ..clipRRect(rrect)
        ..drawRect(
          Rect.fromLTWH(0, 0, 3, size.height),
          Paint()..color = accent,
        )
        ..restore();
    }

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..color = style.border;
    final borderRRect = rrect.deflate(borderWidth / 2);
    if (style.dashed) {
      canvas.drawPath(_dashedRRectPath(borderRRect), borderPaint);
    } else {
      canvas.drawRRect(borderRRect, borderPaint);
    }
  }

  /// `repeating-linear-gradient(<angle>, A 0..w, B w..2w)` — paints the B
  /// bands over the base coat at the stripe's CSS angle.
  void _paintStripes(Canvas canvas, RRect rrect, SlotStripe stripe) {
    final rect = rrect.outerRect;
    canvas
      ..save()
      ..clipRRect(rrect)
      ..translate(rect.center.dx, rect.center.dy)
      // CSS angle is clockwise from north; canvas rotation is from +x.
      ..rotate((stripe.angleDeg - 90) * math.pi / 180);

    // Over-cover the rotated area in both axes.
    final reach = rect.size.longestSide;
    final period = stripe.bandWidth * 2;
    final bandPaint = Paint()..color = stripe.colorB!;
    for (var x = -(reach / period).ceil() * period; x < reach; x += period) {
      canvas.drawRect(
        Rect.fromLTRB(x + stripe.bandWidth, -reach, x + period, reach),
        bandPaint,
      );
    }
    canvas.restore();
  }

  Path _dashedRRectPath(RRect rrect) {
    final source = Path()..addRRect(rrect);
    final dashed = Path();
    for (final metric in source.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        dashed.addPath(
          metric.extractPath(
            distance,
            math.min(distance + _dashLength, metric.length),
          ),
          Offset.zero,
        );
        distance += _dashLength + _gapLength;
      }
    }
    return dashed;
  }

  @override
  bool shouldRepaint(SlotDecorationPainter oldDelegate) =>
      oldDelegate.style != style ||
      oldDelegate.radius != radius ||
      oldDelegate.borderWidth != borderWidth;
}
