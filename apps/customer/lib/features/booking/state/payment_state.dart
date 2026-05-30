import 'package:customer/core/mixins/app_exception_mixin.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_state.freezed.dart';

@freezed
sealed class PaymentState with _$PaymentState {
  const factory PaymentState.loading() = PaymentLoading;

  const factory PaymentState.loaded({
    required String bookingId,
    required String courtName,
    required DateTime slotStart,
    required DateTime slotEnd,
    required double totalPrice,
  }) = PaymentLoaded;

  @With<AppExceptionMixin>()
  const factory PaymentState.error(String message, {StackTrace? stackTrace}) =
      PaymentError;
}
