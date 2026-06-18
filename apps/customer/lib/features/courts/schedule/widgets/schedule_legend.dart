// Status legend (open / booked / closed) for the venue schedule.
// Extracted from court_schedule_overview_screen.dart.

import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class Legend extends StatelessWidget {
  const Legend({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        _LegendItem(
          color: Colors.white,
          border: const Color(0xFFE5E7EB),
          label: l10n.scheduleLegendOpen,
        ),
        const SizedBox(width: 16),
        _LegendItem(
          color: const Color(0xFFF3F4F6),
          border: const Color(0xFFE5E7EB),
          label: l10n.slotPickerBooked,
        ),
        const SizedBox(width: 16),
        _LegendItem(
          color: const Color(0xFFDCFCE7),
          border: const Color(0xFF16A34A),
          label: l10n.scheduleLegendSelected,
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.border,
    required this.label,
  });

  final Color color;
  final Color border;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: border, width: 1.5),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }
}
