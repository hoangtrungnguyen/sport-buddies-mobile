import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

class RequestsHeader extends StatelessWidget {
  const RequestsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Yêu cầu đặt sân',
          style: GoogleFonts.sora(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Theo dõi và xử lý các đơn đặt sân trong ngày.',
          style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5, color: AppColors.neutral500),
        ),
      ],
    );
  }
}
