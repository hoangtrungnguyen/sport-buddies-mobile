// Slot summary card for the participant management screen.
// Extracted from participant_management_screen.dart.

import 'package:customer/features/slots/cubit/participant_management_state.dart';
import 'package:customer/features/slots/slots_style.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SlotSummaryCard extends StatelessWidget {
  const SlotSummaryCard({super.key, required this.slot});

  final SlotSummary slot;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final timeFmt = DateFormat('HH:mm');
    final dateFmt = DateFormat('EEE, dd/MM', 'vi');

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(mdCornerMd),
      elevation: 1,
      shadowColor: const Color(0x1A000000),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: badge + slot ID
            Row(
              children: [
                Container(
                  height: 24,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: mdPrimaryContainer,
                    borderRadius: BorderRadius.circular(mdCornerFull),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '🌐 ${l10n.slotsOpenMatch}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: mdOnPrimaryContainer,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: mdSurfaceContainer,
                    borderRadius: BorderRadius.circular(mdCornerSm),
                  ),
                  child: const Text(
                    'slot_open_001',
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: mdOnSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              slot.courtName,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: mdOnSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${dateFmt.format(slot.startTime)} · '
              '${timeFmt.format(slot.startTime)}–${timeFmt.format(slot.endTime)} · '
              '${slot.sportType}',
              style: const TextStyle(fontSize: 13, color: mdOnSurfaceVariant),
            ),
            Divider(height: 20, color: mdOutlineVariant.withAlpha(128)),
            // Fullness row — rendered by parent since we need maxPlayers from
            // the loaded state. We pass slot only here, so the fullness meter
            // is shown in the players card instead.
            Row(
              children: [
                const Icon(
                  Icons.group_outlined,
                  size: 16,
                  color: mdOnSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.slotsSeeListBelow,
                  style: const TextStyle(
                    fontSize: 12,
                    color: mdOnSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
