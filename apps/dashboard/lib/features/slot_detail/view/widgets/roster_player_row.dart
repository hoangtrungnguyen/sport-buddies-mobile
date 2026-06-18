import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../../../requests/model/booking_request.dart';
import '../../../requests/requests_logic.dart' show statusLabel;
import '../../model/slot_player.dart';
import '../../slot_roster_logic.dart';

/// One player row in the slot roster: avatar + name + booking badge, with the
/// payment-status chip trailing.
class RosterPlayerRow extends StatelessWidget {
  const RosterPlayerRow({super.key, required this.player});
  final SlotPlayer player;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'slot-player-${player.id}',
      container: true,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.neutral200),
        ),
        child: Row(
          children: [
            _Avatar(player: player),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neutral900,
                    ),
                  ),
                  if (player.bookingStatus != null) ...[
                    const SizedBox(height: 4),
                    _BookingBadge(status: player.bookingStatus!),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            _PaymentChip(player: player),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.player});
  final SlotPlayer player;

  @override
  Widget build(BuildContext context) {
    final url = player.avatarUrl;
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark]),
      ),
      clipBehavior: Clip.antiAlias,
      child: (url != null)
          ? Image.network(url, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _initial())
          : _initial(),
    );
  }

  Widget _initial() => Center(
        child: Text(
          player.initial,
          style: GoogleFonts.sora(
              fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      );
}

class _BookingBadge extends StatelessWidget {
  const _BookingBadge({required this.status});
  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      BookingStatus.pending => (AppColors.warningBg, const Color(0xFF854D0E)),
      BookingStatus.confirmed => (AppColors.successBg, const Color(0xFF166534)),
      BookingStatus.cancelled => (AppColors.neutral100, AppColors.neutral500),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
      child: Text(
        statusLabel(status),
        style: GoogleFonts.plusJakartaSans(
            fontSize: 11, fontWeight: FontWeight.w700, color: fg),
      ),
    );
  }
}

class _PaymentChip extends StatelessWidget {
  const _PaymentChip({required this.player});
  final SlotPlayer player;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = switch (player.paymentStatus) {
      PaymentStatus.paid => (
          AppColors.successBg,
          const Color(0xFF166534),
          Icons.check_circle_rounded,
        ),
      PaymentStatus.partial => (
          AppColors.warningBg,
          const Color(0xFF854D0E),
          Icons.timelapse_rounded,
        ),
      // AC#1 OWNER-35: Unpaid = yellow (warningBg).
      PaymentStatus.unpaid => (
          AppColors.warningBg,
          const Color(0xFF854D0E),
          Icons.schedule_rounded,
        ),
      PaymentStatus.unknown => (
          AppColors.neutral100,
          AppColors.neutral400,
          Icons.help_outline_rounded,
        ),
    };
    final methodLabel = paymentMethodLabel(player.paymentMethod);
    return Semantics(
      label: 'slot-player-payment-${player.id}',
      value: player.paymentStatus.name,
      container: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 5),
            Text(
              // Show payment method alongside the status when recorded (AC#4).
              methodLabel.isNotEmpty
                  ? '${paymentLabel(player.paymentStatus)} · $methodLabel'
                  : paymentLabel(player.paymentStatus),
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5, fontWeight: FontWeight.w700, color: fg),
            ),
          ],
        ),
      ),
    );
  }
}
