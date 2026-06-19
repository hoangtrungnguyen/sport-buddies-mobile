// Sticky bottom action bar for the booking detail screen.
// Extracted from booking_detail_screen.dart.

import 'package:customer/features/bookings/booking_model.dart';
import 'package:customer/features/bookings/bookings_style.dart';
import 'package:customer/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomActions extends StatelessWidget {
  const BottomActions({super.key, required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: mdSurface,
        border: Border(top: BorderSide(color: mdOutlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => context.push('/slot/${booking.slot.id}/manage'),
              style: OutlinedButton.styleFrom(
                foregroundColor: mdOnSurface,
                side: const BorderSide(color: mdOutlineVariant),
                shape: const RoundedRectangleBorder(borderRadius: mdCornerFull),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(l10n.bookingDetailManagePlayers),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.map_outlined, size: 18),
              label: Text(l10n.slotPickerDirections),
              style: FilledButton.styleFrom(
                backgroundColor: mdPrimary,
                foregroundColor: mdOnPrimary,
                shape: const RoundedRectangleBorder(borderRadius: mdCornerFull),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
