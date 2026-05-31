part of 'slot_picker_cubit.dart';

sealed class SlotPickerState {
  const SlotPickerState();
}

class SlotPickerLoading extends SlotPickerState {
  const SlotPickerLoading();
}

class SlotPickerLoaded extends SlotPickerState {
  const SlotPickerLoaded({required this.slots, this.pricePerHour});

  final List<Slot> slots;
  final double? pricePerHour;
}

class SlotPickerError extends SlotPickerState {
  const SlotPickerError(this.message);

  final String message;
}
