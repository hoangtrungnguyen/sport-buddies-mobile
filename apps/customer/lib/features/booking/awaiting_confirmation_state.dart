part of 'awaiting_confirmation_cubit.dart';

sealed class AwaitingState {
  const AwaitingState();
}

final class AwaitingInitial extends AwaitingState {
  const AwaitingInitial();
}

final class AwaitingLoading extends AwaitingState {
  const AwaitingLoading();
}

final class AwaitingLoaded extends AwaitingState {
  const AwaitingLoaded({
    required this.bookingId,
    required this.courtName,
    required this.slotStart,
    required this.slotEnd,
    this.status = 'pending',
  });

  final String bookingId;
  final String courtName;
  final DateTime slotStart;
  final DateTime slotEnd;
  final String status;
}

final class AwaitingConfirmed extends AwaitingState {
  const AwaitingConfirmed({required this.bookingId});

  final String bookingId;
}

final class AwaitingError extends AwaitingState with AppExceptionMixin {
  const AwaitingError(this.message, {this.stackTrace});

  @override
  final String message;
  @override
  final StackTrace? stackTrace;
}
