// Venue presentation widgets for the slot picker: court context line, photo
// strip and the directions card. Extracted from slot_picker_screen.dart.

import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class VenuePhotosStrip extends StatelessWidget {
  const VenuePhotosStrip({super.key, required this.photos});

  final List<String> photos;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 2),
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final width = i == 0 ? 200.0 : 150.0;
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              photos[i],
              width: width,
              height: 118,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: width,
                height: 118,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF16A34A), Color(0xFF0EA5E9)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class DirectionsCard extends StatelessWidget {
  const DirectionsCard({super.key, required this.address});

  final String address;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
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
                child: const Center(
                  child: Icon(
                    Icons.location_on,
                    color: Color(0xFFEF4444),
                    size: 28,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.navigation_outlined,
                            size: 14,
                            color: Color(0xFF15803D),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AppLocalizations.of(context).slotPickerDirections,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF15803D),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Center(
                  child: Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CourtContextLine extends StatelessWidget {
  const CourtContextLine({super.key, this.courtName, this.courtAddress});

  final String? courtName;
  final String? courtAddress;

  @override
  Widget build(BuildContext context) {
    final name = courtName?.isNotEmpty == true
        ? courtName!
        : AppLocalizations.of(context).courtsDefaultName;
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
            overflow: TextOverflow.ellipsis,
          ),
          if (courtAddress != null && courtAddress!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              courtAddress!,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
