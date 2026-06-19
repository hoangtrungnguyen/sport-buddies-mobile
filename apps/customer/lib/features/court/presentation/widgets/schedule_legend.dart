// Status legend (open / booked / selected) for the venue schedule.
// Extracted from schedule_page.dart.

import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';

class Legend extends StatelessWidget {
  const Legend({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        _swatch(
          scheme.surfaceContainerLowest,
          scheme.outlineVariant,
          l10n.scheduleLegendOpen,
          scheme,
        ),
        const SizedBox(width: 16),
        _swatch(
          scheme.surfaceContainerHigh,
          scheme.outlineVariant,
          l10n.slotPickerBooked,
          scheme,
        ),
        const SizedBox(width: 16),
        _swatch(
          scheme.primaryContainer,
          scheme.primary,
          l10n.scheduleLegendSelected,
          scheme,
        ),
      ],
    );
  }

  Widget _swatch(Color bg, Color border, String label, ColorScheme scheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.all(
              Radius.circular(AppTokens.cornerXs),
            ),
            border: Border.all(color: border),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
