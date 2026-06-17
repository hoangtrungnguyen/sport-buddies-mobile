import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../../model/booking_request.dart';
import '../../requests_logic.dart';
import 'request_card_actions.dart';
import 'request_tokens.dart';

class RequestCard extends StatelessWidget {
  const RequestCard({super.key, required this.request});
  final BookingRequest request;

  @override
  Widget build(BuildContext context) {
    final cancelled = request.isCancelled;
    final phone = request.revealedPhone;
    final card = Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(name: request.customerName, greyed: cancelled),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            request.customerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.neutral900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          request.code,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutral400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.place_rounded,
                            size: 13, color: AppColors.neutral400),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            request.courtName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5, color: AppColors.neutral500),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.schedule_rounded,
                            size: 13, color: AppColors.neutral400),
                        const SizedBox(width: 4),
                        Text(
                          timeRange(request.startAt.toLocal(),
                              request.endAt.toLocal()),
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5, color: AppColors.neutral500),
                        ),
                      ],
                    ),
                    if (request.venueName.isNotEmpty ||
                        request.sportType.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.sports_rounded,
                              size: 13, color: AppColors.neutral400),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              [
                                if (request.venueName.isNotEmpty)
                                  request.venueName,
                                if (request.sportType.isNotEmpty)
                                  request.sportType,
                              ].join(' · '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  color: AppColors.neutral500),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _StatusBadge(status: request.status),
                  // OWNER-45: "Tự động" label for auto-approved confirmed bookings.
                  if (request.isAutoApproved && request.isConfirmed) ...[
                    const SizedBox(height: 4),
                    _AutoLabel(),
                  ],
                ],
              ),
            ],
          ),
          // Phone is revealed only after approval (OWNER-28).
          if (phone != null) ...[
            const SizedBox(height: 10),
            Semantics(
              label: 'requests-phone-${request.id}',
              child: Row(
                children: [
                  const Icon(Icons.phone_rounded,
                      size: 14, color: Color(0xFF166534)),
                  const SizedBox(width: 6),
                  Text(
                    phone,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral700,
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Approve / reject actions appear only while pending (OWNER-28/29).
          if (request.isPending) ...[
            const SizedBox(height: 12),
            RequestCardActions(request: request),
          ],
        ],
      ),
    );

    final labelled = Semantics(
      label: 'requests-card-${request.id}',
      child: card,
    );
    // Cancelled bookings are de-emphasized (reduced opacity), per OWNER-27 AC.
    return cancelled ? Opacity(opacity: 0.55, child: labelled) : labelled;
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.greyed});
  final String name;
  final bool greyed;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: greyed
            ? null
            : const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark]),
        color: greyed ? AppColors.neutral200 : null,
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.sora(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: greyed ? AppColors.neutral500 : Colors.white,
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      BookingStatus.pending => (AppColors.warningBg, pendingFg),
      BookingStatus.confirmed => (AppColors.successBg, confirmedFg),
      BookingStatus.cancelled => (AppColors.neutral100, AppColors.neutral500),
    };
    return Semantics(
      label: 'requests-status-${status.name}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          statusLabel(status),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: fg,
          ),
        ),
      ),
    );
  }
}

/// "Tự động" mini-chip shown under the status badge for auto-approved bookings
/// (OWNER-45).
class _AutoLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Semantics(
        label: 'requests-auto-approved',
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.neutral100,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  size: 10, color: AppColors.neutral500),
              const SizedBox(width: 4),
              Text(
                'Tự động',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral500,
                ),
              ),
            ],
          ),
        ),
      );
}
