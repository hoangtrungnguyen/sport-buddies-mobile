import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../model/models.dart';
import '../style/slot_state_style.dart';
import '../util/schedule_format.dart';
import 'mouse_vertical_drag.dart';
import 'slot_block.dart' show slotHoverSaturationMatrix;
import 'week_grid_metrics.dart';

class WeekSlotBlock extends StatefulWidget {
  const WeekSlotBlock({super.key, 
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
  State<WeekSlotBlock> createState() => _WeekSlotBlockState();
}

class _WeekSlotBlockState extends State<WeekSlotBlock> {
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
    final rawHeight = slot.durationHours * kHourPx;
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
                      boxShadow: const [kSlotHoverShadow],
                    )
                  : null,
              child: _saturateOnHover(CustomPaint(
                painter: SlotDecorationPainter.fromStyle(style),
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

class DragBand extends StatelessWidget {
  const DragBand({super.key, required this.startHour, required this.endHour});

  final double startHour;
  final double endHour;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: const SlotDecorationPainter(
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
  });

  SlotDecorationPainter.fromStyle(SlotStateStyle style)
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
  bool shouldRepaint(SlotDecorationPainter oldDelegate) =>
      bg != oldDelegate.bg ||
      border != oldDelegate.border ||
      dashed != oldDelegate.dashed ||
      stripeA != oldDelegate.stripeA ||
      stripeB != oldDelegate.stripeB ||
      stripeBand != oldDelegate.stripeBand ||
      stripeAngleDeg != oldDelegate.stripeAngleDeg ||
      accentLeft != oldDelegate.accentLeft;
}
