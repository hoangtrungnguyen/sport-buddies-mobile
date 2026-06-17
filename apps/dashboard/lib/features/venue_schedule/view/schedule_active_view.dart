import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spb_core/core/theme/app_colors.dart';

import '../bloc/venue_schedule_bloc.dart';
import '../model/models.dart';
import 'day_view.dart';
import 'month_view.dart';
import 'week_view.dart';

/// The grid area of the schedule page: resolves the load [VenueScheduleStatus]
/// into a status card (failure + retry / loading / zero-courts empty) or the
/// active Day / Week / Month view, wiring each view's interactions to [bloc].
class ScheduleActiveView extends StatelessWidget {
  const ScheduleActiveView({
    super.key,
    required this.bloc,
    required this.state,
  });

  final VenueScheduleBloc bloc;
  final VenueScheduleState state;

  @override
  Widget build(BuildContext context) {
    if (state.status == VenueScheduleStatus.failure) {
      return _StatusCard(
        message: 'Không tải được dữ liệu lịch sân.',
        onRetry: () => bloc.add(const VenueScheduleEvent.started()),
      );
    }
    if (state.status == VenueScheduleStatus.loading && state.venues.isEmpty) {
      return const _StatusCard.loading();
    }
    // Loaded fine but the owner has no active courts — explain the blank
    // grid instead of rendering a bare time gutter with no columns.
    if (state.venues.isEmpty) {
      return const _StatusCard(
        message: 'Chưa có sân nào — thêm sân trong mục "Sân của tôi" '
            'để bắt đầu xếp lịch.',
      );
    }
    switch (state.view) {
      case ScheduleView.day:
        return const VenueScheduleDayView();
      case ScheduleView.week:
        return WeekView(
          venue: state.selectedVenue,
          slots: state.visibleWeekSlots,
          weekStart: state.weekStart,
          onSlotTapped: (slot) => bloc.add(VenueScheduleEvent.slotTapped(slot)),
          onEmptyCellTapped: (venueId, startHour, weekday) => bloc.add(
            VenueScheduleEvent.emptyCellTapped(
              venueId,
              startHour,
              weekday: weekday,
            ),
          ),
          onDragBlockRequested: (venueId, startHour, endHour, weekday) =>
              bloc.add(
            VenueScheduleEvent.dragBlockRequested(
              venueId,
              startHour,
              endHour,
              weekday: weekday,
            ),
          ),
        );
      case ScheduleView.month:
        return ScheduleMonthView(
          cells: state.monthCells,
          onDayTapped: (date) =>
              bloc.add(VenueScheduleEvent.monthDayTapped(date)),
        );
    }
  }
}

/// Placeholder card occupying the grid area while the first load is in
/// flight, after a failure (with a retry button), or for the zero-courts
/// empty state (message only).
class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.message, this.onRetry}) : loading = false;

  const _StatusCard.loading()
      : loading = true,
        message = null,
        onRetry = null;

  final bool loading;
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.neutral200),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: loading
            ? const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.primary,
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      color: AppColors.neutral500,
                    ),
                  ),
                  if (onRetry != null) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: onRetry,
                      child: Text(
                        'Thử lại',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
