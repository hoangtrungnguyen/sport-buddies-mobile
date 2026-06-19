// Court title block: name, rating/reviews/distance and the tap-to-open-maps
// address row. Extracted from court_detail_page.dart.

import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/court.dart';
import '../../theme/app_tokens.dart';

class TitleBlock extends StatelessWidget {
  const TitleBlock({super.key, required this.court});

  final Court court;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);
    final muted = text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(court.name, style: text.headlineSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.star_rounded, size: 18, color: scheme.tertiary),
            const SizedBox(width: 4),
            Text(
              court.rating.toStringAsFixed(1),
              style: text.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
                fontFeatures: AppTokens.tnum,
              ),
            ),
            _Sep(scheme: scheme),
            Text(l10n.courtDetailReviews(court.reviewCount), style: muted),
            _Sep(scheme: scheme),
            Text(
              l10n.distanceKm(court.distanceKm.toStringAsFixed(1)),
              style: muted,
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Tap the address → open it in an external map app (doc: directions).
        InkWell(
          onTap: () => _openCourtInMaps(context, court),
          borderRadius: AppTokens.radiusSm,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(child: Text(court.address, style: muted)),
                const SizedBox(width: 6),
                Icon(
                  Icons.directions_outlined,
                  size: 18,
                  color: scheme.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Opens the court's location in the user's chosen map app. Presents a sheet so
/// the user picks Apple Maps or Google Maps; launches a coordinate-based URL.
Future<void> _openCourtInMaps(BuildContext context, Court court) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final label = Uri.encodeComponent(court.name);
  final appleUrl = Uri.parse(
    'https://maps.apple.com/?ll=${court.lat},${court.lng}&q=$label',
  );
  final googleUrl = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=${court.lat},${court.lng}',
  );

  final choice = await showModalBottomSheet<Uri>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      final text = Theme.of(ctx).textTheme;
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.courtDetailOpenAddressIn,
                  style: text.titleMedium,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.map_outlined),
              title: Text(l10n.courtDetailAppleMaps),
              onTap: () => Navigator.of(ctx).pop(appleUrl),
            ),
            ListTile(
              leading: const Icon(Icons.navigation_outlined),
              title: Text(l10n.courtDetailGoogleMaps),
              onTap: () => Navigator.of(ctx).pop(googleUrl),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );

  if (choice == null) return;
  final launched = await launchUrl(
    choice,
    mode: LaunchMode.externalApplication,
  );
  if (!launched) {
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.courtDetailMapsUnavailable)),
    );
  }
}

class _Sep extends StatelessWidget {
  const _Sep({required this.scheme});
  final ColorScheme scheme;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Text('·', style: TextStyle(color: scheme.outlineVariant)),
  );
}
