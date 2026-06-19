import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:spb_core/core/theme/app_colors.dart';

class SlotDetailHeader extends StatelessWidget {
  const SlotDetailHeader({super.key, 
    required this.courtName,
    required this.startLocal,
    required this.endLocal,
    required this.onClose,
    required this.onViewSchedule,
    this.sportType,
    this.notes,
  });
  final String courtName;
  final DateTime startLocal;
  final DateTime endLocal;
  final String? sportType;
  final String? notes;
  final VoidCallback onClose;
  final VoidCallback onViewSchedule;

  @override
  Widget build(BuildContext context) {
    final f = DateFormat('HH:mm');
    final fd = DateFormat('dd/MM/yyyy');
    final durationMin = endLocal.difference(startLocal).inMinutes;
    final durationLabel = durationMin >= 60
        ? '${durationMin ~/ 60}h${durationMin % 60 == 0 ? '' : '${durationMin % 60}p'}'
        : '${durationMin}p';
    final note = notes?.trim();
    return Semantics(
      label: 'slot-detail-header',
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _titleRow(),
          const SizedBox(height: 12),
          _chips(f, fd, durationLabel),
          if (note != null && note.isNotEmpty) ...[
            const SizedBox(height: 10),
            _notes(note),
          ],
          const SizedBox(height: 10),
          _viewScheduleLink(),
        ],
      ),
    );
  }

  /// Event icon tile + court name / sport, with the close button.
  Widget _titleRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.event_rounded,
              size: 22, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                courtName,
                style: GoogleFonts.sora(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.neutral900,
                  letterSpacing: -0.3,
                ),
              ),
              if (sportType != null && sportType!.isNotEmpty)
                Text(
                  sportType!,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5, color: AppColors.neutral500),
                ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close_rounded, size: 20),
          color: AppColors.neutral500,
          onPressed: onClose,
        ),
      ],
    );
  }

  /// Date + time-range + duration chips.
  Widget _chips(DateFormat f, DateFormat fd, String durationLabel) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: [
        _InfoChip(
            icon: Icons.calendar_today_rounded, label: fd.format(startLocal)),
        _InfoChip(
            icon: Icons.schedule_rounded,
            label: '${f.format(startLocal)} – ${f.format(endLocal)}'),
        _InfoChip(icon: Icons.timelapse_rounded, label: durationLabel),
      ],
    );
  }

  /// Notes block (AC#2) — shown when non-empty.
  Widget _notes(String note) {
    return Semantics(
      label: 'slot-detail-notes',
      container: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.neutral50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.neutral200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.notes_rounded,
                size: 15, color: AppColors.neutral400),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                note,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppColors.neutral700,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// "Xem lịch sân" back-link (AC#3) — closes all dialogs to the calendar.
  Widget _viewScheduleLink() {
    return Semantics(
      label: 'slot-detail-view-schedule-btn',
      button: true,
      child: TextButton.icon(
        icon: const Icon(Icons.calendar_view_week_rounded, size: 15),
        label: const Text('Xem lịch sân'),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        onPressed: onViewSchedule,
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.neutral100,
      borderRadius: BorderRadius.circular(99),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.neutral500),
        const SizedBox(width: 5),
        Text(label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12, color: AppColors.neutral700,
                fontWeight: FontWeight.w600)),
      ],
    ),
  );
}
