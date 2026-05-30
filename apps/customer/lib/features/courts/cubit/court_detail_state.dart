part of 'court_detail_cubit.dart';

sealed class CourtDetailState {
  const CourtDetailState();
}

final class CourtDetailInitial extends CourtDetailState {
  const CourtDetailInitial();
}

final class CourtDetailLoading extends CourtDetailState {
  const CourtDetailLoading();
}

final class CourtDetailLoaded extends CourtDetailState {
  const CourtDetailLoaded(this.court, {this.openSlotCount = 0});

  final Court court;
  final int openSlotCount;
}

final class CourtDetailError extends CourtDetailState with AppExceptionMixin {
  const CourtDetailError(this.message, {this.stackTrace});

  @override
  final String message;
  @override
  final StackTrace? stackTrace;
}
