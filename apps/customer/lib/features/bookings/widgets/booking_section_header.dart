// Small uppercase date/section label heading used between booking groups.
// Extracted from booking_tab_views.dart.

import 'package:customer/features/bookings/bookings_style.dart';
import 'package:flutter/material.dart';

class BookingSectionHeader extends StatelessWidget {
  const BookingSectionHeader({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: mdOnSurfaceVariant,
        letterSpacing: 0.5,
      ),
    );
  }
}
