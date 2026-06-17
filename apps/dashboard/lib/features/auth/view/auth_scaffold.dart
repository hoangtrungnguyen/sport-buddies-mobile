// Shared chrome for the auth screens (login, signup). Extracted so both
// screens render an identical brand panel / responsive layout and reuse the
// same field-label and banner styling.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import 'auth_brand_panel.dart';

/// Responsive auth shell: a branded left panel beside [form] on wide screens,
/// or a compact brand header stacked above [form] on narrow ones.
class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, required this.form});

  /// The fully-styled form panel (e.g. login or signup form).
  final Widget form;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          if (isWide) {
            return Row(
              children: [
                const Expanded(child: AuthBrandPanel()),
                SizedBox(width: 480, child: form),
              ],
            );
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                const AuthMobileBrandHeader(),
                form,
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable form bits
// ---------------------------------------------------------------------------

class AuthFieldLabel extends StatelessWidget {
  const AuthFieldLabel({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.neutral700,
      ),
    );
  }
}

class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.dangerBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 16, color: AppColors.danger),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppColors.dangerDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
