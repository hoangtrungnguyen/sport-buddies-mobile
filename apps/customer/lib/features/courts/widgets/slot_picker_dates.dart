// Horizontal 7-day date tab row for the slot picker.
// Extracted from slot_picker_screen.dart.

import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class DateTabRow extends StatelessWidget {
  const DateTabRow({
    super.key,
    required this.dates,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<DateTime> dates;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: SizedBox(
        height: 76,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: dates.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) => _DateTabItem(
            date: dates[i],
            isActive: i == selectedIndex,
            isToday: i == 0,
            isTomorrow: i == 1,
            onTap: () => onTap(i),
          ),
        ),
      ),
    );
  }
}

class _DateTabItem extends StatelessWidget {
  const _DateTabItem({
    required this.date,
    required this.isActive,
    required this.isToday,
    required this.isTomorrow,
    required this.onTap,
  });

  final DateTime date;
  final bool isActive;
  final bool isToday;
  final bool isTomorrow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final topLabel = isToday
        ? l10n.scheduleToday
        : isTomorrow
        ? l10n.courtsTomorrow
        : _weekdayShort(date.weekday);
    final dayNum = date.day.toString();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 76,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF16A34A) : Colors.white,
          border: Border.all(
            color: isActive ? const Color(0xFF16A34A) : const Color(0xFFE5E7EB),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              topLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dayNum,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isActive ? Colors.white : const Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _weekdayShort(int w) => switch (w) {
    1 => 'T2',
    2 => 'T3',
    3 => 'T4',
    4 => 'T5',
    5 => 'T6',
    6 => 'T7',
    _ => 'CN',
  };
}
