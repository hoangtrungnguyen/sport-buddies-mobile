// Join-requests card (host approves/declines) for the booking detail screen.
// Extracted from booking_detail_screen.dart.

import 'package:customer/features/bookings/booking_detail_cubit.dart';
import 'package:customer/features/bookings/booking_detail_state.dart';
import 'package:customer/features/bookings/bookings_style.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class JoinRequestsCard extends StatelessWidget {
  const JoinRequestsCard({
    super.key,
    required this.joinRequests,
    required this.slotId,
    required this.processing,
  });

  final List<JoinRequest> joinRequests;
  final String slotId;
  final Set<String> processing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pending = joinRequests.where((r) => r.status == 'pending').toList();

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
              children: [
                Text(
                  l10n.bookingDetailJoinRequests,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: mdOnSurface,
                  ),
                ),
                if (pending.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    height: 20,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: const BoxDecoration(
                      color: mdTertiaryContainer,
                      borderRadius: mdCornerFull,
                    ),
                    child: Center(
                      child: Text(
                        l10n.bookingDetailNewCount(pending.length),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: mdOnTertiaryContainer,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            if (pending.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  l10n.bookingDetailNoRequests,
                  style: const TextStyle(
                    fontSize: 13,
                    color: mdOnSurfaceVariant,
                  ),
                ),
              )
            else
              for (int i = 0; i < pending.length; i++) ...[
                if (i > 0) ...[
                  const SizedBox(height: 12),
                  Container(height: 1, color: mdOutlineVariant),
                  const SizedBox(height: 12),
                ],
                _RequestRow(
                  request: pending[i],
                  slotId: slotId,
                  busy: processing.contains(pending[i].id),
                ),
              ],
          ],
        ),
      ),
    );
  }
}

class _RequestRow extends StatelessWidget {
  const _RequestRow({
    required this.request,
    required this.slotId,
    required this.busy,
  });

  final JoinRequest request;
  final String slotId;

  /// An approve/reject call for this request is in flight.
  final bool busy;

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return (parts.first[0] + parts.last[0]).toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: mdSurfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _initials(request.userName),
                  style: const TextStyle(
                    color: mdOnSurface,
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
                  Text(
                    request.userName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: mdOnSurface,
                    ),
                  ),
                  Text(
                    request.status,
                    style: const TextStyle(
                      fontSize: 12,
                      color: mdOnSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: busy
                    ? null
                    : () => context.read<BookingDetailCubit>().reject(
                        request.id,
                        slotId,
                      ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: mdError,
                  side: const BorderSide(color: mdOutlineVariant),
                  shape: const RoundedRectangleBorder(borderRadius: mdCornerMd),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: Text(
                  l10n.bookingJoinRejected,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: busy
                    ? null
                    : () => context.read<BookingDetailCubit>().approve(
                        request.id,
                        slotId,
                      ),
                style: FilledButton.styleFrom(
                  backgroundColor: mdPrimary,
                  foregroundColor: mdOnPrimary,
                  disabledBackgroundColor: mdSurfaceContainerHighest,
                  shape: const RoundedRectangleBorder(borderRadius: mdCornerMd),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: mdOnPrimary,
                        ),
                      )
                    : Text(
                        l10n.bookingDetailAccept,
                        style: const TextStyle(fontSize: 13),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
