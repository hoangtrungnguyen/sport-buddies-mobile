import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../model/models.dart';
import '../style/slot_state_style.dart';

/// `.drawer-state-banner` — full-width state-tinted pill with icon + label.
class StateBanner extends StatelessWidget {
  const StateBanner({super.key, required this.state});

  final SlotState state;

  @override
  Widget build(BuildContext context) {
    final fg = slotStateBannerFg[state]!;
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: slotStateBannerBg[state],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(slotStateIcons[state], size: 16, color: fg),
          const SizedBox(width: 10),
          Text(
            slotStateLabels[state]!,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

/// `.detail-row` — `[110px label] [value]` grid with a bottom hairline.
class DetailRow extends StatelessWidget {
  const DetailRow({super.key, 
    required this.label,
    required this.value,
    this.divider = true,
  });

  final String label;
  final Widget value;
  final bool divider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: divider
          ? const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.neutral100)),
            )
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                color: AppColors.neutral500,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: DefaultTextStyle.merge(
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: AppColors.neutral900,
              ),
              child: value,
            ),
          ),
        ],
      ),
    );
  }
}

/// Payment badge (`.badge.pay.*` in the handoff CSS) — paid / partial /
/// unpaid pill on the "Thanh toán" row.
class PaymentBadge extends StatelessWidget {
  const PaymentBadge({super.key, required this.payment});

  final PaymentStatus payment;

  static const _labels = {
    PaymentStatus.paid: 'Đã thanh toán',
    PaymentStatus.partial: 'Đặt cọc',
    PaymentStatus.unpaid: 'Chưa TT',
  };
  static const _bg = {
    PaymentStatus.paid: AppColors.successBg, // .pay.paid
    PaymentStatus.partial: Color(0xFFFFEDD5), // .pay.partial
    PaymentStatus.unpaid: AppColors.warningBg, // .pay.unpaid
  };
  static const _fg = {
    PaymentStatus.paid: Color(0xFF15803D),
    PaymentStatus.partial: Color(0xFFC2410C),
    PaymentStatus.unpaid: Color(0xFF854D0E),
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
      decoration: BoxDecoration(
        color: _bg[payment],
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        _labels[payment]!,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: _fg[payment],
        ),
      ),
    );
  }
}

/// `.batch-preview` — green-tinted contextual info card (open / empty slots).
class InfoCard extends StatelessWidget {
  const InfoCard({super.key, required this.strong, required this.text});

  final String strong;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        border: Border.all(color: AppColors.primaryLight),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: strong,
              style: GoogleFonts.sora(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: text),
          ],
        ),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 12.5,
          color: AppColors.primaryDark,
          height: 1.5,
        ),
      ),
    );
  }
}

/// `.btn.btn-ghost.btn-sm.btn-icon-only` — the header's ✕ close button.
class GhostCloseButton extends StatefulWidget {
  const GhostCloseButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  State<GhostCloseButton> createState() => _GhostCloseButtonState();
}

class _GhostCloseButtonState extends State<GhostCloseButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          width: 38,
          height: 32,
          decoration: BoxDecoration(
            color: _hover ? AppColors.neutral100 : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.close, size: 16, color: AppColors.neutral700),
        ),
      ),
    );
  }
}

enum SheetButtonVariant { primary, secondary, danger }

/// `.btn` in the handoff CSS — 38px tall, radius 10, 13.5/600, 80ms hover.
///
/// `primary` = filled `--primary` (hover `--primary-dark`); `secondary` =
/// white + `--n-200` border (hover `--n-50` / `--n-300`); `danger` = white +
/// `--danger` text (hover `--danger-bg` fill + `--danger` border).
class SheetButton extends StatefulWidget {
  const SheetButton({super.key, 
    required this.label,
    this.icon,
    required this.variant,
    required this.onPressed,
  });

  final String label;
  final IconData? icon;
  final SheetButtonVariant variant;
  final VoidCallback onPressed;

  @override
  State<SheetButton> createState() => _SheetButtonState();
}

class _SheetButtonState extends State<SheetButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, Color border, List<BoxShadow> shadow) =
        switch (widget.variant) {
      SheetButtonVariant.primary => (
          _hover ? AppColors.primaryDark : AppColors.primary,
          Colors.white,
          Colors.transparent,
          // 0 1px 2px rgba(22,163,74,.24)
          const [
            BoxShadow(
              color: Color(0x3D16A34A),
              offset: Offset(0, 1),
              blurRadius: 2,
            ),
          ],
        ),
      SheetButtonVariant.secondary => (
          _hover ? AppColors.neutral50 : Colors.white,
          AppColors.neutral800,
          _hover ? AppColors.neutral300 : AppColors.neutral200,
          const <BoxShadow>[],
        ),
      SheetButtonVariant.danger => (
          _hover ? AppColors.dangerBg : Colors.white,
          _hover ? AppColors.dangerDark : AppColors.danger,
          _hover ? AppColors.danger : AppColors.neutral200,
          const <BoxShadow>[],
        ),
    };

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(10),
            boxShadow: shadow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 15, color: fg),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: fg,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
