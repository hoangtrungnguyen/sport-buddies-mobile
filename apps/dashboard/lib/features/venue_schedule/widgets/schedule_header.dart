import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../model/models.dart';
import 'hover_builder.dart';

/// Page header of the "Lịch sân" screen (`.page-head` in the handoff CSS):
/// title + subtitle on the left, the two global actions right-aligned.
///
/// Pure presentational — wire [onBlockPressed] / [onCreatePressed] to open
/// the Block / Create sheets. Stacks vertically on narrow layouts (the
/// prototype's ≤1024px behaviour).
class ScheduleHeader extends StatelessWidget {
  const ScheduleHeader({
    super.key,
    required this.onBlockPressed,
    required this.onCreatePressed,
  });

  /// "Khoá giờ" — opens the Block sheet.
  final VoidCallback onBlockPressed;

  /// "Tạo slot mới" — opens the Create sheet.
  final VoidCallback onCreatePressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 720;

        final title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Lịch sân',
              style: GoogleFonts.sora(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.52, // -0.02em × 26px
                height: 1.1,
                color: AppColors.neutral900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              // "mở ghép đội" only once matchmaking slots exist in the DB —
              // the subtitle must not advertise a gated feature.
              kMatchmakingEnabled
                  ? 'Xem theo ngày, tuần hoặc tháng · tạo slot, mở ghép đội, '
                      'khoá giờ.'
                  : 'Xem theo ngày, tuần hoặc tháng · tạo slot, khoá giờ.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                color: AppColors.neutral500,
              ),
            ),
          ],
        );

        final actions = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ActionButton(
              label: 'Khoá giờ',
              icon: Icons.lock_outline,
              onPressed: onBlockPressed,
            ),
            const SizedBox(width: 8),
            _ActionButton(
              label: 'Tạo slot mới',
              icon: Icons.add,
              primary: true,
              onPressed: onCreatePressed,
            ),
          ],
        );

        if (stacked) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [title, const SizedBox(height: 14), actions],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: title),
            const SizedBox(width: 16),
            actions,
          ],
        );
      },
    );
  }
}

/// `.btn` from the handoff CSS — 38px tall, radius 10, 13.5/600 label.
///
/// [primary] → `--primary` fill, white text, green-tinted shadow, hover
/// `--primary-dark`. Otherwise the secondary look: white, 1px `--n-200`
/// border, `--n-800` text, hover `--n-50` bg + `--n-300` border.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.primary = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return HoverBuilder(
      builder: (context, hovered) {
        final Color bg;
        final Color border;
        final Color fg;
        if (primary) {
          bg = hovered ? AppColors.primaryDark : AppColors.primary;
          border = Colors.transparent;
          fg = Colors.white;
        } else {
          bg = hovered ? AppColors.neutral50 : Colors.white;
          border = hovered ? AppColors.neutral300 : AppColors.neutral200;
          fg = AppColors.neutral800;
        }
        return GestureDetector(
          onTap: onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: bg,
              border: Border.all(color: border),
              borderRadius: BorderRadius.circular(10),
              boxShadow: primary
                  ? const [
                      // 0 1px 2px rgba(22,163,74,.24)
                      BoxShadow(
                        color: Color(0x3D16A34A),
                        offset: Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: fg),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: fg,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
