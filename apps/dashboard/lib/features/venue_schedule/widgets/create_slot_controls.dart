import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

/// `seg-opt` — one radio card of the type picker: 1.5px border, radius 10;
/// active = `--primary` border + `--primary-50` bg + `--primary-dark` title.
class KindCard extends StatefulWidget {
  const KindCard({super.key, 
    required this.active,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final bool active;
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  State<KindCard> createState() => _KindCardState();
}

class _KindCardState extends State<KindCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final titleColor =
        widget.active ? AppColors.primaryDark : AppColors.neutral800;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
          decoration: BoxDecoration(
            color: widget.active
                ? AppColors.primary50
                : (_hovered ? AppColors.neutral50 : Colors.white),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              width: 1.5,
              color: widget.active
                  ? AppColors.primary
                  : (_hovered ? AppColors.neutral300 : AppColors.neutral200),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // `.so-t` — icon + title 13/700.
              Row(
                children: [
                  Icon(widget.icon, size: 14, color: titleColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              // `.so-d` — one-line description 11 `--n-500`.
              Text(
                widget.description,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppColors.neutral500,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// `day-toggle` — 38×38 weekday square (or the 46×26 BẬT/TẮT pill); on =
/// `--primary` filled, white text.
class ToggleButton extends StatelessWidget {
  const ToggleButton({super.key, 
    required this.label,
    required this.on,
    required this.onTap,
    this.width = 38,
    this.height = 38,
    this.radius = 9,
  });

  final String label;
  final bool on;
  final VoidCallback onTap;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              width: 1.5,
              color: on ? AppColors.primary : AppColors.neutral200,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: on ? Colors.white : AppColors.neutral600,
            ),
          ),
        ),
      ),
    );
  }
}

/// `.btn` — 38px, radius 10, 13.5/600; primary (green, white text) or
/// secondary (white, `--n-200` border). A null [onTap] renders the button
/// disabled (dimmed, basic cursor).
class SheetButton extends StatefulWidget {
  const SheetButton({super.key, 
    required this.label,
    required this.onTap,
    this.icon,
    this.primary = false,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool primary;

  @override
  State<SheetButton> createState() => _SheetButtonState();
}

class _SheetButtonState extends State<SheetButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final hovered = _hovered && enabled;
    final Color bg;
    final Color fg;
    final Color borderColor;
    if (widget.primary) {
      bg = hovered ? AppColors.primaryDark : AppColors.primary;
      fg = Colors.white;
      borderColor = Colors.transparent;
    } else {
      bg = hovered ? AppColors.neutral50 : Colors.white;
      fg = AppColors.neutral800;
      borderColor = hovered ? AppColors.neutral300 : AppColors.neutral200;
    }
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Opacity(
          opacity: enabled ? 1 : 0.55,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor),
              boxShadow: widget.primary
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
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 15, color: fg),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    widget.label,
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
      ),
    );
  }
}

/// `btn-ghost btn-sm btn-icon-only` — the drawer's ✕ button.
class GhostIconButton extends StatefulWidget {
  const GhostIconButton({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  State<GhostIconButton> createState() => _GhostIconButtonState();
}

class _GhostIconButtonState extends State<GhostIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 38,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _hovered ? AppColors.neutral100 : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(widget.icon, size: 16, color: AppColors.neutral700),
        ),
      ),
    );
  }
}
