import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../../bloc/requests_bloc.dart';
import '../../model/booking_request.dart';

/// The Duyệt / Từ chối buttons shown on a pending request card. Approve is a
/// single tap (undo via snackbar, OWNER-28); reject opens [_RejectDialog] for
/// an optional reason (OWNER-29).
class RequestCardActions extends StatelessWidget {
  const RequestCardActions({super.key, required this.request});
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
