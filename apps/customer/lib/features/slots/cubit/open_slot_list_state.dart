part of 'open_slot_list_cubit.dart';

sealed class OpenSlotListState {
  const OpenSlotListState();
}

final class OpenSlotListInitial extends OpenSlotListState {
  const OpenSlotListInitial();
}

final class OpenSlotListLoading extends OpenSlotListState {
  const OpenSlotListLoading();
}

final class OpenSlotListLoaded extends OpenSlotListState {
  const OpenSlotListLoaded(this.slots);

  final List<OpenSlot> slots;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OpenSlotListLoaded &&
          _listEquals(other.slots, slots));

  @override
  int get hashCode => Object.hashAll(slots);
}

final class OpenSlotListError extends OpenSlotListState {
  const OpenSlotListError(this.message);

  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OpenSlotListError && other.message == message);

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
