// SlotRow widget — grava-c9ca.5.2.
//
// Displays a single open slot in a list of available slots.
//
// Shows:
//   - Court name
//   - Sport type badge (Vietnamese labels)
//   - Date (e.g. "Mon, 15 Jun 2026")
//   - Time range (e.g. "10:00 – 11:00")
//   - Player count (e.g. "2/4")
//   - Access policy icon (open lock / closed lock)
//   - Full slot indicator (red player count when full)
//   - Optional tap callback

import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spb_core/spb_core.dart';

class SlotRow extends StatelessWidget {
  const SlotRow({super.key, required this.slot, this.onTap});

  final Slot slot;
  final VoidCallback? onTap;

  /// Returns the localized label for a given sport type.
  static String _sportTypeLabel(AppLocalizations l10n, String sportType) {
    return switch (sportType) {
      'badminton' => l10n.sportBadminton,
      'football' => l10n.sportFootball,
      'tennis' => l10n.sportTennis,
      'basketball' => l10n.sportBasketball,
      _ => sportType,
    };
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final dateStr = DateFormat('EEE, d MMM yyyy').format(slot.startTime);
    final startStr = DateFormat('HH:mm').format(slot.startTime);
    final endStr = DateFormat('HH:mm').format(slot.endTime);

    final playerCountColor = slot.isFull ? Colors.red : null;

    return InkWell(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slot.courtName,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(dateStr, style: textTheme.bodyMedium),
                    const SizedBox(height: 2),
                    Text('$startStr – $endStr', style: textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _SportTypeBadge(sportType: slot.sportType),
                  const SizedBox(height: 6),
                  _PlayerCountIndicator(
                    current: slot.currentPlayers,
                    max: slot.maxPlayers,
                    color: playerCountColor,
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    slot.accessPolicy == 'open' ? Icons.lock_open : Icons.lock,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SportTypeBadge extends StatelessWidget {
  const _SportTypeBadge({required this.sportType});

  final String sportType;

  @override
  Widget build(BuildContext context) {
    final label = SlotRow._sportTypeLabel(
      AppLocalizations.of(context),
      sportType,
    );

    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _PlayerCountIndicator extends StatelessWidget {
  const _PlayerCountIndicator({
    required this.current,
    required this.max,
    this.color,
  });

  final int current;
  final int max;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$current/$max',
      style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 14),
    );
  }
}
