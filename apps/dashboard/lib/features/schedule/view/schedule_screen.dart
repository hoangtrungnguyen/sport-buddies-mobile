import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:spb_core/core/theme/app_colors.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../setup/model/owner_court.dart';
import '../booking_logic.dart';
import '../bloc/schedule_bloc.dart';
import '../model/manual_booking_result.dart';
import '../model/owner_slot.dart';
import '../schedule_logic.dart';
import 'create_manual_booking_dialog.dart';
import 'create_owner_slot_dialog.dart';
import 'slot_actions_dialog.dart';

// ---------------------------------------------------------------------------
// Slot visual tokens — lifted verbatim from the design (styles.css `.slot.*`).
// ---------------------------------------------------------------------------

class _SlotStyle {
  const _SlotStyle(this.bg, this.border, this.text, this.label);
  final Color bg;
  final Color border;
  final Color text;
  final String label;
}

_SlotStyle _styleFor(String status) => switch (status) {
      SlotStatus.owner => const _SlotStyle(Color(0xFFDBEAFE), Color(0xFF3B82F6),
          Color(0xFF1E3A8A), 'Sân của tôi'),
      SlotStatus.booked => const _SlotStyle(
          Color(0xFFDCFCE7), Color(0xFF22C55E), Color(0xFF14532D), 'Đã đặt'),
      SlotStatus.pending => const _SlotStyle(
          Color(0xFFFEF9C3), Color(0xFFEAB308), Color(0xFF713F12), 'Chờ duyệt'),
      SlotStatus.maintenance => const _SlotStyle(
          Color(0xFFFEF3C7), Color(0xFFFBBF24), Color(0xFF92400E), 'Bảo trì'),
      SlotStatus.blocked => const _SlotStyle(AppColors.neutral100,
          AppColors.neutral300, AppColors.neutral600, 'Đã khoá'),
      _ => const _SlotStyle(AppColors.surface, AppColors.neutral200,
          AppColors.neutral500, 'Còn trống'),
    };

// ---------------------------------------------------------------------------

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final _calendar = CalendarController();

  @override
  void dispose() {
    _calendar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScheduleBloc, ScheduleState>(
      listener: (context, state) {
        if (state is ScheduleFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) => switch (state) {
        ScheduleInitial() || ScheduleLoading() => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        ScheduleFailure(:final message) => _FailureView(message: message),
        ScheduleLoaded() when state.courts.isEmpty => const _NoCourtsView(),
        ScheduleLoaded() => _Loaded(state: state, calendar: _calendar),
      },
    );
  }
}

// ---------------------------------------------------------------------------

class _Loaded extends StatelessWidget {
  const _Loaded({required this.state, required this.calendar});
  final ScheduleLoaded state;
  final CalendarController calendar;

  OwnerCourt get _activeCourt =>
      state.courts.firstWhere((c) => c.id == state.activeCourtId,
          orElse: () => state.courts.first);

  Future<void> _openCreate(BuildContext context, {DateTime? at}) async {
    await showCreateOwnerSlotDialog(
      context,
      bloc: context.read<ScheduleBloc>(),
      court: _activeCourt,
      weekStart: state.weekStart,
      existing: state.slots,
      initial: at,
    );
  }

  /// Tapping an existing slot opens the block / unblock sheet (OWNER-25).
  void _openSlotActions(BuildContext context, OwnerSlot slot) {
    showSlotActionsDialog(
      context,
      bloc: context.read<ScheduleBloc>(),
      slot: slot,
    );
  }

  Future<void> _openManualBooking(BuildContext context, {DateTime? at}) async {
    final result = await showCreateManualBookingDialog(
      context,
      bloc: context.read<ScheduleBloc>(),
      initialAt: at,
    );
    if (result is! ManualBookingSucceeded || !context.mounted) return;
    // OWNER-23: on confirm, navigate the schedule to the new entry ("today's
    // list") — it now shows as a green "Đã đặt" (confirmed) slot — and surface
    // a success confirmation.
    calendar.displayDate = result.startAt.toLocal();
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(confirmedBookingMessage(
          startAtLocal: result.startAt.toLocal(),
          endAtLocal: result.endAt.toLocal(),
          customerName: result.customerName,
        )),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 26, 28, 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(
                onCreate: () => _openCreate(context),
                onManualBooking: () => _openManualBooking(context),
              ),
              const SizedBox(height: 22),
              _CourtTabs(
                courts: state.courts,
                activeCourtId: state.activeCourtId,
              ),
              const SizedBox(height: 14),
              _WeekNav(
                weekStart: state.weekStart,
                slotCount: state.slots.length,
                calendar: calendar,
              ),
              const SizedBox(height: 14),
              _CalendarCard(
                slots: state.slots,
                calendar: calendar,
                onTapEmpty: (at) => _openCreate(context, at: at),
                onTapSlot: (slot) => _openSlotActions(context, slot),
              ),
            ],
          ),
        ),
        if (state.busy)
          const Positioned(
            top: 30,
            right: 36,
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                  strokeWidth: 2.5, color: AppColors.primary),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header({required this.onCreate, required this.onManualBooking});
  final VoidCallback onCreate;
  final VoidCallback onManualBooking;

  void _soon(BuildContext context, String what) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$what sẽ có trong epic Đặt Slot.'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lịch sân tuần này',
                style: GoogleFonts.sora(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: AppColors.neutral900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Quản lý slot, khoá giờ và đặt sân cho riêng bạn theo từng sân.',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5, color: AppColors.neutral500),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _SecondaryAction(
              icon: Icons.refresh_rounded,
              label: 'Lịch cố định',
              onTap: () => _soon(context, 'Lịch cố định'),
            ),
            _SecondaryAction(
              icon: Icons.lock_outline_rounded,
              label: 'Khoá nhiều giờ',
              onTap: () => _soon(context, 'Khoá nhiều giờ'),
            ),
            Semantics(
              label: 'schedule-manual-booking-btn',
              button: true,
              child: FilledButton.icon(
                icon: const Icon(Icons.storefront_rounded, size: 18),
                label: const Text('Đặt tại quầy'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  textStyle: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
                onPressed: onManualBooking,
              ),
            ),
            Semantics(
              label: 'schedule-create-slot-btn',
              button: true,
              child: FilledButton.icon(
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Tạo slot mới'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  textStyle: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
                onPressed: onCreate,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SecondaryAction extends StatelessWidget {
  const _SecondaryAction(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.neutral700,
        side: const BorderSide(color: AppColors.neutral200),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600, fontSize: 13.5),
      ),
      onPressed: onTap,
    );
  }
}

