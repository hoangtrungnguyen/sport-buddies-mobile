// Brand visuals for the auth shell — the gradient marketing panel shown beside
// the form on wide screens, and the compact brand header stacked above it on
// narrow ones. Used by AuthLayout (auth_scaffold.dart).

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

/// Desktop left column: gradient background, brand mark, tagline and feature
/// pills.
class AuthBrandPanel extends StatelessWidget {
  const AuthBrandPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF052E16), Color(0xFF14532D), Color(0xFF166534)],
        ),
      ),
      child: Stack(
        children: [
          // Decorative radial glow
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryMid.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -40,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(56),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand mark
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primary, AppColors.primaryDark],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'S',
                          style: GoogleFonts.sora(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SportBuddies',
                          style: GoogleFonts.sora(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Bảng điều khiển chủ sân',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF86EFAC),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const Spacer(),

                // Tagline
                Text(
                  'Quản lý sân\nthông minh hơn.',
                  style: GoogleFonts.sora(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 40,
                    height: 1.15,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Duyệt đặt sân, xem lịch, theo dõi\ndoanh thu — tất cả trong một nơi.',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF86EFAC),
                    fontSize: 15,
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 40),

                // Feature pills
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: const [
                    _FeaturePill('Duyệt đặt sân tức thì'),
                    _FeaturePill('Lịch sân 7 ngày'),
                    _FeaturePill('Thống kê doanh thu'),
                    _FeaturePill('Quản lý khách hàng'),
                  ],
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: Colors.white.withValues(alpha: 0.1),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryMid,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact brand header stacked above the form on narrow screens.
class AuthMobileBrandHeader extends StatelessWidget {
  const AuthMobileBrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF052E16), Color(0xFF14532D)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                ),
                child: Center(
                  child: Text(
                    'S',
                    style: GoogleFonts.sora(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'SportBuddies',
                style: GoogleFonts.sora(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Quản lý sân\nthông minh hơn.',
            style: GoogleFonts.sora(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 28,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}
