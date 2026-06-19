import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';

/// Horizontal "today + next 6 days" tab row — shared by screens 08 and 09
/// (doc 02 §9). Selection drives a re-fetch in the parent; the cart is kept.
class DateTabs extends StatelessWidget {
  const DateTabs({
    super.key,
    required this.dates,
    required this.selectedIndex,
    required this.onSelect,
    this.minTabWidth = 60,
  });

  final List<DateTime> dates;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final double minTabWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => _DateTab(
          date: dates[i],
          isToday: i == 0,
          active: i == selectedIndex,
          minWidth: minTabWidth,
          onTap: () => onSelect(i),
        ),
      ),
    );
  }
}

class _DateTab extends StatelessWidget {
  const _DateTab({
    required this.date,
    required this.isToday,
    required this.active,
    required this.minWidth,
    required this.onTap,
  });

  final DateTime date;
  final bool isToday;
  final bool active;
  final double minWidth;
  final VoidCallback onTap;

  static const _weekdays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dayLabel = isToday
        ? AppLocalizations.of(context).scheduleToday
        : _weekdays[date.weekday - 1];
    final fg = active ? scheme.onPrimary : scheme.onSurfaceVariant;

    return Material(
      color: active ? scheme.primary : scheme.surface,
      borderRadius: AppTokens.radiusMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTokens.radiusMd,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: AppTokens.radiusMd,
            border: active ? null : Border.all(color: scheme.outlineVariant),
          ),
          child: Container(
            constraints: BoxConstraints(minWidth: minWidth),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dayLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: fg,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: fg,
                    fontFeatures: AppTokens.tnum,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Builds "today + next 6 days" from a base date.
List<DateTime> next7Days(DateTime from) =>
    List.generate(7, (i) => DateTime(from.year, from.month, from.day + i));
