// Host/Join colour-key legend shown above the Upcoming bookings list.
// Extracted from booking_tab_views.dart.

import 'package:customer/features/bookings/bookings_style.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class RoleLegend extends StatelessWidget {
  const RoleLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: mdSurfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _LegendItem(
            color: mdPrimary,
            label: AppLocalizations.of(context).bookingsLegendHost,
          ),
          const SizedBox(width: 16),
          _LegendItem(
            color: mdSecondary,
            label: AppLocalizations.of(context).bookingsLegendJoin,
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: mdOnSurfaceVariant),
        ),
      ],
    );
  }
}
