// Address / directions card for the slot picker (taps to an external-maps
// fallback). Extracted from slot_picker_page.dart.

import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../domain/court.dart';
import '../../theme/app_tokens.dart';

class DirectionsCard extends StatelessWidget {
  const DirectionsCard({super.key, required this.court, required this.onTap});

  final Court court;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    return Material(
      color: scheme.surfaceContainerLowest,
      borderRadius: AppTokens.radiusMd,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: AppTokens.radiusMd,
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 92,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFDCFCE7), Color(0xFFBFDBFE)],
                    ),
                  ),
                  child: Icon(Icons.location_on, color: scheme.error, size: 28),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          court.address,
                          style: text.labelLarge,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.slotPickerDistanceDrive(
                            court.distanceKm.toStringAsFixed(1),
                          ),
                          style: text.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontFeatures: AppTokens.tnum,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.navigation_outlined,
                              size: 16,
                              color: scheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.slotPickerDirections,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: scheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Center(
                    child: Icon(
                      Icons.chevron_right,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
