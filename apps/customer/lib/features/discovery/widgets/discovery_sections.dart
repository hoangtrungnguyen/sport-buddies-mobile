// Body sections for the discovery list screen: count line, all-full banner
// and the empty state. Extracted from discovery_list_screen.dart.

import 'package:customer/features/discovery/discovery_style.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class CountLine extends StatelessWidget {
  const CountLine({
    super.key,
    required this.courtCount,
    required this.openSlots,
  });

  final int courtCount;
  final int openSlots;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: l10n.discoveryCourtsCount(courtCount),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: mdOnSurfaceVariant,
                ),
              ),
              TextSpan(
                text: ' · ${l10n.availabilityOpenSlots(openSlots)}',
                style: const TextStyle(fontSize: 13, color: mdOnSurfaceVariant),
              ),
            ],
          ),
        ),
        Text(
          l10n.discoverySortNearest,
          style: const TextStyle(fontSize: 13, color: mdOnSurfaceVariant),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// AllFullBanner
// ---------------------------------------------------------------------------

class AllFullBanner extends StatelessWidget {
  const AllFullBanner({
    super.key,
    required this.courtCount,
    required this.onSlots,
  });

  final int courtCount;
  final VoidCallback onSlots;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: warningBg,
        border: Border.all(color: warningBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFF59E0B),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.discoveryAllFullTitle,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: warningText,
              ),
            ),
          ),
          GestureDetector(
            onTap: onSlots,
            child: Text(
              l10n.discoveryAllFullAction,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: warningText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// EmptyState (doc 02 §6)
// ---------------------------------------------------------------------------

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.onlyOpen,
    required this.onExpand,
    required this.onReset,
  });

  final bool onlyOpen;
  final VoidCallback onExpand;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: mdSurfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off,
                size: 32,
                color: mdOnSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              onlyOpen
                  ? l10n.discoveryEmptyNoOpen
                  : l10n.discoveryEmptyNoCourts,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: mdOnSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.discoveryEmptyBody,
              style: const TextStyle(
                fontSize: 13,
                color: mdOnSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onExpand,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: mdOutlineVariant),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(mdCornerFull),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      l10n.discoveryEmptyExpand,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: mdOnSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: onReset,
                    style: FilledButton.styleFrom(
                      backgroundColor: mdPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(mdCornerFull),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      l10n.discoveryEmptyResetFilters,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: mdOnPrimary,
                      ),
                    ),
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
