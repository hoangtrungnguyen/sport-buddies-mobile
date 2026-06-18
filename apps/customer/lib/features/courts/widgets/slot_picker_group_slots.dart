// Open-match ("play together") group-slot section for the slot picker.
// Extracted from slot_picker_screen.dart.

import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:spb_core/spb_core.dart';

class GroupSlotsSection extends StatelessWidget {
  const GroupSlotsSection({
    super.key,
    required this.groupSlots,
    required this.courtId,
  });

  final List<Slot> groupSlots;
  final String courtId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.courtsOpenMatchSlots,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.courtDetailSlotCount(groupSlots.length),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF15803D),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.slotPickerOpenHelper,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 12),
          ...groupSlots.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _GroupSlotRow(slot: s),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupSlotRow extends StatelessWidget {
  const _GroupSlotRow({required this.slot});

  final Slot slot;

  static const _sportColors = <String, Color>{
    'pickleball': Color(0xFF0EA5E9),
    'badminton': Color(0xFF0369A1),
    'cầu lông': Color(0xFF0369A1),
    'tennis': Color(0xFFEF4444),
    'football': Color(0xFF374151),
    'bóng đá': Color(0xFF374151),
    'bóng đá 5v5': Color(0xFF374151),
    'basketball': Color(0xFF9A3412),
    'bóng rổ': Color(0xFF9A3412),
    'volleyball': Color(0xFF6D28D9),
  };

  static IconData _sportIcon(String sportType) =>
      switch (sportType.toLowerCase()) {
        'badminton' || 'cầu lông' => Icons.sports_tennis,
        'tennis' => Icons.sports_tennis,
        'football' || 'bóng đá' || 'bóng đá 5v5' => Icons.sports_soccer,
        'basketball' || 'bóng rổ' => Icons.sports_basketball,
        'volleyball' => Icons.sports_volleyball,
        _ => Icons.sports,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final key = slot.sportType.toLowerCase();
    final color = _sportColors[key] ?? const Color(0xFF374151);
    final left = slot.maxPlayers - slot.currentPlayers;
    final timeLabel = _buildTimeLabel(l10n, slot.startTime, slot.endTime);

    final icon = _sportIcon(slot.sportType);
    return GestureDetector(
      onTap: () => context.push('/slot/${slot.id}'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slot.courtName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    timeLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.group_outlined,
                        size: 14,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.slotsJoinedCount(
                          slot.currentPlayers,
                          slot.maxPlayers,
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.courtsSlotsLeft(left),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF22C55E),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }

  static String _buildTimeLabel(
    AppLocalizations l10n,
    DateTime start,
    DateTime end,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final slotDay = DateTime(start.year, start.month, start.day);
    final diff = slotDay.difference(today).inDays;
    final prefix = switch (diff) {
      0 => l10n.scheduleToday,
      1 => l10n.courtsTomorrow,
      _ => DateFormat('EEE', 'vi').format(start),
    };
    final fmt = DateFormat('HH:mm');
    return '$prefix · ${fmt.format(start)} – ${fmt.format(end)}';
  }
}