// ---------------------------------------------------------------------------

class _CourtTabs extends StatelessWidget {
  const _CourtTabs({required this.courts, required this.activeCourtId});
  final List<OwnerCourt> courts;
  final String activeCourtId;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...courts.map((c) {
          final active = c.id == activeCourtId;
          return Semantics(
            label: 'schedule-court-tab-${c.id}',
            button: true,
            selected: active,
            child: GestureDetector(
              onTap: () => context
                  .read<ScheduleBloc>()
                  .add(ScheduleEvent.courtSelected(c.id)),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? AppColors.neutral900 : AppColors.surface,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(
                      color:
                          active ? AppColors.neutral900 : AppColors.neutral200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            active ? AppColors.primaryMid : AppColors.primary,
                      ),
                    ),
                    Text(
                      c.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: active ? Colors.white : AppColors.neutral700,
                      ),
                    ),
                    if (c.primarySport.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(
                        '· ${c.primarySport}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: active
                              ? Colors.white.withValues(alpha: 0.7)
                              : AppColors.neutral500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
        // "+ Thêm sân" — routes to court Setup.
        Semantics(
          label: 'schedule-add-court-tab',
          button: true,
          child: GestureDetector(
            onTap: () => context.go('/settings'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                    color: AppColors.neutral300, style: BorderStyle.solid),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded,
                      size: 14, color: AppColors.neutral500),
                  const SizedBox(width: 6),
                  Text(
                    'Thêm sân',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neutral500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _WeekNav extends StatelessWidget {
  const _WeekNav({
    required this.weekStart,
    required this.slotCount,
    required this.calendar,
  });
  final DateTime weekStart;
  final int slotCount;
  final CalendarController calendar;

  @override
  Widget build(BuildContext context) {
    final end = weekStart.add(const Duration(days: 6));
    final label =
        '${DateFormat('dd/MM').format(weekStart)} – ${DateFormat('dd/MM/yyyy').format(end)}';
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.neutral200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _NavArrow(
                icon: Icons.chevron_left_rounded,
                semantics: 'schedule-prev-week-btn',
                onTap: () => calendar.backward!(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neutral900,
                  ),
                ),
              ),
              _NavArrow(
                icon: Icons.chevron_right_rounded,
                semantics: 'schedule-next-week-btn',
                onTap: () => calendar.forward!(),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        OutlinedButton(
          onPressed: () => calendar.displayDate = DateTime.now(),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.neutral700,
            side: const BorderSide(color: AppColors.neutral200),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            textStyle: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600, fontSize: 12.5),
          ),
          child: const Text('Hôm nay'),
        ),
        const Spacer(),
        Text(
          '$slotCount slot trong tuần',
          style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5, color: AppColors.neutral600),
        ),
      ],
    );
  }
}

class _NavArrow extends StatelessWidget {
  const _NavArrow(
      {required this.icon, required this.onTap, required this.semantics});
  final IconData icon;
  final VoidCallback onTap;
  final String semantics;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semantics,
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Icon(icon, size: 18, color: AppColors.neutral600),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.slots,
    required this.calendar,
    required this.onTapEmpty,
    required this.onTapSlot,
  });
  final List<OwnerSlot> slots;
  final CalendarController calendar;
  final ValueChanged<DateTime> onTapEmpty;
  final ValueChanged<OwnerSlot> onTapSlot;

