// Sticky bottom cart bar for the slot picker: count, total and continue CTA.
// Extracted from slot_picker_page.dart.

import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../domain/time_slot.dart';
import '../../theme/app_tokens.dart';
import '../../theme/browse_pick_theme.dart';

class BottomCartBar extends StatelessWidget {
  const BottomCartBar({
    super.key,
    required this.selection,
    required this.onContinue,
  });

  final List<TimeSlot> selection;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final count = selection.length;
    final total = selection.fold<int>(0, (s, e) => s + e.priceVnd);
    final minutes = selection.fold<int>(0, (m, e) => m + e.duration.inMinutes);
    final hours = (minutes / 60);
    final hoursLabel = hours == hours.roundToDouble()
        ? hours.toStringAsFixed(0)
        : hours.toStringAsFixed(1);
    final enabled = onContinue != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    count == 0
                        ? l10n.slotPickerNoSelection
                        : l10n.slotPickerSelectedCount(
                            count,
                            l10n.wizardHours(hoursLabel),
                          ),
                    style: text.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    count == 0 ? '—' : '${_thousands(total)} đ',
                    style: text.priceMedium(scheme),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: onContinue,
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, AppTokens.buttonStickyHeight),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: Text(
                enabled
                    ? l10n.slotPickerContinue(count)
                    : l10n.slotPickerPickSlots,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _thousands(int v) {
  final s = v.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return buf.toString();
}
