// Slot grid, individual slot tile and the selected badge for the slot picker.
// Extracted from slot_picker_screen.dart.

import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spb_core/spb_core.dart';

class SlotGrid extends StatelessWidget {
  const SlotGrid({
    super.key,
    required this.slots,
    required this.pricePerHour,
    required this.selectedSlotId,
    required this.onTap,
  });

  final List<Slot> slots;
  final double? pricePerHour;
  final String? selectedSlotId;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.2,
      children: [
        for (final slot in slots)
          _SlotTile(
            slot: slot,
            pricePerHour: pricePerHour,
            isSelected: slot.id == selectedSlotId,
            onTap: () => onTap(slot.id),
          ),
      ],
    );
  }
}

class _SlotTile extends StatelessWidget {
  const _SlotTile({
    required this.slot,
    required this.pricePerHour,
    required this.isSelected,
    required this.onTap,
  });

  final Slot slot;
  final double? pricePerHour;
  final bool isSelected;
  final VoidCallback onTap;

  static final _timeFmt = DateFormat('HH:mm');

  /// Label shown instead of price on non-open slots.
  static String _statusLabel(AppLocalizations l10n, String status) =>
      switch (status) {
        'booked' => l10n.slotPickerBooked,
        'blocked' => l10n.slotPickerLocked,
        'maintenance' => l10n.slotPickerMaintenance,
        _ => '',
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final available = slot.isAvailable;
    final timeLabel =
        '${_timeFmt.format(slot.startTime.toLocal())} – ${_timeFmt.format(slot.endTime.toLocal())}';
    final durationMinutes = slot.endTime.difference(slot.startTime).inMinutes;
    final price = pricePerHour != null
        ? (pricePerHour! * durationMinutes / 60).round()
        : null;
    final priceLabel = price != null ? '${(price / 1000).round()}k' : '—';

    return GestureDetector(
      onTap: available ? onTap : null,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: !available
              ? const Color(0xFFF3F4F6)
              : isSelected
              ? const Color(0xFFDCFCE7)
              : Colors.white,
          border: Border.all(
            color: isSelected
                ? const Color(0xFF16A34A)
                : const Color(0xFFE5E7EB),
            width: isSelected ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                if (isSelected)
                  const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: _SelectedBadge(),
                  ),
                Expanded(
                  child: Text(
                    timeLabel,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: available
                          ? const Color(0xFF111827)
                          : const Color(0xFF9CA3AF),
                      decoration: available ? null : TextDecoration.lineThrough,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              available ? priceLabel : _statusLabel(l10n, slot.status),
              style: TextStyle(
                fontSize: available ? 15 : 12,
                fontWeight: FontWeight.w800,
                color: !available
                    ? const Color(0xFF9CA3AF)
                    : isSelected
                    ? const Color(0xFF16A34A)
                    : const Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedBadge extends StatelessWidget {
  const _SelectedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF16A34A),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(Icons.check, size: 13, color: Colors.white),
    );
  }
}
