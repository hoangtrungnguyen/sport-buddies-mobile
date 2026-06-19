// Numbered multi-select slot grid for the slot picker.
// Extracted from slot_picker_page.dart.

import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../domain/schedule.dart';
import '../../domain/time_slot.dart';
import '../../theme/app_tokens.dart';

class SlotGrid extends StatelessWidget {
  const SlotGrid({
    super.key,
    required this.slots,
    required this.selection,
    required this.onToggle,
  });

  final List<TimeSlot> slots;
  final List<TimeSlot> selection;
  final void Function(TimeSlot) onToggle;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.4,
      children: [
        for (final slot in slots)
          _SlotCell(
            slot: slot,
            order: selection.indexWhere((s) => s.id == slot.id),
            onTap: slot.isOpen ? () => onToggle(slot) : null,
          ),
      ],
    );
  }
}

class _SlotCell extends StatelessWidget {
  const _SlotCell({required this.slot, required this.order, this.onTap});

  final TimeSlot slot;

  /// Index in the selection list, or -1 if not selected.
  final int order;
  final VoidCallback? onTap;

  static String _hhmm(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selected = order >= 0;
    final timeLabel = '${_hhmm(slot.start)} – ${_hhmm(slot.end)}';
    final priceLabel = '${(slot.priceVnd / 1000).round()}k';
    final inert = !slot.isOpen;

    late final Color bg;
    late final BoxBorder border;
    if (selected) {
      bg = scheme.primaryContainer;
      border = Border.all(color: scheme.primary, width: 2);
    } else if (inert) {
      bg = scheme.surfaceContainer.withValues(alpha: 0.6);
      border = Border.all(color: scheme.outlineVariant);
    } else {
      bg = scheme.surfaceContainerLowest;
      border = Border.all(color: scheme.outlineVariant);
    }

    final timeColor = selected
        ? scheme.onPrimaryContainer
        : inert
        ? scheme.onSurfaceVariant
        : scheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: AppTokens.radiusMd,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppTokens.radiusMd,
          border: border,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                if (selected) ...[
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${order + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: scheme.onPrimary,
                        fontFeatures: AppTokens.tnum,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    timeLabel,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: timeColor,
                      fontFeatures: AppTokens.tnum,
                      decoration: slot.status == CellStatus.booked
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  priceLabel,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: timeColor,
                    fontFeatures: AppTokens.tnum,
                  ),
                ),
                if (inert) ...[
                  const Spacer(),
                  Text(
                    slot.status == CellStatus.booked
                        ? AppLocalizations.of(context).slotPickerBooked
                        : AppLocalizations.of(context).slotPickerClosed,
                    style: TextStyle(
                      fontSize: 12,
                      color: slot.status == CellStatus.booked
                          ? scheme.error
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
