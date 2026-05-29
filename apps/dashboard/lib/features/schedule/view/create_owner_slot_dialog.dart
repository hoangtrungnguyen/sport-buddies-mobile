import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../../setup/model/owner_court.dart';
import '../bloc/schedule_bloc.dart';
import '../model/owner_slot.dart';
import '../schedule_logic.dart';

/// Opens the "create an owner slot" dialog (OWNER-19). On confirm it dispatches
/// [ScheduleEvent.ownerSlotCreated] to [bloc]; the bloc persists the slot with
/// `status = 'owner'` and reloads the week.
Future<void> showCreateOwnerSlotDialog(
  BuildContext context, {
  required ScheduleBloc bloc,
  required OwnerCourt court,
  required DateTime weekStart,
  required List<OwnerSlot> existing,
  DateTime? initial,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _CreateOwnerSlotDialog(
      bloc: bloc,
      court: court,
      weekStart: weekStart,
      existing: existing,
      initial: initial,
    ),
  );
}

const _kDurations = <int>[60, 90, 120, 180];

class _CreateOwnerSlotDialog extends StatefulWidget {
  const _CreateOwnerSlotDialog({
    required this.bloc,
    required this.court,
    required this.weekStart,
    required this.existing,
    this.initial,
  });

  final ScheduleBloc bloc;
  final OwnerCourt court;
  final DateTime weekStart;
  final List<OwnerSlot> existing;
  final DateTime? initial;

  @override
  State<_CreateOwnerSlotDialog> createState() => _CreateOwnerSlotDialogState();
}

class _CreateOwnerSlotDialogState extends State<_CreateOwnerSlotDialog> {
  late DateTime _date;
  late int _hour;
  int _duration = 90;

  @override
  void initState() {
    super.initState();
    final init = widget.initial;
    if (init != null && dayIndexInWeek(widget.weekStart, init) != null) {
      _date = DateTime(init.year, init.month, init.day);
    } else {
      final today = DateTime.now();
      _date = dayIndexInWeek(widget.weekStart, today) != null
          ? DateTime(today.year, today.month, today.day)
          : widget.weekStart;
    }
    _hour = (init?.hour ?? 18).clamp(kOpenHour, kCloseHour - 1);
  }

  DateTime get _startAt => DateTime(_date.year, _date.month, _date.day, _hour);
  DateTime get _endAt => _startAt.add(Duration(minutes: _duration));

  /// End must not run past closing time (22:00).
  bool get _withinHours =>
      _endAt.hour < kCloseHour ||
      (_endAt.hour == kCloseHour && _endAt.minute == 0);

  bool get _conflict => hasConflict(widget.existing, _startAt, _endAt);
  bool get _canSubmit => _withinHours && !_conflict;

  void _submit() {
    if (!_canSubmit) return;
    widget.bloc.add(
      ScheduleEvent.ownerSlotCreated(startAt: _startAt, endAt: _endAt),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final days =
        List.generate(7, (i) => widget.weekStart.add(Duration(days: i)));

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Semantics(
          label: 'create-slot-dialog',
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.person_rounded,
                          size: 20, color: Color(0xFF3B82F6)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tạo slot của tôi',
                            style: GoogleFonts.sora(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.neutral900,
                            ),
                          ),
                          Text(
                            widget.court.name,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 13, color: AppColors.neutral500),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: AppColors.neutral500,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Date chips
                _Label('Ngày'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < days.length; i++)
                      _DateChip(
                        label: kDayLabels[i],
                        date: DateFormat('dd/MM').format(days[i]),
                        selected: _isSameDay(days[i], _date),
                        index: i,
                        onTap: () => setState(() => _date =
                            DateTime(days[i].year, days[i].month, days[i].day)),
                      ),
                  ],
                ),
                const SizedBox(height: 18),

                // Start hour + duration
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label('Giờ bắt đầu'),
                          const SizedBox(height: 6),
                          Semantics(
                            label: 'create-slot-hour-dropdown',
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                              ),
                              child: DropdownButton<int>(
                                value: _hour,
                                isExpanded: true,
                                underline: const SizedBox.shrink(),
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14, color: AppColors.neutral900),
                                items: [
                                  for (var h = kOpenHour; h < kCloseHour; h++)
                                    DropdownMenuItem(
                                      value: h,
                                      child: Text(
                                          '${h.toString().padLeft(2, '0')}:00'),
                                    ),
                                ],
                                onChanged: (v) =>
                                    setState(() => _hour = v ?? _hour),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label('Thời lượng'),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            children: _kDurations
                                .map((d) => _DurationChip(
                                      minutes: d,
                                      selected: _duration == d,
                                      onTap: () =>
                                          setState(() => _duration = d),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Owner-slot info (no payment, not customer-bookable)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 16, color: Color(0xFF3B82F6)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Slot dành riêng cho bạn — khách không đặt được và '
                          'không phát sinh thanh toán.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            height: 1.45,
                            color: const Color(0xFF1E40AF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Summary / validation
                if (!_withinHours)
                  _Banner(
                    color: AppColors.danger,
                    bg: AppColors.dangerBg,
                    text:
                        'Slot vượt quá giờ đóng cửa (${kCloseHour.toString().padLeft(2, '0')}:00). '
                        'Hãy chọn giờ hoặc thời lượng ngắn hơn.',
                  )
                else if (_conflict)
                  _Banner(
                    color: AppColors.danger,
                    bg: AppColors.dangerBg,
                    text:
                        'Trùng với một slot đã có trên ${widget.court.name}. Hãy chọn giờ khác.',
                  )
                else
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded,
                          size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${DateFormat('HH:mm').format(_startAt)} – ${DateFormat('HH:mm').format(_endAt)} · '
                          '${kDayLabels[dayIndexInWeek(widget.weekStart, _date) ?? 0]} '
                          '${DateFormat('dd/MM').format(_date)}',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 13, color: AppColors.neutral700),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 22),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.neutral700,
                          side: const BorderSide(color: AppColors.neutral200),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Huỷ'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Semantics(
                        label: 'create-slot-submit-btn',
                        button: true,
                        child: FilledButton(
                          onPressed: _canSubmit ? _submit : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          child: const Text('Tạo slot'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ---------------------------------------------------------------------------

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.neutral700,
        ),
      );
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.label,
    required this.date,
    required this.selected,
    required this.index,
    required this.onTap,
  });
  final String label;
  final String date;
  final bool selected;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'create-slot-date-$index',
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 56,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.neutral900 : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: selected ? AppColors.neutral900 : AppColors.neutral200),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? Colors.white.withValues(alpha: 0.7)
                      : AppColors.neutral500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                date,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.neutral900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DurationChip extends StatelessWidget {
  const _DurationChip({
    required this.minutes,
    required this.selected,
    required this.onTap,
  });
  final int minutes;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'create-slot-duration-$minutes',
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryLight : AppColors.neutral100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: selected ? AppColors.primary : AppColors.neutral200),
          ),
          child: Text(
            '$minutes phút',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? AppColors.primaryDark : AppColors.neutral700,
            ),
          ),
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.color, required this.bg, required this.text});
  final Color color;
  final Color bg;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5, color: AppColors.dangerDark),
            ),
          ),
        ],
      ),
    );
  }
}
