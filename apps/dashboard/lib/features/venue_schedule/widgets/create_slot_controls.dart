import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../util/schedule_format.dart';

/// `.form-field label` — 12.5/600 `--n-700` field caption.
TextStyle get sheetLabelStyle => GoogleFonts.plusJakartaSans(
      fontSize: 12.5,
      fontWeight: FontWeight.w600,
      color: AppColors.neutral700,
    );

/// `.hint` — 11.5 `--n-500` helper line under a field.
TextStyle get sheetHintStyle => GoogleFonts.plusJakartaSans(
      fontSize: 11.5,
      color: AppColors.neutral500,
      height: 1.4,
    );

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

/// `.select` — 40px white field, 1px `--n-200` border, radius 9.
class SheetSelect<T> extends StatelessWidget {
  const SheetSelect({
    super.key,
    required this.value,
    required this.options,
    required this.labelOf,
    required this.onChanged,
  });

  final T? value;
  final List<T> options;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Center(
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            isDense: true,
            borderRadius: BorderRadius.circular(9),
            dropdownColor: Colors.white,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: AppColors.neutral500,
            ),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              color: AppColors.neutral900,
            ),
            items: [
              for (final option in options)
                DropdownMenuItem(
                  value: option,
                  child: Text(labelOf(option), overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ),
    );
  }
}

/// `.input` (number) — digits only, focus border `--primary`.
class SheetNumberField extends StatelessWidget {
  const SheetNumberField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  static OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: BorderSide(color: color),
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13.5,
          color: AppColors.neutral900,
        ),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          enabledBorder: _border(AppColors.neutral200),
          focusedBorder: _border(AppColors.primary),
        ),
      ),
    );
  }
}

/// `.batch-preview` — "Sẽ tạo N slot · T3, T5 · 4 tuần · HH:MM–HH:MM" + up to
/// 3 "weekday · tuần k" chips per selected weekday, then a "+X nữa" overflow.
class BatchPreview extends StatelessWidget {
  const BatchPreview({
    super.key,
    required this.sessions,
    required this.days,
    required this.weeks,
    required this.start,
    required this.dur,
  });

  /// `repeat ? days.length * weeks : 1`.
  final int sessions;

  /// Selected weekday indices, 0=Mon..6=Sun.
  final List<int> days;
  final int weeks;
  final double start;
  final double dur;

  @override
  Widget build(BuildContext context) {
    final dayList =
        days.isEmpty ? '—' : days.map((i) => weekdayShortLabels[i]).join(', ');
    // Chips grouped per weekday like the jsx: min(weeks, 3) per day, then a
    // "+X nữa" overflow chip.
    final chips = <String>[
      for (final di in days)
        for (var w = 0; w < (weeks > 3 ? 3 : weeks); w++)
          '${weekdayShortLabels[di]} · tuần ${w + 1}',
    ];
    if (sessions > days.length * 3) {
      chips.add('+${sessions - days.length * 3} nữa');
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: 'Sẽ tạo ',
              children: [
                TextSpan(
                  text: '$sessions slot',
                  // <strong> renders in the display font (Sora).
                  style: GoogleFonts.sora(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                TextSpan(
                  text: ' · $dayList · $weeks tuần · '
                      '${hourLabel(start)}–${hourLabel(start + dur)}',
                ),
              ],
            ),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              color: AppColors.primaryDark,
              height: 1.5,
            ),
          ),
          if (chips.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final chip in chips)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.primaryLight),
                    ),
                    child: Text(
                      chip,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
