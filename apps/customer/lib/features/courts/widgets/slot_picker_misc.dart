// Small slot-picker pieces: error view, empty-state and the bottom CTA bar.
// Extracted from slot_picker_screen.dart.

import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spb_core/spb_core.dart';

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Color(0xFF9CA3AF)),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: Text(AppLocalizations.of(context).commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptySlots extends StatelessWidget {
  const EmptySlots({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Center(
        child: Text(
          AppLocalizations.of(context).slotPickerNoSlotsToday,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
      ),
    );
  }
}

class BottomCta extends StatelessWidget {
  const BottomCta({
    super.key,
    required this.selected,
    required this.totalPrice,
    required this.durationMinutes,
    required this.onContinue,
  });

  final Slot? selected;
  final double totalPrice;
  final int durationMinutes;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final fmt = NumberFormat.decimalPattern('vi_VN');
    final enabled = onContinue != null;
    final hours = durationMinutes / 60;
    final hoursLabel = hours == hours.roundToDouble()
        ? hours.toStringAsFixed(0)
        : hours.toStringAsFixed(1);

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        12,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selected == null
                      ? l10n.slotPickerNoSelection
                      : l10n.slotPickerSelectedCount(
                          1,
                          l10n.wizardHours(hoursLabel),
                        ),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  selected == null || totalPrice == 0
                      ? '—'
                      : '${fmt.format(totalPrice.round())} đ',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: enabled ? onContinue : null,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              disabledBackgroundColor: const Color(0xFFD1D5DB),
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              selected == null ? l10n.commonContinue : l10n.slotPickerBookNow,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: enabled ? Colors.white : const Color(0xFF9CA3AF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
