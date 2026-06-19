// Sticky bottom confirm button for the booking screen.
// Extracted from booking_screen.dart.

import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class BottomConfirmBtn extends StatelessWidget {
  const BottomConfirmBtn({super.key, this.submitting = false, this.onConfirm});

  final bool submitting;
  final VoidCallback? onConfirm;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        child: FilledButton(
          onPressed: submitting ? null : onConfirm,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF16A34A),
            disabledBackgroundColor: const Color(0xFFD1D5DB),
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: submitting
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  AppLocalizations.of(context).bookingConfirmTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
