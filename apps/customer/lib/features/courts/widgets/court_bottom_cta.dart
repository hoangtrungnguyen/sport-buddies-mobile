// Sticky bottom call-to-action bar for the court detail screen.
// Extracted from court_detail_screen.dart.

import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomCta extends StatelessWidget {
  const BottomCta({
    super.key,
    required this.courtId,
    required this.openSlotCount,
    this.pricePerHour,
    this.courtName,
    this.courtAddress,
  });

  final String courtId;
  final double? pricePerHour;
  final int openSlotCount;
  final String? courtName;
  final String? courtAddress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final priceLabel = pricePerHour != null
        ? '${(pricePerHour! / 1000).toStringAsFixed(pricePerHour! % 1000 == 0 ? 0 : 1)}k'
        : '–';

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 10, 20, safeBottom + 4),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
          boxShadow: [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 12,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.courtsPriceFrom,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: priceLabel,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                          if (pricePerHour != null)
                            TextSpan(
                              text: l10n.courtsPerHourSuffix,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: openSlotCount > 0
                        ? () => context.push(
                            '/court/$courtId/slots',
                            extra: <String, String?>{
                              'name': courtName,
                              'address': courtAddress,
                            },
                          )
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: openSlotCount > 0
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFD1D5DB),
                      disabledBackgroundColor: const Color(0xFFD1D5DB),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      openSlotCount > 0
                          ? l10n.courtsBookNow
                          : l10n.courtsSoldOutToday,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: openSlotCount > 0
                            ? Colors.white
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (openSlotCount == 0) ...[
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => context.push('/court/$courtId/schedule'),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_month_outlined,
                      size: 16,
                      color: Color(0xFF0EA5E9),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.courtsViewUpcoming,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF0EA5E9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: Color(0xFF0EA5E9),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
