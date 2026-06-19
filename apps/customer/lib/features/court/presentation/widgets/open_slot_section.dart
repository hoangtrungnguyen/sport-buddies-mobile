import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/time_slot.dart';
import '../../theme/app_tokens.dart';
import 'count_badge.dart';
import 'sport_style.dart';

/// "Slot mở chơi ghép" section — shared by screens 07 and 09 (doc 02 §8).
///
/// [trailing] selects the per-screen affordance: a "Tham gia" button on 07,
/// a chevron on 09. Either way the row navigates to the slot-detail
/// placeholder (edges E4 / E10).
enum OpenSlotTrailing { joinButton, chevron }

class OpenSlotSection extends StatelessWidget {
  const OpenSlotSection({
    super.key,
    required this.slots,
    required this.helper,
    required this.trailing,
  });

  final List<OpenGroupSlot> slots;
  final String helper;
  final OpenSlotTrailing trailing;

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) return const SizedBox.shrink();
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(l10n.browseOpenMatchSlots, style: text.titleMedium),
            const SizedBox(width: 8),
            CountBadge(label: '${slots.length} slot'),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          helper,
          style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < slots.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _OpenSlotCard(slot: slots[i], trailing: trailing),
        ],
      ],
    );
  }
}

class _OpenSlotCard extends StatelessWidget {
  const _OpenSlotCard({required this.slot, required this.trailing});

  final OpenGroupSlot slot;
  final OpenSlotTrailing trailing;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final sportColor = SportStyle.color(slot.sport);

    void open() => context.push('/browse/slot/${slot.id}');

    return Material(
      color: scheme.surfaceContainerLow,
      borderRadius: AppTokens.radiusMd,
      child: InkWell(
        onTap: open,
        borderRadius: AppTokens.radiusMd,
        child: Ink(
          decoration: const BoxDecoration(
            boxShadow: AppTokens.elev1,
            borderRadius: AppTokens.radiusMd,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: sportColor.withValues(alpha: 0.1),
                    borderRadius: AppTokens.radiusMd,
                  ),
                  child: Icon(
                    SportStyle.icon(slot.sport),
                    size: 24,
                    color: sportColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(slot.courtLabel, style: text.titleSmall),
                      const SizedBox(height: 2),
                      Text(
                        slot.timeLabel,
                        style: text.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontFeatures: AppTokens.tnum,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.group_outlined,
                            size: 14,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.slotsPlayersFraction(slot.joined, slot.max),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface,
                              fontFeatures: AppTokens.tnum,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '· ${l10n.browseSlotsLeft(slot.placesLeft)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: scheme.primary,
                              fontFeatures: AppTokens.tnum,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (trailing == OpenSlotTrailing.joinButton)
                  FilledButton(onPressed: open, child: Text(l10n.browseJoin))
                else
                  Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
