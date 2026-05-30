part of 'slot_detail_cubit.dart';

sealed class SlotDetailState {
  const SlotDetailState();
}

final class SlotDetailInitial extends SlotDetailState {
  const SlotDetailInitial();
}

final class SlotDetailLoading extends SlotDetailState {
  const SlotDetailLoading();
}

final class SlotDetailLoaded extends SlotDetailState {
  const SlotDetailLoaded(this.slot);

  final Slot slot;
}

final class SlotDetailError extends SlotDetailState with AppExceptionMixin {
  const SlotDetailError(this.message, {this.stackTrace});

  @override
  final String message;
  @override
  final StackTrace? stackTrace;
}
