part of 'slot_picker_cubit.dart';

sealed class SlotPickerState {
  const SlotPickerState();
}

class SlotPickerLoading extends SlotPickerState {
  const SlotPickerLoading();
}

class SlotPickerLoaded extends SlotPickerState {
  const SlotPickerLoaded({
    required this.slots,
    this.pricePerHour,
    this.photos = const [],
    this.groupSlots = const [],
    this.address,
    this.courtName,
  });

  final List<Slot> slots;
  final double? pricePerHour;
  final List<String> photos;
  final List<Slot> groupSlots;
  final String? address;
  final String? courtName;
}

class SlotPickerError extends SlotPickerState {
  const SlotPickerError(this.message);

  final String message;
}
