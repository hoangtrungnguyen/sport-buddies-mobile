// Courts × time-slot grid for the venue schedule: header rows, court rows
// and individual selectable cells. Extracted from
// court_schedule_overview_screen.dart.

import 'package:customer/features/courts/schedule/court_schedule_style.dart';
import 'package:customer/features/courts/schedule/cubit/court_schedule_overview_state.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScheduleGrid extends StatelessWidget {
  const ScheduleGrid({
    super.key,
    required this.courts,
    required this.hours,
    required this.slots,
    required this.selected,
    required this.onTap,
  });

  final List<ScheduleCourt> courts;
  final List<int> hours;
  final Map<String, ScheduleSlot> slots;
  final Set<String> selected;
  final ValueChanged<String> onTap;

  static const _courtColW = 88.0;
  static const _cellW = 40.0;
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
              const SizedBox(width: _courtColW, height: 32),
              for (final h in hours)
                SizedBox(
                  width: _cellW,
                  height: 32,
                  child: Center(
                    child: Text(
                      '${h.toString().padLeft(2, '0')}:00',
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
          for (var i = 0; i < courts.length; i++) ...[
            _CourtRow(
              court: courts[i],
              hours: hours,
              slots: slots,
              selected: selected,
              onTap: onTap,
            ),
            if (i < courts.length - 1)
              const Divider(height: 1, color: Color(0xFFF3F4F6)),
          ],
        ],
      ),
    );
  }
}

class _CourtRow extends StatelessWidget {
  const _CourtRow({
    required this.court,
    required this.hours,
    required this.slots,
    required this.selected,
    required this.onTap,
  });

  final ScheduleCourt court;
  final List<int> hours;
  final Map<String, ScheduleSlot> slots;
  final Set<String> selected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context.push(
              '/court/${court.id}/slots',
              extra: <String, String?>{
                'name': '${court.name} · ${court.sport}',
                'address': kVenueName,
              },
            ),
            child: SizedBox(
              width: ScheduleGrid._courtColW,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      court.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                    Text(
                      court.sport,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          for (final h in hours)
            _Cell(
              key: ValueKey('${court.id}|$h'),
              slotKey: '${court.id}|$h',
              slot: slots['${court.id}|$h'],
              isSelected: selected.contains('${court.id}|$h'),
              onTap: onTap,
            ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    super.key,
    required this.slotKey,
    required this.slot,
    required this.isSelected,
    required this.onTap,
  });

  final String slotKey;
  final ScheduleSlot? slot;
  final bool isSelected;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    Widget content;
    Color bg = Colors.white;
    Color? border;
    final isOpen = slot?.status == SlotStatus.open;
    final isBooked = slot?.status == SlotStatus.booked;
    final isClosed = slot == null || slot!.status == SlotStatus.closed;

    if (isClosed) {
      content = Container(
        width: 12,
        height: 1.5,
        color: const Color(0xFFD1D5DB),
      );
    } else if (isBooked) {
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
              onTap: () => onTap(slotKey),
              behavior: HitTestBehavior.opaque,
              child: cell,
            )
          : cell,
    );
  }
}
