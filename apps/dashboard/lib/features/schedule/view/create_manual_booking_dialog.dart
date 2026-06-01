import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../../setup/model/owner_court.dart';
import '../booking_logic.dart';
import '../bloc/schedule_bloc.dart';
import '../model/manual_booking_result.dart';
import '../schedule_logic.dart';

/// Opens the "manual walk-in booking" dialog (OWNER-20/23). On confirm it
/// dispatches [ScheduleEvent.manualBookingCreated] to [bloc]; the bloc routes
/// the booking through the backend (`POST /api/bookings/manual`) and reloads
/// the week. [initialAt] pre-selects the tapped day/hour when opened from an
/// empty calendar cell.
///
/// The dialog stays open until the backend resolves (OWNER-23): on success it
/// pops returning a [ManualBookingSucceeded] (the caller then navigates the
/// schedule to the new entry); on a predictable rejection it stays open with an
/// inline error so the owner can fix + retry; "Huỷ"/close ask for confirmation
/// when the form has been touched. Resolves to `null` when dismissed without a
/// confirmed booking.
///
/// The dialog reads the active court + loaded slots live from [bloc] (so the
/// court dropdown and conflict guard stay in sync) — hence it re-provides the
/// same bloc instance to the dialog subtree.
Future<ManualBookingResult?> showCreateManualBookingDialog(
  BuildContext context, {
  required ScheduleBloc bloc,
  DateTime? initialAt,
}) {
  return showDialog<ManualBookingResult>(
    context: context,
    barrierDismissible: false,
    builder: (_) => BlocProvider<ScheduleBloc>.value(
      value: bloc,
      child: _CreateManualBookingDialog(initial: initialAt),
    ),
  );
}

const _kStep = 30; // minute granularity for the time pickers

class _CreateManualBookingDialog extends StatefulWidget {
  const _CreateManualBookingDialog({this.initial});
  final DateTime? initial;

  @override
  State<_CreateManualBookingDialog> createState() =>
      _CreateManualBookingDialogState();
}

