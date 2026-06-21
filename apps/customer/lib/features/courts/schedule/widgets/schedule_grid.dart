// Venues × start-time grid for the court schedule: header row, one row per
// lane (venue) and individual selectable cells. Cells key on the real slot id.

import 'package:customer/features/courts/schedule/cubit/court_schedule_overview_state.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ScheduleGrid extends StatelessWidget {
  const ScheduleGrid({
    super.key,
    required this.venues,
    required this.times,
    required this.dayGrid,
    required this.selectedIds,
    required this.onToggle,
  });

  /// One row per lane.
  final List<ScheduleVenue> venues;

  /// Column headers — distinct "HH:mm" start times on the visible day.
  final List<String> times;

  /// `venueId → 'HH:mm' → slot` for the visible day.
  final Map<String, Map<String, VenueSlot>> dayGrid;

  /// Real slot ids currently in the cart.
  final Set<String> selectedIds;

  /// Toggles a slot id when an open cell is tapped.
  final ValueChanged<String> onToggle;

  static const _venueColW = 96.0;
  static const _cellW = 48.0;
  static const _cellH = 40.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: _venueColW, height: 32),
              for (final t in times)
                SizedBox(
                  width: _cellW,
                  height: 32,
                  child: Center(
                    child: Text(
                      t,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          for (var i = 0; i < venues.length; i++) ...[
            _VenueRow(
              venue: venues[i],
              times: times,
              byTime: dayGrid[venues[i].id] ?? const {},
              selectedIds: selectedIds,
              onToggle: onToggle,
            ),
            if (i < venues.length - 1)
              const Divider(height: 1, color: Color(0xFFF3F4F6)),
          ],
        ],
      ),
    );
  }
}

class _VenueRow extends StatelessWidget {
  const _VenueRow({
    required this.venue,
    required this.times,
    required this.byTime,
    required this.selectedIds,
    required this.onToggle,
  });

  final ScheduleVenue venue;
  final List<String> times;
  final Map<String, VenueSlot> byTime;
  final Set<String> selectedIds;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: ScheduleGrid._venueColW,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    venue.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  Text(
                    venue.sportType,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),
          for (final t in times)
            _Cell(
              key: ValueKey('${venue.id}|$t'),
              slot: byTime[t],
              isSelected:
                  byTime[t] != null && selectedIds.contains(byTime[t]!.id),
              onToggle: onToggle,
            ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    super.key,
    required this.slot,
    required this.isSelected,
    required this.onToggle,
  });

  final VenueSlot? slot;
  final bool isSelected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final slot = this.slot;
    final isOpen = slot != null && slot.bookable;
    final isTaken = slot != null && !slot.bookable;

    Widget content;
    Color bg = Colors.white;
    Color? border;

    if (slot == null) {
      // No slot at this time for this lane.
      content = Container(
        width: 12,
        height: 1.5,
        color: const Color(0xFFD1D5DB),
      );
    } else if (isTaken) {
      content = Text(
        AppLocalizations.of(context).scheduleBookedShort,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF9CA3AF),
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.lineThrough,
        ),
      );
      bg = const Color(0xFFF3F4F6);
    } else if (isSelected) {
      content = const Icon(Icons.check, size: 18, color: Color(0xFF16A34A));
      bg = const Color(0xFFDCFCE7);
      border = const Color(0xFF16A34A);
    } else {
      content = Container(
        width: 4,
        height: 4,
        decoration: const BoxDecoration(
          color: Color(0xFFD1D5DB),
          shape: BoxShape.circle,
        ),
      );
    }

    final cell = Container(
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: bg,
        border: border != null ? Border.all(color: border, width: 1.5) : null,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(child: content),
    );

    return SizedBox(
      width: ScheduleGrid._cellW,
      height: ScheduleGrid._cellH,
      child: isOpen
          ? GestureDetector(
              onTap: () => onToggle(slot.id),
              behavior: HitTestBehavior.opaque,
              child: cell,
            )
          : cell,
    );
  }
}
