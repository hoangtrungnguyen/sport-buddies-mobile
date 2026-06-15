import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../../bloc/requests_bloc.dart';
import '../../model/booking_request.dart';
import '../../requests_logic.dart';
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
            _CardActions(request: request),
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

/// The Duyệt / Từ chối buttons shown on a pending card.
class _CardActions extends StatelessWidget {
  const _CardActions({required this.request});
  final BookingRequest request;

  Future<void> _reject(BuildContext context) async {
    final bloc = context.read<RequestsBloc>();
    final result = await showDialog<({String? reason})>(
      context: context,
      builder: (_) => _RejectDialog(code: request.code),
    );
    if (result == null) return; // dialog dismissed
    bloc.add(RequestsEvent.rejected(request, reason: result.reason));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Semantics(
          label: 'requests-reject-btn-${request.id}',
          button: true,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.close_rounded, size: 16),
            label: const Text('Từ chối'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: const BorderSide(color: AppColors.dangerBg),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              textStyle: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600, fontSize: 13),
            ),
            onPressed: () => _reject(context),
          ),
        ),
        const SizedBox(width: 8),
        Semantics(
          label: 'requests-approve-btn-${request.id}',
          button: true,
          child: FilledButton.icon(
            icon: const Icon(Icons.check_rounded, size: 16),
            label: const Text('Duyệt'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              textStyle: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600, fontSize: 13),
            ),
            // Single tap approves (≤ 2 taps per OWNER-28); undo via snackbar.
            onPressed: () =>
                context.read<RequestsBloc>().add(RequestsEvent.approved(request)),
          ),
        ),
      ],
    );
  }
}

/// Reject confirmation with an optional reason field (OWNER-29). Pops a record
/// `(reason:)` on confirm (reason null when blank), or null when dismissed.
class _RejectDialog extends StatefulWidget {
  const _RejectDialog({required this.code});
  final String code;

  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: Text(
        'Từ chối đơn ${widget.code}?',
        style: GoogleFonts.sora(
            fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.neutral900),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Khung giờ sẽ được mở lại cho khách khác.',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5, color: AppColors.neutral500),
          ),
          const SizedBox(height: 14),
          Semantics(
            label: 'requests-reject-reason-field',
            textField: true,
            child: TextField(
              controller: _ctrl,
              maxLines: 2,
              style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
              decoration: const InputDecoration(
                hintText: 'Lý do (không bắt buộc)',
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(foregroundColor: AppColors.neutral600),
          child: const Text('Huỷ'),
        ),
        Semantics(
          label: 'requests-reject-confirm-btn',
          button: true,
          child: FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.danger, foregroundColor: Colors.white),
            onPressed: () {
              final reason = _ctrl.text.trim();
              Navigator.of(context)
                  .pop((reason: reason.isEmpty ? null : reason));
            },
            child: const Text('Từ chối'),
          ),
        ),
      ],
    );
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
