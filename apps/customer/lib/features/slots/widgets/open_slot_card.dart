// Open-slot card with sport accent, fullness badge and the sport colour
// palette/label helpers. Extracted from open_slot_list_screen.dart.

import 'package:customer/l10n/app_localizations.dart';
import 'package:customer/features/slots/slots_style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spb_core/spb_core.dart';

// ── Sport colour palette ──────────────────────────────────────────────────────
const _sportColors = <String, Color>{
  'football': Color(0xFF22C55E),
  'badminton': Color(0xFFEF4444),
  'pickleball': Color(0xFF0EA5E9),
  'tennis': Color(0xFFEAB308),
  'multi': Color(0xFF6B7280),
};

/// Localized display label for a sport type; falls back to the raw value.
String _sportLabel(AppLocalizations l10n, String type) => switch (type) {
  'football' => l10n.sportFootball,
  'badminton' => l10n.sportBadminton,
  'pickleball' => l10n.sportPickleball,
  'tennis' => l10n.sportTennis,
  'multi' => l10n.sportMulti,
  _ => type,
};

class SlotCard extends StatelessWidget {
  const SlotCard({super.key, required this.slot, required this.onTap});

  final Slot slot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sportColor = _sportColors[slot.sportType] ?? const Color(0xFF6B7280);
    final sportLabel = _sportLabel(l10n, slot.sportType);
    final isFull = slot.isFull;

    final timeFmt = DateFormat('HH:mm');
    final dateFmt = DateFormat('EEE, dd/MM', 'vi');
    final timeLabel =
        '${dateFmt.format(slot.startTime)} · ${timeFmt.format(slot.startTime)} – ${timeFmt.format(slot.endTime)}';

    return Material(
      color: const Color(0xFFFFFFFF),
      borderRadius: BorderRadius.circular(mdCornerMd),
      elevation: 1,
      shadowColor: const Color(0x1A000000),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(mdCornerMd),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sport icon container
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: sportColor.withAlpha(26),
                      borderRadius: BorderRadius.circular(mdCornerMd),
                    ),
                    child: Icon(
                      _sportIcon(slot.sportType),
                      color: sportColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                slot.courtName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: mdOnSurface,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _FullnessBadge(
                              joined: slot.currentPlayers,
                              max: slot.maxPlayers,
                              isFull: isFull,
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          timeLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            color: mdOnSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.sports,
                              size: 13,
                              color: mdOnSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              sportLabel,
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
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Divider(
                  height: 1,
                  color: mdOutlineVariant.withAlpha(128),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: mdSurfaceContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 16,
                        color: mdOnSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.slotsHostInvite,
                        style: const TextStyle(
                          fontSize: 12,
                          color: mdOnSurfaceVariant,
                        ),
                      ),
                    ),
                    if (slot.accessPolicy == 'open')
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: mdSurfaceContainerHigh,
                          borderRadius: BorderRadius.circular(mdCornerSm),
                        ),
                        child: Text(
                          l10n.slotsOpenMatch,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: mdOnSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _sportIcon(String sport) => switch (sport) {
    'football' => Icons.sports_soccer,
    'badminton' => Icons.sports_tennis,
    'pickleball' => Icons.sports_tennis,
    'tennis' => Icons.sports_tennis,
    _ => Icons.sports,
  };
}

class _FullnessBadge extends StatelessWidget {
  const _FullnessBadge({
    required this.joined,
    required this.max,
    required this.isFull,
  });

  final int joined;
  final int max;
  final bool isFull;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isFull ? mdSurfaceContainerHighest : mdPrimaryContainer,
        borderRadius: BorderRadius.circular(mdCornerFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isFull ? const Color(0xFF72796C) : mdPrimary,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isFull
                ? AppLocalizations.of(context).slotsFull
                : AppLocalizations.of(context).slotsJoinedCount(joined, max),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isFull ? mdOnSurfaceVariant : mdOnPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
