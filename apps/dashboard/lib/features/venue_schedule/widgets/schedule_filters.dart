import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../bloc/venue_schedule_state.dart';
import '../model/models.dart';
import '../style/slot_state_style.dart';

/// The two filter rows of the "Lịch sân" screen (`.sc-filters`):
///
/// - Row 1 — "MÔN" sport chips (multi-toggle; empty set ⇒ all, rendered
///   all-ACTIVE like the prototype's full default set), plus, in Week view,
///   "SÂN" venue chips (single-select, coloured dot — ALL venues, so the
///   selection never disappears under a sport filter). Far right: the muted
///   drag hint "Kéo trên lưới để khoá giờ".
/// - Row 2 — "TRẠNG THÁI" chips, one per [SlotState], each with a 10px
///   state-coloured swatch (multi-toggle; empty set ⇒ all, all-active).
///
/// Pure presentational — wire the callbacks to `sportFilterToggled`,
/// `venueSelected` and `stateFilterToggled`.
class ScheduleFilters extends StatelessWidget {
  const ScheduleFilters({
    super.key,
    required this.state,
    required this.onSportToggled,
    required this.onVenueSelected,
    required this.onStateToggled,
  });

  final VenueScheduleState state;
  final ValueChanged<SportType> onSportToggled;

  /// Week-view "SÂN" chip tapped — receives the venue id.
  final ValueChanged<String> onVenueSelected;
  final ValueChanged<SlotState> onStateToggled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const _FilterLabel('MÔN'),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final sport in SportType.values)
                        _FilterChip(
                          label: sport.label,
                          // Empty set ≡ "all" — render every chip active,
                          // like the prototype's full default set.
                          active: state.sportFilter.isEmpty ||
                              state.sportFilter.contains(sport),
                          onTap: () => onSportToggled(sport),
                        ),
                    ],
                  ),
                  if (state.view == ScheduleView.week) ...[
                    const _FilterLabel('SÂN'),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        // ALL venues (prototype `SC_COURTS.map`) — the sport
                        // filter must not hide the selected venue's chip.
                        for (final venue in state.venues)
                          _FilterChip(
                            label: venue.name,
                            active: venue.id == state.selectedVenueId,
                            leading: _VenueDot(color: Color(venue.colorValue)),
                            onTap: () => onVenueSelected(venue.id),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            const _DragTip(),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const _FilterLabel('TRẠNG THÁI'),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                // Only states real data can produce; fixed/open/private stay
                // gated until matchmaking exists (TODO BCORE-321/326).
                for (final slotState in SlotState.values)
                  if (kMatchmakingEnabled ||
                      !kMatchmakingOnlyStates.contains(slotState))
                    _FilterChip(
                      label: slotStateShortLabels[slotState]!,
                      active: state.stateFilter.isEmpty ||
                          state.stateFilter.contains(slotState),
                      leading: _StateSwatch(style: slotStateStyles[slotState]!),
                      onTap: () => onStateToggled(slotState),
                    ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// `.sc-filters .label` — uppercase 11/700 `--n-400`, 0.06em tracking.
class _FilterLabel extends StatelessWidget {
  const _FilterLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.66, // 0.06em × 11px
        color: AppColors.neutral400,
      ),
    );
  }
}

/// `.fchip` — white pill, 1px `--n-200`, 7×13 padding, 12.5/600 `--n-700`;
/// hover `--n-50` bg + `--n-300` border; active `--n-900` bg, white text.
class _FilterChip extends StatefulWidget {
  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
    this.leading,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  /// Venue dot or state swatch shown before the label.
  final Widget? leading;

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color border;
    if (widget.active) {
      bg = AppColors.neutral900;
      border = AppColors.neutral900;
    } else if (_hovered) {
      bg = AppColors.neutral50;
      border = AppColors.neutral300;
    } else {
      bg = Colors.white;
      border = AppColors.neutral200;
    }
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.leading != null) ...[
                widget.leading!,
                const SizedBox(width: 6),
              ],
              Text(
                widget.label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: widget.active ? Colors.white : AppColors.neutral700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// `.fchip .dot` — 8px coloured venue dot.
class _VenueDot extends StatelessWidget {
  const _VenueDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// `.fchip .sw` — 10px state swatch: state bg (striped for `empty`/`locked`),
/// 1.5px state border, dashed for the dashed states.
class _StateSwatch extends StatelessWidget {
  const _StateSwatch({required this.style});

  final SlotStateStyle style;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size.square(10),
      painter: _SwatchPainter(style),
    );
  }
}

/// Paints the tiny rounded swatch: solid/striped fill + solid/dashed border.
class _SwatchPainter extends CustomPainter {
  const _SwatchPainter(this.style);

  final SlotStateStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(3));

    // Fill — base coat, then diagonal colorB bands for striped states.
    canvas.save();
    canvas.clipRRect(rrect);
    canvas.drawRect(rect, Paint()..color = style.bg);
    final stripe = style.striped;
    if (stripe != SlotStripe.none) {
      canvas.drawRect(rect, Paint()..color = stripe.colorA!);
      final bandPaint = Paint()..color = stripe.colorB!;
      final reach = rect.longestSide; // covers the box at any angle
      canvas.translate(rect.center.dx, rect.center.dy);
      canvas.rotate(stripe.angleDeg * math.pi / 180);
      for (var x = -reach; x < reach; x += stripe.bandWidth * 2) {
        canvas.drawRect(
          Rect.fromLTWH(x, -reach, stripe.bandWidth, reach * 2),
          bandPaint,
        );
      }
    }
    canvas.restore();

    // Border — 1.5px, inset so the stroke stays inside the 10px box.
    final borderPaint = Paint()
      ..color = style.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final borderRRect = rrect.deflate(0.75);
    if (!style.dashed) {
      canvas.drawRRect(borderRRect, borderPaint);
      return;
    }
    final path = Path()..addRRect(borderRRect);
    for (final metric in path.computeMetrics()) {
      const dash = 3.0;
      const gap = 2.5;
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(
              distance, math.min(distance + dash, metric.length)),
          borderPaint,
        );
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_SwatchPainter oldDelegate) => oldDelegate.style != style;
}

/// `.drag-tip` — muted hint "⤧ Kéo trên lưới để khoá giờ".
class _DragTip extends StatelessWidget {
  const _DragTip();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.open_with, size: 14, color: AppColors.neutral400),
        const SizedBox(width: 7),
        Text(
          'Kéo trên lưới để khoá giờ',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.neutral500,
          ),
        ),
      ],
    );
  }
}
