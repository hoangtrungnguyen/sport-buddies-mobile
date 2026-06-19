// Participants card for the booking detail screen.
// Extracted from booking_detail_screen.dart.

import 'package:customer/features/bookings/booking_detail_state.dart';
import 'package:customer/features/bookings/bookings_style.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ParticipantsCard extends StatelessWidget {
  const ParticipantsCard({super.key, required this.joinRequests});

  final List<JoinRequest> joinRequests;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final approved = joinRequests.where((r) => r.status == 'approved').toList();

    return Container(
      decoration: BoxDecoration(
        color: mdSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: mdOutlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      l10n.bookingDetailPlayers,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: mdOnSurface,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '· ${approved.length + 1}/4',
                      style: const TextStyle(
                        fontSize: 16,
                        color: mdOnSurfaceVariant,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: mdPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 32),
                  ),
                  child: Text(
                    l10n.bookingDetailInvite,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Host row (placeholder - real data would come from booking)
            _PlayerRow(
              name: l10n.bookingDetailYouHost,
              sub: l10n.bookingDetailHostRole,
              initials: 'TM',
              color: mdPrimary,
              isHost: true,
            ),
            if (approved.isNotEmpty) ...[
              const SizedBox(height: 12),
              for (final req in approved) ...[
                _PlayerRow(
                  name: req.userName,
                  sub: l10n.bookingDetailAcceptedAt(req.createdAt),
                  initials: _initials(req.userName),
                  color: mdSurfaceContainerHighest,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return (parts.first[0] + parts.last[0]).toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({
    required this.name,
    required this.sub,
    required this.initials,
    required this.color,
    this.isHost = false,
  });

  final String name;
  final String sub;
  final String initials;
  final Color color;
  final bool isHost;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Center(
            child: Text(
              initials,
              style: TextStyle(
                color: isHost ? mdOnPrimary : mdOnSurface,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: mdOnSurface,
                    ),
                  ),
                  if (isHost) ...[
                    const SizedBox(width: 6),
                    Container(
                      height: 18,
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      decoration: const BoxDecoration(
                        color: mdPrimaryContainer,
                        borderRadius: mdCornerFull,
                      ),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context).bookingDetailHostRole,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: mdOnPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                sub,
                style: const TextStyle(fontSize: 12, color: mdOnSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
