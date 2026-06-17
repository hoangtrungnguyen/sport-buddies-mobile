import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../model/models.dart';
import '../style/slot_state_style.dart';
import '../util/schedule_format.dart';

/// `.month-dow` — T2..CN, 7 equal columns, 11/700 `--n-500` on `--n-50`.
class MonthWeekdayHeader extends StatelessWidget {
  const MonthWeekdayHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.neutral50,
        border: Border(bottom: BorderSide(color: AppColors.neutral200)),
      ),
      child: Row(
        children: [
          for (var d = 0; d < 7; d++)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: d == 6
                      ? null
                      : const Border(
                          right: BorderSide(color: AppColors.neutral200),
                        ),
                ),
                child: Text(
                  weekdayShortLabels[d],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral500,
                    letterSpacing: 0.44, // .04em
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// `.mcell` — one heatmap day: number top-left, occupancy block bottom,
/// full-cell heat tint, hover ring, tap → Day view.
class MonthCell extends StatefulWidget {
  const MonthCell({
    super.key,
    required this.cell,
    required this.lastInRow,
    required this.compact,
    required this.onTap,
  });

  final OccupancyDay cell;
  final bool lastInRow;
  final bool compact;
  final ValueChanged<DateTime> onTap;

  @override
  State<MonthCell> createState() => _MonthCellState();
}

class _MonthCellState extends State<MonthCell> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final cell = widget.cell;
    final minHeight = widget.compact ? 70.0 : 96.0;
    final padding = widget.compact
        ? const EdgeInsets.all(6)
        : const EdgeInsets.symmetric(vertical: 9, horizontal: 10);
    final hairlines = Border(
      top: const BorderSide(color: AppColors.neutral100),
      right: widget.lastInRow
          ? BorderSide.none
          : const BorderSide(color: AppColors.neutral100),
    );

    // `.mcell.other` — other-month filler: n-50 bg, n-300 number, inert.
    if (!cell.isCurrentMonth) {
      return Container(
        constraints: BoxConstraints(minHeight: minHeight),
        padding: padding,
        decoration: BoxDecoration(
          color: AppColors.neutral50,
          border: hairlines,
        ),
        alignment: Alignment.topLeft,
        child: Text(
          '${cell.date.day}',
          style: GoogleFonts.sora(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.neutral300,
          ),
        ),
      );
    }

    final occ = cell.occupancy;
    final color = occupancyColor(occ);
    final pct = (occ * 100).round();

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => widget.onTap(cell.date),
        child: Container(
          constraints: BoxConstraints(minHeight: minHeight),
          decoration: BoxDecoration(border: hairlines),
          // Hover → 2px inset --primary ring, drawn above content/borders.
          foregroundDecoration: _hovered
              ? BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 2),
                )
              : null,
          child: Stack(
            children: [
              // `.mheat` — faint full-cell tint: occ colour @ occ×0.18+0.04.
              Positioned.fill(
                child: IgnorePointer(
                  child: ColoredBox(
                    color: color.withValues(alpha: occ * 0.18 + 0.04),
                  ),
                ),
              ),
              Padding(
                padding: padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // `.dnum` — today: 26px primary circle, white 13/700.
                    if (cell.isToday)
                      Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${cell.date.day}',
                          style: GoogleFonts.sora(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      )
                    else
                      Text(
                        '${cell.date.day}',
                        style: GoogleFonts.sora(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.neutral800,
                        ),
                      ),
                    // `.mocc` — percentage + slot count + progress bar.
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$pct%',
                              style: GoogleFonts.sora(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.neutral900,
                              ),
                            ),
                            if (!widget.compact) ...[
                              const SizedBox(width: 6),
                              Text(
                                '${cell.bookings} slot',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.neutral500,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        // `.mbar` — 6px pill: n-100 track, occ-colour fill.
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: Container(
                            height: 6,
                            color: AppColors.neutral100,
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: occ.clamp(0.0, 1.0),
                              heightFactor: 1,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// `.month-scale` — footer legend: label + 160×10 gradient pill + hint.
class MonthScaleFooter extends StatelessWidget {
  const MonthScaleFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 18),
      decoration: const BoxDecoration(
        color: AppColors.neutral50,
        border: Border(top: BorderSide(color: AppColors.neutral100)),
      ),
      child: Row(
        children: [
          Text(
            'Tỷ lệ lấp đầy',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.neutral600,
            ),
          ),
          const SizedBox(width: 10),
          // linear-gradient(90deg, #F0FDF4, #86EFAC 45%, #F59E0B 75%, #EF4444)
          Container(
            width: 160,
            height: 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(99),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFF0FDF4),
                  Color(0xFF86EFAC),
                  Color(0xFFF59E0B),
                  Color(0xFFEF4444),
                ],
                stops: [0.0, 0.45, 0.75, 1.0],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'thấp → cao',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: AppColors.neutral500,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Nhấp vào ngày để xem chi tiết',
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppColors.neutral500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
