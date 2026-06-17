import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../model/models.dart';
import '../util/schedule_format.dart';
import 'day_grid_metrics.dart';

/// Pinned header row of the Day grid: a [kGutterWidth] corner cell over the
/// time gutter + one `.day-head` per venue column. Pure presentation — no
/// interaction lives here.
class DayGridHeader extends StatelessWidget {
  const DayGridHeader({super.key, required this.venues, required this.slots});

  final List<Venue> venues;

  /// All visible day slots — each head shows its venue's booked-slot count.
  final List<Slot> slots;

  @override
  Widget build(BuildContext context) {
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
                child: _DayVenueHead(
                  venue: venues[i],
                  slots: slots,
                  isLast: i == venues.length - 1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 9px venue dot + name (Sora 14/700) + sport (11 n-500) + `<N> slot`
/// (mono 11/700) — `.day-col-head`.
class _DayVenueHead extends StatelessWidget {
  const _DayVenueHead({
    required this.venue,
    required this.slots,
    required this.isLast,
  });

  final Venue venue;
  final List<Slot> slots;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
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
}

/// 17 stacked `06:00..22:00` labels, mono 10.5 n-400, right-aligned, 60px rows
/// with a top hairline (`.day-gutter .ghr`). Static — same for every day.
class DayTimeGutter extends StatelessWidget {
  const DayTimeGutter({super.key});

  @override
  Widget build(BuildContext context) {
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
}
