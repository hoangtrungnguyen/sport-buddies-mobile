import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../bloc/venue_schedule_state.dart';
import '../model/models.dart';
import 'schedule_toolbar_controls.dart';

/// Fallback bookable hours per venue per day (06:00 → 22:00) — used in the
/// Day-view "lấp đầy" denominator only when a court has no parseable
/// operating window (same fallback as the Month-view occupancy).
const int _fallbackHoursPerDay = 16;

/// States whose hours count as occupied in the "lấp đầy" percentage — the
/// customer-occupied set, matching the Month-view busy definition
/// (booked + pending).
const Set<SlotState> _occupiedStates = {
  SlotState.confirmed,
  SlotState.pending,
  SlotState.fixed,
};

/// Toolbar row of the "Lịch sân" screen (`.sc-toolbar`): date navigator pill,
/// "Hôm nay", the Ngày/Tuần/Tháng segmented switcher and right-aligned stats.
///
/// Pure presentational — takes the bloc [state] plus callbacks; wire
/// [onPrev]/[onNext] to `dateMoved(∓1)`, [onToday] to `todayPressed()` and
/// [onViewChanged] to `viewChanged(view)`.
class ScheduleToolbar extends StatelessWidget {
  const ScheduleToolbar({
    super.key,
    required this.state,
    required this.onPrev,
    required this.onNext,
    required this.onToday,
    required this.onViewChanged,
  });

  final VenueScheduleState state;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onToday;
  final ValueChanged<ScheduleView> onViewChanged;

  @override
  Widget build(BuildContext context) {
    final dateNav =
        ScheduleDateNav(label: _dateLabel(), onPrev: onPrev, onNext: onNext);
    final today = ScheduleTodayButton(onPressed: onToday);
    final viewSwitch =
        ScheduleViewSwitch(active: state.view, onChanged: onViewChanged);
    final stats = _stats();

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 880) {
          // Narrow: let the row wrap like the prototype's flex-wrap.
          return Wrap(
            spacing: 12,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [dateNav, today, viewSwitch, stats],
          );
        }
        return Row(
          children: [
            dateNav,
            const SizedBox(width: 12),
            today,
            const SizedBox(width: 16), // 12px gap + 4px marginLeft
            viewSwitch,
            const Spacer(),
            stats,
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Date label — computed from the focused date, per active view
  // ---------------------------------------------------------------------------

  static String _dd(int n) => n.toString().padLeft(2, '0');

  /// Full Vietnamese weekday name — "Thứ 2" … "Thứ 7", Sunday "Chủ nhật".
  static String _weekdayName(DateTime d) =>
      d.weekday == DateTime.sunday ? 'Chủ nhật' : 'Thứ ${d.weekday + 1}';

  /// Prototype copy (`labels` / `MONTH_LABEL` in `schedule-page.jsx`):
  /// Day `"Thứ 5 · 14/05/2026"` · Week `"11 — 17 / 05 / 2026"` ·
  /// Month `"Tháng 5, 2026"`.
  String _dateLabel() {
    final d = state.focusedDate;
    switch (state.view) {
      case ScheduleView.day:
        return '${_weekdayName(d)} · ${_dd(d.day)}/${_dd(d.month)}/${d.year}';
      case ScheduleView.week:
        final start = state.weekStart;
        final end = DateTime(start.year, start.month, start.day + 6);
        if (start.month == end.month) {
          return '${_dd(start.day)} — ${_dd(end.day)} / ${_dd(start.month)} / ${start.year}';
        }
        // Cross-month/-year weeks have no prototype example — keep the same
        // dd / mm / yyyy vocabulary.
        if (start.year == end.year) {
          return '${_dd(start.day)} / ${_dd(start.month)} — '
              '${_dd(end.day)} / ${_dd(end.month)} / ${end.year}';
        }
        return '${_dd(start.day)} / ${_dd(start.month)} / ${start.year} — '
            '${_dd(end.day)} / ${_dd(end.month)} / ${end.year}';
      case ScheduleView.month:
        return 'Tháng ${d.month}, ${d.year}';
    }
  }

  // ---------------------------------------------------------------------------
  // Stats — `.sc-stat`, strings per the handoff README
  // ---------------------------------------------------------------------------

  /// `strong` span — number in Sora 700 `--n-900`.
  static TextSpan _strong(String text) => TextSpan(
        text: text,
        style: GoogleFonts.sora(
          fontWeight: FontWeight.w700,
          color: AppColors.neutral900,
        ),
      );

  /// `.hl` span carrying a number — Sora, `--primary-dark`.
  static TextSpan _hlNumber(String text) => TextSpan(
        text: text,
        style: GoogleFonts.sora(
          fontWeight: FontWeight.w700,
          color: AppColors.primaryDark,
        ),
      );

  Widget _stats() {
    final List<InlineSpan> spans;
    switch (state.view) {
      case ScheduleView.day:
        // "<N> đã đặt · <N> còn mở · <P>% lấp đầy"
        final slots = state.visibleDaySlots;
        final booked = slots
            .where((s) =>
                s.state == SlotState.confirmed || s.state == SlotState.fixed)
            .length;
        final open = slots
            .where(
                (s) => s.state == SlotState.empty || s.state == SlotState.open)
            .length;
        // Real occupancy: occupied HOURS over the summed real operating
        // window of the visible venues (a 2h slot weighs twice a 1h slot;
        // a court open 06–14 fully booked reads 100%, not 50%).
        final occupiedHours = slots
            .where((s) => _occupiedStates.contains(s.state))
            .fold<double>(0, (sum, s) => sum + s.durationHours);
        final operatingHours = state.visibleVenues.fold<double>(0, (sum, v) {
          final span = (v.closeHour ?? 22) - (v.openHour ?? 6);
          return sum + (span > 0 ? span : _fallbackHoursPerDay);
        });
        final pct = operatingHours == 0
            ? 0
            : (occupiedHours / operatingHours * 100).clamp(0, 100).round();
        spans = [
          _strong('$booked'),
          const TextSpan(text: ' đã đặt · '),
          _strong('$open'),
          const TextSpan(text: ' còn mở · '),
          _hlNumber('$pct%'),
          const TextSpan(text: ' lấp đầy'),
        ];
      case ScheduleView.week:
        // "<N> slot · <venue name> · tuần này"
        spans = [
          _strong('${state.visibleWeekSlots.length}'),
          TextSpan(text: ' slot · ${state.selectedVenue?.name ?? '—'} · '),
          const TextSpan(
            text: 'tuần này',
            style: TextStyle(color: AppColors.primaryDark),
          ),
        ];
      case ScheduleView.month:
        // "Lấp đầy TB tháng <P>%"
        final cells = state.monthCells.where((c) => c.isCurrentMonth).toList();
        final avg = cells.isEmpty
            ? 0
            : (cells.map((c) => c.occupancy).reduce((a, b) => a + b) /
                    cells.length *
                    100)
                .round();
        spans = [
          const TextSpan(text: 'Lấp đầy TB tháng '),
          _hlNumber('$avg%'),
        ];
    }
    return Text.rich(
      TextSpan(
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12.5,
          color: AppColors.neutral600,
        ),
        children: spans,
      ),
    );
  }
}
