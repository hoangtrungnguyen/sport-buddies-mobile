part of 'booking_cubit.dart';

sealed class BookingState {
  const BookingState();
}

final class BookingInitial extends BookingState {
  const BookingInitial();
}

final class BookingLoading extends BookingState {
  const BookingLoading();
}

final class BookingLoaded extends BookingState {
  const BookingLoaded({
    required this.slot,
    required this.pricePerHour,
    required this.name,
    required this.phone,
  });

  final Slot slot;
  final double? pricePerHour;
  final String name;
  final String phone;
}

final class BookingSubmitting extends BookingState {
  const BookingSubmitting();
}

final class BookingSubmitted extends BookingState {
  const BookingSubmitted({required this.bookingId});
  final String bookingId;
}

final class BookingSlotTaken extends BookingState {
  const BookingSlotTaken();
}

final class BookingError extends BookingState with AppExceptionMixin {
  const BookingError(this.message, {this.stackTrace});

  @override
  final String message;
  @override
  final StackTrace? stackTrace;
}
