import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../../requests_logic.dart';
import 'request_card.dart';

class RequestGroup extends StatelessWidget {
  const RequestGroup({super.key, required this.group, required this.dayCount});
  final BookingGroup group;

  /// Total bookings sharing this slot time across the whole day (not just this
  /// page) — keeps the count honest when a group straddles a page boundary.
  final int dayCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded,
                    size: 15, color: AppColors.neutral400),
                const SizedBox(width: 7),
                Text(
                  group.label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral700,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$dayCount đơn',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 12, color: AppColors.neutral400),
                ),
              ],
            ),
          ),
          for (final r in group.items) RequestCard(request: r),
        ],
      ),
    );
  }
}
