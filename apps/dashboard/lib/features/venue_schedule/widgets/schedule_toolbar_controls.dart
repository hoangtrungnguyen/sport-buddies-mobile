import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../model/models.dart';

/// `.date-nav` — white pill (1px `--n-200`, radius 10, padding 4) with ‹ / ›
/// arrow buttons around a Sora 13/600 label.
class ScheduleDateNav extends StatelessWidget {
  const ScheduleDateNav({
    super.key,
    required this.label,
    required this.onPrev,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.neutral200),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ArrowButton(icon: Icons.chevron_left, onPressed: onPrev),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              label,
              style: GoogleFonts.sora(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral900,
              ),
            ),
          ),
          _ArrowButton(icon: Icons.chevron_right, onPressed: onNext),
        ],
      ),
    );
  }
}

/// `.date-nav .arr` — 30×30, radius 8, hover `--n-100` bg + `--n-900` icon.
class _ArrowButton extends StatefulWidget {
  const _ArrowButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  State<_ArrowButton> createState() => _ArrowButtonState();
}

class _ArrowButtonState extends State<_ArrowButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: _hovered ? AppColors.neutral100 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            widget.icon,
            size: 16,
            color: _hovered ? AppColors.neutral900 : AppColors.neutral600,
          ),
        ),
      ),
    );
  }
}

/// "Hôm nay" — `.btn-secondary.btn-sm`: 32px tall, 12.5/600, white bg,
/// 1px `--n-200` border, hover `--n-50` bg + `--n-300` border.
class ScheduleTodayButton extends StatefulWidget {
  const ScheduleTodayButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  State<ScheduleTodayButton> createState() => _ScheduleTodayButtonState();
}

class _ScheduleTodayButtonState extends State<ScheduleTodayButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _hovered ? AppColors.neutral50 : Colors.white,
            border: Border.all(
              color: _hovered ? AppColors.neutral300 : AppColors.neutral200,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'Hôm nay',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral800,
            ),
          ),
        ),
      ),
    );
  }
}

/// `.view-switch` — segmented control: `--n-100` pill (padding 3, radius 10);
/// active segment is white with `--shadow-sm` and `--n-900` text. Labels hide
/// below 640px viewport width (icon-only, like the prototype's media query).
class ScheduleViewSwitch extends StatelessWidget {
  const ScheduleViewSwitch({
    super.key,
    required this.active,
    required this.onChanged,
  });

  final ScheduleView active;
  final ValueChanged<ScheduleView> onChanged;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final iconOnly = screenWidth < 640;
    final compact = screenWidth < 1024;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Prototype icons: 'columns' (resource columns) / 'calendar' /
          // 'grid' — keep Day and Month visually distinct.
          for (final (view, icon, label) in const [
            (ScheduleView.day, Icons.view_column_outlined, 'Ngày'),
            (ScheduleView.week, Icons.calendar_today_outlined, 'Tuần'),
            (ScheduleView.month, Icons.grid_on, 'Tháng'),
          ])
            _ViewSwitchButton(
              icon: icon,
              label: label,
              active: view == active,
              iconOnly: iconOnly,
              compact: compact,
              onPressed: () => onChanged(view),
            ),
        ],
      ),
    );
  }
}

class _ViewSwitchButton extends StatefulWidget {
  const _ViewSwitchButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.iconOnly,
    required this.compact,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool active;
  final bool iconOnly;
  final bool compact;
  final VoidCallback onPressed;

  @override
  State<_ViewSwitchButton> createState() => _ViewSwitchButtonState();
}

class _ViewSwitchButtonState extends State<_ViewSwitchButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final fg =
        widget.active || _hovered ? AppColors.neutral900 : AppColors.neutral600;
    final padding = widget.iconOnly
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
        : widget.compact
            ? const EdgeInsets.symmetric(horizontal: 11, vertical: 7)
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 7);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          padding: padding,
          decoration: BoxDecoration(
            color: widget.active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            boxShadow: widget.active
                ? const [
                    // --shadow-sm
                    BoxShadow(
                      color: Color(0x0A111827),
                      offset: Offset(0, 1),
                      blurRadius: 2,
                    ),
                    BoxShadow(
                      color: Color(0x08111827),
                      offset: Offset(0, 1),
                      blurRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 15, color: fg),
              if (!widget.iconOnly) ...[
                const SizedBox(width: 7),
                Text(
                  widget.label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: fg,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
