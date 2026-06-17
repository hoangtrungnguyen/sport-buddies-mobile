import 'package:flutter/material.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../model/models.dart';
import '../widgets/month_grid_cells.dart';

/// Month view — occupancy heatmap (`MonthView` in `schedule-views.jsx`,
/// `.month-grid` in `schedule-styles.css`).
///
/// Pure presentational: feed it `state.monthCells` (full Mon..Sun weeks) and
/// wire [onDayTapped] to `VenueScheduleEvent.monthDayTapped(date)`.
class ScheduleMonthView extends StatelessWidget {
  const ScheduleMonthView({
    super.key,
    required this.cells,
    required this.onDayTapped,
  });

  /// Full-week heatmap cells (length is a multiple of 7, index 0 = Monday).
  final List<OccupancyDay> cells;

  /// Tap a current-month day → jump to Day view for that date.
  final ValueChanged<DateTime> onDayTapped;

  @override
  Widget build(BuildContext context) {
    // ≤640px: cells shrink to 70px / 6px padding, "N slot" sublabel hides.
    final compact = MediaQuery.sizeOf(context).width <= 640;
    final weeks = <List<OccupancyDay>>[
      for (var i = 0; i + 7 <= cells.length; i += 7) cells.sublist(i, i + 7),
    ];
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.neutral200),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const MonthWeekdayHeader(),
          for (final week in weeks)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var d = 0; d < 7; d++)
                    Expanded(
                      child: MonthCell(
                        cell: week[d],
                        lastInRow: d == 6,
                        compact: compact,
                        onTap: onDayTapped,
                      ),
                    ),
                ],
              ),
            ),
          const MonthScaleFooter(),
        ],
      ),
    );
  }
}
