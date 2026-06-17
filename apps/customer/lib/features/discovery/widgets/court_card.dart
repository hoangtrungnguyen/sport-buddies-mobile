// Court list row + availability badge — shared by the discovery list body and
// the search overlay (doc 02 §2).

import 'package:customer/features/discovery/discovery_style.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:spb_core/spb_core.dart';

class CourtCard extends StatelessWidget {
  const CourtCard({
    super.key,
    required this.court,
    required this.distanceKm,
    required this.onTap,
  });

  final CourtAvailability court;
  final double? distanceKm;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasSlots = court.openSlotCount > 0;
    final sportColor = sportColorFor(court.sportTypes);
    final sportLabel = court.sportTypes.firstOrNull ?? l10n.sportGeneric;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: mdSurfaceContainerLowest,
          borderRadius: BorderRadius.circular(mdCornerLg),
          border: Border.all(color: mdOutlineVariant),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Leading sport tile with sport-label chip
            SizedBox(
              width: 84,
              height: 84,
              child: Stack(
                children: [
                  Opacity(
                    opacity: hasSlots ? 1 : 0.7,
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [sportColor, sportColor.withAlpha(204)],
                        ),
                        borderRadius: BorderRadius.circular(mdCornerMd),
                      ),
                      child: Icon(
                        sportIconFor(court.sportTypes),
                        size: 34,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 6,
                    bottom: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(235),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        sportLabel,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2B2F28),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Body
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          court.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: hasSlots
                                ? mdOnSurface
                                : mdOnSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      AvailabilityBadge(openSlotCount: court.openSlotCount),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.place_outlined,
                          size: 16, color: Color(0xFF9AA3AF)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          sportLabel,
                          style: const TextStyle(
                            fontSize: 13,
                            color: mdOnSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (distanceKm != null) ...[
                        const Text(
                          ' · ',
                          style: TextStyle(
                              fontSize: 13, color: mdOnSurfaceVariant),
                        ),
                        Text(
                          l10n.distanceKm(formatKm(distanceKm!)),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF42493F),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AvailabilityBadge extends StatelessWidget {
  const AvailabilityBadge({super.key, required this.openSlotCount});

  final int openSlotCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasSlots = openSlotCount > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: hasSlots ? mdPrimaryContainer : mdSurfaceContainerHigh,
        borderRadius: BorderRadius.circular(mdCornerSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: hasSlots ? mdPrimary : mdOutline,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            hasSlots
                ? l10n.availabilityOpenSlots(openSlotCount)
                : l10n.availabilityFull,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: hasSlots ? mdOnPrimaryContainer : mdOnSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