  @override
  Widget build(BuildContext context) {
    final appointments = slots
        .map((s) => Appointment(
              id: s.id,
              startTime: s.startAt.toLocal(),
              endTime: s.endAt.toLocal(),
              subject: _styleFor(s.status).label,
              notes: s.status,
              color: _styleFor(s.status).border,
            ))
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.neutral200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            height: 17 * 56.0 + 60, // 17 hour rows @56px + view header
            child: SfCalendar(
              controller: calendar,
              view: CalendarView.week,
              firstDayOfWeek: 1, // Monday
              headerHeight: 0,
              viewHeaderHeight: 60,
              showNavigationArrow: false,
              showDatePickerButton: false,
              cellBorderColor: AppColors.neutral100,
              todayHighlightColor: AppColors.primary,
              selectionDecoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 1.5),
                borderRadius: BorderRadius.circular(6),
                color: Colors.transparent,
              ),
              timeSlotViewSettings: TimeSlotViewSettings(
                startHour: kOpenHour.toDouble(),
                endHour: kCloseHour.toDouble(),
                timeIntervalHeight: 56,
                timeFormat: 'HH:00',
                timeTextStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: AppColors.neutral400,
                ),
              ),
              viewHeaderStyle: ViewHeaderStyle(
                dayTextStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral500,
                ),
                dateTextStyle: GoogleFonts.sora(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral900,
                ),
              ),
              dataSource: _SlotDataSource(appointments),
              appointmentBuilder: _buildAppointment,
              onViewChanged: (details) {
                final dates = details.visibleDates;
                if (dates.isEmpty) return;
                // Monday of the visible week drives the fetch window + label.
                final monday = mondayOf(dates[dates.length ~/ 2]);
                context
                    .read<ScheduleBloc>()
                    .add(ScheduleEvent.weekChanged(monday));
              },
              onTap: (details) {
                final appts = details.appointments;
                if (appts != null && appts.isNotEmpty) {
                  // Tapped an existing slot → block / unblock sheet (OWNER-25).
                  final id = (appts.first as Appointment).id;
                  for (final s in slots) {
                    if (s.id == id) {
                      onTapSlot(s);
                      return;
                    }
                  }
                } else if (details.targetElement ==
                        CalendarElement.calendarCell &&
                    details.date != null) {
                  onTapEmpty(details.date!);
                }
              },
            ),
          ),
          const _Legend(),
        ],
      ),
    );
  }

  Widget _buildAppointment(
      BuildContext context, CalendarAppointmentDetails details) {
    final appt = details.appointments.first as Appointment;
    final style = _styleFor(appt.notes ?? SlotStatus.open);
    final isOwner = appt.notes == SlotStatus.owner;
    final isBlocked = appt.notes == SlotStatus.blocked;
    // Blocked slots show their reason (OWNER-25), looked up by appointment id.
    String? blockedReason;
    if (isBlocked) {
      for (final s in slots) {
        if (s.id == appt.id) {
          blockedReason = s.blockedReason?.trim();
          break;
        }
      }
    }
    return Container(
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: style.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (isOwner)
                Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child:
                      Icon(Icons.person_rounded, size: 11, color: style.text),
                )
              else if (isBlocked)
                Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: Icon(Icons.lock_rounded, size: 11, color: style.text),
                ),
              Flexible(
                child: Text(
                  appt.subject,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: style.text,
                  ),
                ),
              ),
            ],
          ),
          Text(
            '${DateFormat('HH:mm').format(appt.startTime)} – ${DateFormat('HH:mm').format(appt.endTime)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              color: style.text.withValues(alpha: 0.8),
            ),
          ),
          if (blockedReason != null && blockedReason.isNotEmpty)
            Text(
              blockedReason,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 9.5,
                fontStyle: FontStyle.italic,
                color: style.text.withValues(alpha: 0.75),
              ),
            ),
        ],
      ),
    );
  }
}

class _SlotDataSource extends CalendarDataSource {
  _SlotDataSource(List<Appointment> source) {
    appointments = source;
  }
}

// ---------------------------------------------------------------------------

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    const items = [
      SlotStatus.booked,
      SlotStatus.pending,
      SlotStatus.owner,
      SlotStatus.maintenance,
      SlotStatus.blocked,
      SlotStatus.open,
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.neutral50,
        border: Border(top: BorderSide(color: AppColors.neutral100)),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: items.map((s) {
          final style = _styleFor(s);
          final legendLabel = s == SlotStatus.owner ? 'Sân chủ' : style.label;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: style.bg,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: style.border),
                ),
              ),
              Text(
                legendLabel,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12, color: AppColors.neutral600),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _NoCourtsView extends StatelessWidget {
  const _NoCourtsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.calendar_month_outlined,
                size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Text(
            'Chưa có sân nào',
            style: GoogleFonts.sora(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tạo sân trong mục "Cài đặt sân" trước khi lên lịch slot.',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 14, color: AppColors.neutral500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FailureView extends StatelessWidget {
  const _FailureView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 40, color: AppColors.danger),
          const SizedBox(height: 12),
          Text(message,
              style: GoogleFonts.plusJakartaSans(
                  color: AppColors.neutral600, fontSize: 14)),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () =>
                context.read<ScheduleBloc>().add(const ScheduleEvent.started()),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}