class _CreateManualBookingDialogState
    extends State<_CreateManualBookingDialog> {
  late DateTime _date;
  late int _startMin; // minutes from midnight
  late int _endMin;

  // Pristine values captured at open, to detect whether the form is "dirty"
  // (any field touched) for the cancel-confirmation guard (OWNER-23).
  late final DateTime _initDate;
  late final int _initStartMin;
  late final int _initEndMin;

  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _notes = TextEditingController();
  bool _phoneTouched = false;

  /// True while the backend call is in flight — disables actions + shows a
  /// spinner on the confirm button (OWNER-23).
  bool _submitting = false;

  /// Localized server-rejection message to show inline; cleared on next edit.
  String? _serverError;

  @override
  void initState() {
    super.initState();
    final init = widget.initial;
    final now = DateTime.now();
    final base = init ?? now;
    _date = DateTime(base.year, base.month, base.day);
    final startHour = (init?.hour ?? 18).clamp(kOpenHour, kCloseHour - 1);
    _startMin = startHour * 60;
    _endMin = _startMin + 90;
    _initDate = _date;
    _initStartMin = _startMin;
    _initEndMin = _endMin;
    // Rebuild on phone edits (live validation) and dismiss any stale server
    // error once the owner starts fixing the input.
    _phone.addListener(() => setState(() => _serverError = null));
  }

  /// Whether the owner has entered or changed anything since the dialog opened.
  bool get _isDirty =>
      _name.text.trim().isNotEmpty ||
      _phone.text.trim().isNotEmpty ||
      _notes.text.trim().isNotEmpty ||
      !_isSameDay(_date, _initDate) ||
      _startMin != _initStartMin ||
      _endMin != _initEndMin;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _notes.dispose();
    super.dispose();
  }

  // ---- helpers --------------------------------------------------------------

  int _snap(int minutes) => (minutes ~/ _kStep) * _kStep;

  String _fmt(int minutes) => '${(minutes ~/ 60).toString().padLeft(2, '0')}:'
      '${(minutes % 60).toString().padLeft(2, '0')}';

  DateTime _at(int minutes) =>
      DateTime(_date.year, _date.month, _date.day, minutes ~/ 60, minutes % 60);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScheduleBloc, ScheduleState>(
      // Fire only when a fresh booking outcome lands (identity change to a
      // non-null result), so we react exactly once per attempt.
      listenWhen: (prev, curr) {
        final prevResult = prev is ScheduleLoaded ? prev.bookingResult : null;
        final currResult = curr is ScheduleLoaded ? curr.bookingResult : null;
        return currResult != null && !identical(prevResult, currResult);
      },
      listener: (context, state) {
        if (!context.mounted) return;
        final result = (state as ScheduleLoaded).bookingResult!;
        // Acknowledge so a re-opened dialog / later reload won't see it again.
        context.read<ScheduleBloc>().add(
              const ScheduleEvent.bookingResultCleared(),
            );
        switch (result) {
          case ManualBookingSucceeded():
            Navigator.of(context).pop(result); // caller navigates to the entry
          case ManualBookingFailed(:final message):
            setState(() {
              _submitting = false;
              _serverError = message;
            });
        }
      },
      builder: (context, state) {
        if (state is! ScheduleLoaded || state.courts.isEmpty) {
          return const SizedBox.shrink();
        }
        final court = state.courts.firstWhere(
          (c) => c.id == state.activeCourtId,
          orElse: () => state.courts.first,
        );

        // Bound the pickers to this court's operating hours.
        final openMin = court.openHour * 60;
        final closeMin = court.closeHour * 60;
        final start = _snap(_startMin).clamp(openMin, closeMin - _kStep);
        final end = _snap(_endMin).clamp(start + _kStep, closeMin);

        final startAt = _at(start);
        final endAt = _at(end);

        final conflict = hasConflict(state.slots, startAt, endAt);
        final crosses = crossesUtcDateBoundary(startAt, endAt);
        final phoneRaw = _phone.text.trim();
        final phoneValid =
            phoneRaw.isEmpty || normalizeVietnamPhone(phoneRaw) != null;
        final canSubmit = !conflict && !crosses && phoneValid;

        final days =
            List.generate(7, (i) => state.weekStart.add(Duration(days: i)));

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            // Ignore system back / Esc while a booking is in flight (mirrors the
            // disabled Huỷ/✕ buttons) so we never discard a pending request.
            if (!didPop && !_submitting) _attemptClose(context);
          },
          child: Dialog(
            backgroundColor: AppColors.surface,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Semantics(
                label: 'manual-booking-dialog',
                // Lock the form while a booking is in flight (the buttons are
                // already disabled) so mid-submit edits can't mislead the owner.
                child: AbsorbPointer(
                  absorbing: _submitting,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _header(context),
                        const SizedBox(height: 18),

                        // Court + sport (auto)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _Label('Sân'),
                                  const SizedBox(height: 6),
                                  _courtDropdown(context, state, court),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _Label('Môn'),
                                  const SizedBox(height: 6),
                                  _sportField(court),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Date
                        const _Label('Ngày'),
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
                                onTap: () => setState(() {
                                  _date = DateTime(
                                      days[i].year, days[i].month, days[i].day);
                                  _serverError = null;
                                }),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Start / end time + duration
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _timeDropdown(
                                label: 'Bắt đầu',
                                semantics: 'manual-booking-start',
                                value: start,
                                min: openMin,
                                max: closeMin - _kStep,
                                onChanged: (v) => setState(() {
                                  _startMin = v;
                                  if (_endMin <= v) _endMin = v + _kStep;
                                  _serverError = null;
                                }),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _timeDropdown(
                                label: 'Kết thúc',
                                semantics: 'manual-booking-end',
                                value: end,
                                min: start + _kStep,
                                max: closeMin,
                                onChanged: (v) => setState(() {
                                  _endMin = v;
                                  _serverError = null;
                                }),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _Label('Thời lượng'),
                                  const SizedBox(height: 6),
                                  Container(
                                    height: 44,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AppColors.neutral50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: AppColors.neutral200),
                                    ),
                                    child: Text(
                                      _durationLabel(end - start),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.neutral700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Customer
                        const _Label('Khách hàng (không bắt buộc)'),
                        const SizedBox(height: 6),
                        _textField(
                          controller: _name,
                          semantics: 'manual-booking-name',
                          hint: 'Tên khách',
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 10),
                        _textField(
                          controller: _phone,
                          semantics: 'manual-booking-phone',
                          hint: 'Số điện thoại (vd: 0901 234 567)',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          errorText: (_phoneTouched && !phoneValid)
                              ? 'Số điện thoại không hợp lệ.'
                              : null,
                          onChanged: (_) {
                            if (!_phoneTouched) {
                              setState(() => _phoneTouched = true);
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        _textField(
                          controller: _notes,
                          semantics: 'manual-booking-notes',
                          hint: 'Ghi chú',
                          icon: Icons.sticky_note_2_outlined,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 14),

                        _statusBanner(
                          court: court,
                          conflict: conflict,
                          crosses: crosses,
                          startAt: startAt,
                          endAt: endAt,
                        ),
                        if (_serverError != null) ...[
                          const SizedBox(height: 10),
                          Semantics(
                            label: 'manual-booking-server-error',
                            child: _Banner(
                              color: AppColors.danger,
                              bg: AppColors.dangerBg,
                              text: _serverError!,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),

                        _actions(context, canSubmit, startAt, endAt, phoneRaw),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ---- pieces ---------------------------------------------------------------

  Widget _header(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.successBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.storefront_rounded,
              size: 20, color: AppColors.success),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Đặt sân tại quầy',
                style: GoogleFonts.sora(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.neutral900,
                ),
              ),
              Text(
                'Ghi nhận một lượt đặt cho khách đến trực tiếp.',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5, color: AppColors.neutral500),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close_rounded, size: 20),
          color: AppColors.neutral500,
          onPressed: _submitting ? null : () => _attemptClose(context),
        ),
      ],
    );
  }

  Widget _courtDropdown(
      BuildContext context, ScheduleLoaded state, OwnerCourt court) {
    return Semantics(
      label: 'manual-booking-court-dropdown',
      child: InputDecorator(
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
        child: DropdownButton<String>(
          value: court.id,
          isExpanded: true,
          underline: const SizedBox.shrink(),
          style: GoogleFonts.plusJakartaSans(
              fontSize: 14, color: AppColors.neutral900),
          items: [
            for (final c in state.courts)
              DropdownMenuItem(value: c.id, child: Text(c.name)),
          ],
          onChanged: (id) {
            if (id == null || id == state.activeCourtId) return;
            // Switch the active court on the shared bloc — the BlocBuilder then
            // rebuilds with that court's slots, keeping the conflict guard honest.
            context.read<ScheduleBloc>().add(ScheduleEvent.courtSelected(id));
          },
        ),
      ),
    );
  }

  Widget _sportField(OwnerCourt court) {
    const sport = '—';
    return Container(
      height: 48,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Text(
        sport,
        style: GoogleFonts.plusJakartaSans(
            fontSize: 14, color: AppColors.neutral700),
      ),
    );
  }

  Widget _timeDropdown({
    required String label,
    required String semantics,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    final items = <int>[for (var m = min; m <= max; m += _kStep) m];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        const SizedBox(height: 6),
        Semantics(
          label: semantics,
          child: InputDecorator(
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: DropdownButton<int>(
              value: value,
              isExpanded: true,
              underline: const SizedBox.shrink(),
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 14, color: AppColors.neutral900),
              items: [
                for (final m in items)
                  DropdownMenuItem(value: m, child: Text(_fmt(m))),
              ],
              onChanged: (v) => onChanged(v ?? value),
            ),
          ),
        ),
      ],
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String semantics,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    return Semantics(
      label: semantics,
      textField: true,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: onChanged,
        style: GoogleFonts.plusJakartaSans(
            fontSize: 14, color: AppColors.neutral900),
        decoration: InputDecoration(
          isDense: true,
          hintText: hint,
          hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 13.5, color: AppColors.neutral400),
          prefixIcon: Icon(icon, size: 18, color: AppColors.neutral400),
          errorText: errorText,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.neutral200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.neutral200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _statusBanner({
    required OwnerCourt court,
    required bool conflict,
    required bool crosses,
    required DateTime startAt,
    required DateTime endAt,
  }) {
    if (conflict) {
      return _Banner(
        color: AppColors.danger,
        bg: AppColors.dangerBg,
        text: 'Trùng với một slot đã có trên ${court.name}. Hãy chọn giờ khác.',
      );
    }
    if (crosses) {
      return const _Banner(
        color: AppColors.danger,
        bg: AppColors.dangerBg,
        text: 'Khung giờ này chưa hỗ trợ do giới hạn múi giờ máy chủ. '
            'Vui lòng chọn giờ bắt đầu từ 07:00.',
      );
    }
    final dayIdx = startAt.weekday - DateTime.monday; // 0 == Mon … 6 == Sun
    return Row(
      children: [
        const Icon(Icons.check_circle_outline_rounded,
            size: 16, color: AppColors.success),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '${DateFormat('HH:mm').format(startAt)} – '
            '${DateFormat('HH:mm').format(endAt)} · '
            '${kDayLabels[dayIdx]} ${DateFormat('dd/MM').format(startAt)}',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13, color: AppColors.neutral700),
          ),
        ),
      ],
    );
  }

  Widget _actions(BuildContext context, bool canSubmit, DateTime startAt,
      DateTime endAt, String phoneRaw) {
    return Row(
      children: [
        Expanded(
          child: Semantics(
            label: 'manual-booking-cancel-btn',
            button: true,
            child: OutlinedButton(
              onPressed: _submitting ? null : () => _attemptClose(context),
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
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Semantics(
            label: 'manual-booking-submit-btn',
            button: true,
            child: FilledButton(
              onPressed: (canSubmit && !_submitting)
                  ? () => _submit(context, startAt, endAt, phoneRaw)
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    AppColors.success.withValues(alpha: 0.5),
                disabledForegroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600, fontSize: 14),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.4, color: Colors.white),
                    )
                  : const Text('Xác nhận đặt sân'),
            ),
          ),
        ),
      ],
    );
  }

  void _submit(
      BuildContext context, DateTime startAt, DateTime endAt, String phoneRaw) {
    final name = _name.text.trim();
    final phone = phoneRaw.isEmpty ? null : normalizeVietnamPhone(phoneRaw);
    final notes = _notes.text.trim();
    // Keep the dialog open; the bloc's booking outcome (success → pop+navigate,
    // rejection → inline error) is handled by the BlocConsumer listener above.
    setState(() {
      _submitting = true;
      _serverError = null;
    });
    context.read<ScheduleBloc>().add(
          ScheduleEvent.manualBookingCreated(
            startAt: startAt,
            endAt: endAt,
            customerName: name.isEmpty ? null : name,
            customerPhone: phone,
            notes: notes.isEmpty ? null : notes,
          ),
        );
  }

  /// Close the dialog, asking for confirmation first when the form is dirty
  /// (OWNER-23: "Huỷ discards the form, with a confirmation dialog if any field
  /// has been filled"). Routes "Huỷ", the header ✕, and a system back/Esc here.
  Future<void> _attemptClose(BuildContext context) async {
    final navigator = Navigator.of(context);
    if (!_isDirty) {
      navigator.pop();
      return;
    }
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Huỷ đặt sân?'),
        content: const Text(
            'Thông tin bạn đã nhập sẽ không được lưu. Bạn chắc chắn muốn huỷ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Tiếp tục nhập'),
          ),
          Semantics(
            label: 'manual-booking-discard-confirm-btn',
            button: true,
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Huỷ bỏ'),
            ),
          ),
        ],
      ),
    );
    if (discard == true) navigator.pop();
  }

  static String _durationLabel(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '$m phút';
    if (m == 0) return '$h giờ';
    return '${h}h$m';
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
      label: 'manual-booking-date-$index',
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 52,
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
