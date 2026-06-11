import 'package:customer/features/booking/wizard/domain/booking.dart';
import 'package:customer/features/court/domain/booking_draft.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking_wizard_state.freezed.dart';

/// One-shot effects the page reacts to then clears (snackbar + navigation).
enum WizardEffect { none, raceLost, networkFailed }

/// The wizard is a single evolving record, not a set of discrete states
/// (handoff doc 03 §2) — so this is a freezed data class, not a sealed union.
@freezed
abstract class BookingWizardState with _$BookingWizardState {
  const factory BookingWizardState({
    required BookingDraft draft,
    required ContactInfo contact,
    @Default(0) int currentStep, // 0 Confirm · 1 Play · 2 Awaiting · 3 Done
    @Default(AccessPolicy.private) AccessPolicy access,
    @Default(4) int maxPlayers,
    Booking? booking, // null until createBooking succeeds
    @Default(false) bool submitting, // RPC in flight
    @Default(false) bool declined, // owner declined on Step 3
    @Default(WizardEffect.none) WizardEffect effect,
  }) = _BookingWizardState;

  const BookingWizardState._();

  int get slotCount => draft.slots.length;
  int get totalVnd => draft.totalVnd;
  Duration get totalDuration => draft.totalDuration;
}
