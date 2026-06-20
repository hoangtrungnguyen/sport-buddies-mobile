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
          _header(cancelled),
          // Phone is revealed only after approval (OWNER-28).
          if (phone != null) ...[
            const SizedBox(height: 10),
            _phoneRow(phone),
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

  /// Avatar + customer info + status column.
  Widget _header(bool cancelled) {
    return Row(
      children: [
        _Avatar(name: request.customerName, greyed: cancelled),
        const SizedBox(width: 12),
        Expanded(child: _customerInfo()),
        const SizedBox(width: 10),
        _statusColumn(),
      ],
    );
  }

  /// Name + code, then the court/time and optional venue/sport meta rows.
  Widget _customerInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _nameRow(),
        const SizedBox(height: 4),
        _locationTimeRow(),
        if (request.venueName.isNotEmpty || request.sportType.isNotEmpty) ...[
          const SizedBox(height: 3),
          _venueSportRow(),
        ],
      ],
    );
  }

  /// Customer name (ellipsised) + the short booking code.
  Widget _nameRow() {
    return Row(
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
    );
  }

  /// Court name + booking time, each with its meta icon.
  Widget _locationTimeRow() {
    return Row(
      children: [
        _metaIcon(Icons.place_rounded),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            request.courtName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _metaStyle,
          ),
        ),
        const SizedBox(width: 10),
        _metaIcon(Icons.schedule_rounded),
        const SizedBox(width: 4),
        Text(
          timeRange(request.startAt.toLocal(), request.endAt.toLocal()),
          style: _metaStyle,
        ),
      ],
    );
  }

  /// Optional "venue · sport" meta line (rendered only when either is set).
  Widget _venueSportRow() {
    return Row(
      children: [
        _metaIcon(Icons.sports_rounded),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            [
              if (request.venueName.isNotEmpty) request.venueName,
              if (request.sportType.isNotEmpty) request.sportType,
            ].join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _metaStyle,
          ),
        ),
      ],
    );
  }

  /// Status badge, plus the "Tự động" label for auto-approved confirmed
  /// bookings (OWNER-45).
  Widget _statusColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _StatusBadge(status: request.status),
        if (request.isAutoApproved && request.isConfirmed) ...[
          const SizedBox(height: 4),
          _AutoLabel(),
        ],
      ],
    );
  }

  /// Revealed customer phone (shown only after approval, OWNER-28).
  Widget _phoneRow(String phone) {
    return Semantics(
      label: 'requests-phone-${request.id}',
      child: Row(
        children: [
          const Icon(Icons.phone_rounded, size: 14, color: Color(0xFF166534)),
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
    );
  }

  /// The neutral leading icon shared by the meta rows.
  Widget _metaIcon(IconData icon) =>
      Icon(icon, size: 13, color: AppColors.neutral400);

  /// Shared text style for the court / time / venue meta lines.
  TextStyle get _metaStyle =>
      GoogleFonts.plusJakartaSans(fontSize: 12.5, color: AppColors.neutral500);
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
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
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
