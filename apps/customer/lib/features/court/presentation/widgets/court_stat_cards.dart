// Price / open-today stat cards for the court detail screen.
// Extracted from court_detail_page.dart.

import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../domain/court.dart';
import '../../theme/app_tokens.dart';
import '../../theme/browse_pick_theme.dart';

class StatCards extends StatelessWidget {
  const StatCards({super.key, required this.court});

  final Court court;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    // IntrinsicHeight bounds the Row's (otherwise unbounded) cross-axis so
    // CrossAxisAlignment.stretch can give the two cards equal height without
    // forcing an infinite constraint.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _StatCard(
              label: l10n.courtDetailPricePerHour,
              value: '${_thousands(court.pricePerHourVnd)} đ',
              valueColor: scheme.onSurface,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              label: l10n.courtDetailOpenToday,
              value: l10n.courtDetailSlotCount(court.openSlotsToday),
              valueColor: scheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: AppTokens.radiusMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: text.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: text.priceMedium(scheme).copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}

/// "180000" → "180.000" (vi thousands).
String _thousands(int v) {
  final s = v.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return buf.toString();
}
