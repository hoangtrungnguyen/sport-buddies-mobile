import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../bloc/venue_schedule_state.dart';
import '../model/models.dart';

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
        _DateNav(label: _dateLabel(), onPrev: onPrev, onNext: onNext);
    final today = _TodayButton(onPressed: onToday);
    final viewSwitch =
        _ViewSwitch(active: state.view, onChanged: onViewChanged);
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

/// `.date-nav` — white pill (1px `--n-200`, radius 10, padding 4) with
/// ‹ / › arrow buttons around a Sora 13/600 label.
class _DateNav extends StatelessWidget {
  const _DateNav({
    required this.label,
    required this.onPrev,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.neutral200),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ArrowButton(icon: Icons.chevron_left, onPressed: onPrev),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              label,
              style: GoogleFonts.sora(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral900,
              ),
            ),
          ),
          _ArrowButton(icon: Icons.chevron_right, onPressed: onNext),
        ],
      ),
    );
  }
}

/// `.date-nav .arr` — 30×30, radius 8, hover `--n-100` bg + `--n-900` icon.
class _ArrowButton extends StatefulWidget {
  const _ArrowButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  State<_ArrowButton> createState() => _ArrowButtonState();
}

class _ArrowButtonState extends State<_ArrowButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: _hovered ? AppColors.neutral100 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            widget.icon,
            size: 16,
            color: _hovered ? AppColors.neutral900 : AppColors.neutral600,
          ),
        ),
      ),
    );
  }
}

/// "Hôm nay" — `.btn-secondary.btn-sm`: 32px tall, 12.5/600, white bg,
/// 1px `--n-200` border, hover `--n-50` bg + `--n-300` border.
class _TodayButton extends StatefulWidget {
  const _TodayButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<_TodayButton> createState() => _TodayButtonState();
}

class _TodayButtonState extends State<_TodayButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _hovered ? AppColors.neutral50 : Colors.white,
            border: Border.all(
              color: _hovered ? AppColors.neutral300 : AppColors.neutral200,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'Hôm nay',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral800,
            ),
          ),
        ),
      ),
    );
  }
}

/// `.view-switch` — segmented control: `--n-100` pill (padding 3, radius 10);
/// active segment is white with `--shadow-sm` and `--n-900` text. Labels hide
/// below 640px viewport width (icon-only, like the prototype's media query).
class _ViewSwitch extends StatelessWidget {
  const _ViewSwitch({required this.active, required this.onChanged});

  final ScheduleView active;
  final ValueChanged<ScheduleView> onChanged;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final iconOnly = screenWidth < 640;
    final compact = screenWidth < 1024;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Prototype icons: 'columns' (resource columns) / 'calendar' /
          // 'grid' — keep Day and Month visually distinct.
          for (final (view, icon, label) in const [
            (ScheduleView.day, Icons.view_column_outlined, 'Ngày'),
            (ScheduleView.week, Icons.calendar_today_outlined, 'Tuần'),
            (ScheduleView.month, Icons.grid_on, 'Tháng'),
          ])
            _ViewSwitchButton(
              icon: icon,
              label: label,
              active: view == active,
              iconOnly: iconOnly,
              compact: compact,
              onPressed: () => onChanged(view),
            ),
        ],
      ),
    );
  }
}

class _ViewSwitchButton extends StatefulWidget {
  const _ViewSwitchButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.iconOnly,
    required this.compact,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool active;
  final bool iconOnly;
  final bool compact;
  final VoidCallback onPressed;

  @override
  State<_ViewSwitchButton> createState() => _ViewSwitchButtonState();
}

class _ViewSwitchButtonState extends State<_ViewSwitchButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final fg =
        widget.active || _hovered ? AppColors.neutral900 : AppColors.neutral600;
    final padding = widget.iconOnly
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
        : widget.compact
            ? const EdgeInsets.symmetric(horizontal: 11, vertical: 7)
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 7);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          padding: padding,
          decoration: BoxDecoration(
            color: widget.active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            boxShadow: widget.active
                ? const [
                    // --shadow-sm
                    BoxShadow(
                      color: Color(0x0A111827),
                      offset: Offset(0, 1),
                      blurRadius: 2,
                    ),
                    BoxShadow(
                      color: Color(0x08111827),
                      offset: Offset(0, 1),
                      blurRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 15, color: fg),
              if (!widget.iconOnly) ...[
                const SizedBox(width: 7),
                Text(
                  widget.label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: fg,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
