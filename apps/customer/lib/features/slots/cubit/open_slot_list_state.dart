part of 'open_slot_list_cubit.dart';

sealed class SlotListState {
  const SlotListState();
}

final class SlotListInitial extends SlotListState {
  const SlotListInitial();
}

final class SlotListLoading extends SlotListState {
  const SlotListLoading();
}

final class SlotListLoaded extends SlotListState {
  const SlotListLoaded(this.slots);

  final List<Slot> slots;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SlotListLoaded &&
          _listEquals(other.slots, slots));

  @override
  int get hashCode => Object.hashAll(slots);
}

final class SlotListError extends SlotListState with AppExceptionMixin {
  const SlotListError(this.message, {this.stackTrace});

  @override
  final String message;
  @override
  final StackTrace? stackTrace;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SlotListError && other.message == message);

  @override
  int get hashCode => message.hashCode;
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
