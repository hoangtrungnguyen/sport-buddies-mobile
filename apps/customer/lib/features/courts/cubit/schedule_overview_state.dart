part of 'schedule_overview_cubit.dart';

sealed class ScheduleOverviewState {
  const ScheduleOverviewState();
}

final class ScheduleOverviewInitial extends ScheduleOverviewState {
  const ScheduleOverviewInitial();
}

final class ScheduleOverviewLoading extends ScheduleOverviewState {
  const ScheduleOverviewLoading();
}

final class ScheduleOverviewLoaded extends ScheduleOverviewState {
  const ScheduleOverviewLoaded({
    required this.courts,
    required this.slotsByCourtId,
    required this.selectedDate,
  });

  final List<Court> courts;
  final Map<String, List<Slot>> slotsByCourtId;
  final DateTime selectedDate;

  ScheduleOverviewLoaded copyWith({
    List<Court>? courts,
    Map<String, List<Slot>>? slotsByCourtId,
    DateTime? selectedDate,
  }) {
    return ScheduleOverviewLoaded(
      courts: courts ?? this.courts,
      slotsByCourtId: slotsByCourtId ?? this.slotsByCourtId,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

final class ScheduleOverviewError extends ScheduleOverviewState
    with AppExceptionMixin {
  const ScheduleOverviewError(this.message, {this.stackTrace});

  @override
  final String message;
  @override
  final StackTrace? stackTrace;
}
