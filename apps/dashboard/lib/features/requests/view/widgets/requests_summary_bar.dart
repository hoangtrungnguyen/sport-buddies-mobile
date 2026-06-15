import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../../requests_logic.dart';
import 'request_tokens.dart';

class RequestsSummaryBar extends StatelessWidget {
  const RequestsSummaryBar({super.key, required this.summary});
  final RequestsSummary summary;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      _StatCard(
        semantics: 'requests-summary-total',
        label: 'Tổng đơn',
        value: summary.total.toString(),
        icon: Icons.receipt_long_rounded,
        accent: AppColors.primary,
        accentBg: AppColors.primaryLight,
      ),
      _StatCard(
        semantics: 'requests-summary-pending',
        label: 'Chờ xác nhận',
        value: summary.pending.toString(),
        icon: Icons.hourglass_top_rounded,
        accent: pendingFg,
        accentBg: AppColors.warningBg,
      ),
      _StatCard(
        semantics: 'requests-summary-revenue',
        label: 'Doanh thu dự kiến',
        value: formatVnd(summary.expectedRevenue),
        icon: Icons.payments_rounded,
        accent: confirmedFg,
        accentBg: AppColors.successBg,
      ),
    ];

    return LayoutBuilder(
      builder: (context, c) {
        // Stack vertically on mobile widths (the shell renders content
        // full-width below 1024) so the revenue value never truncates.
        if (c.maxWidth < 640) {
          return Column(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                cards[i],
              ],
            ],
          );
        }
        return Row(
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(width: 14),
              Expanded(child: cards[i]),
            ],
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.semantics,
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    required this.accentBg,
  });
  final String semantics;
  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final Color accentBg;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semantics,
      value: value,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.neutral200),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accentBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 19, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12, color: AppColors.neutral500),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: GoogleFonts.sora(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: AppColors.neutral900,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
