import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/court.dart';

/// Opens the court's location in the user's chosen map app. Presents a sheet so
/// the user picks Apple Maps or Google Maps, then launches a coordinate-based
/// URL. Shared by the court detail screen and the slot picker.
Future<void> openCourtInMaps(BuildContext context, Court court) async {
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
