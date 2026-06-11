import 'dart:async';

import 'package:customer/features/booking/wizard/cubit/booking_wizard_state.dart';
import 'package:customer/features/booking/wizard/data/booking_repository.dart';
import 'package:customer/features/booking/wizard/domain/booking.dart';
import 'package:customer/features/court/domain/booking_draft.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

export 'package:customer/features/booking/wizard/cubit/booking_wizard_state.dart';

/// Drives the 4-step booking wizard state machine (handoff doc 03).
///
/// Owns `currentStep`, the editable contact, the access choice, the RPC call,
/// and the Step-3 realtime subscription. Step 3 → Step 4 is driven by the
/// realtime `confirmed` event, never a button.
class BookingWizardCubit extends Cubit<BookingWizardState> {
  BookingWizardCubit({
    required BookingRepository repository,
    required BookingDraft draft,
    required ContactInfo initialContact,
  })  : _repository = repository,
        super(BookingWizardState(draft: draft, contact: initialContact));

  final BookingRepository _repository;
  StreamSubscription<Booking>? _watch;

  // ── Step 1 · Confirm ──────────────────────────────────────────────────
  void updateContact(ContactInfo contact) => emit(state.copyWith(contact: contact));

  /// T1 — pure advance to Play-together, no network (doc 03 §3 T1).
  void confirm() => emit(state.copyWith(currentStep: 1));

  // ── Step 2 · Play-together ────────────────────────────────────────────
  void selectAccess(AccessPolicy access) => emit(state.copyWith(access: access));

  void setMaxPlayers(int value) {
    final clamped = value.clamp(2, 20);
    emit(state.copyWith(maxPlayers: clamped));
  }

  /// T2 — the only write in the wizard (SPB-043). On success advances to
  /// Step 3 and starts watching; on race loss / failure emits a one-shot
  /// effect for the page to handle (doc 03 §3.2–§3.5).
  ///
  /// [skip] = the app-bar "Bỏ qua" → submit as private.
  Future<void> submit({bool skip = false}) async {
    if (state.submitting) return;
    final access = skip ? AccessPolicy.private : state.access;
    emit(state.copyWith(submitting: true, effect: WizardEffect.none));

    try {
      final booking = await _repository.createBooking(
        draft: state.draft,
        contact: state.contact,
        access: access,
        maxPlayers: state.maxPlayers,
      );
      emit(state.copyWith(
        submitting: false,
        access: access,
        booking: booking,
        currentStep: 2,
      ));
      _startWatching(booking);
    } on SlotTakenException {
      emit(state.copyWith(submitting: false, effect: WizardEffect.raceLost));
    } on BookingFailedException {
      emit(state.copyWith(submitting: false, effect: WizardEffect.networkFailed));
    }
  }

  // ── Step 3 · Awaiting (realtime auto-advance) ─────────────────────────
  void _startWatching(Booking booking) {
    _watch?.cancel();
    _watch = _repository.watchBooking(booking).listen((b) {
      if (b.status == BookingStatus.confirmed) {
        emit(state.copyWith(booking: b, currentStep: 3));
      } else if (b.status.isTerminalNegative) {
        emit(state.copyWith(booking: b, declined: true));
      }
    });
  }

  /// Per-step back (doc 03 §5). Returns true if handled internally (Step 2 →
  /// Step 1); false means the page should pop the route.
  bool back() {
    if (state.currentStep == 1) {
      emit(state.copyWith(currentStep: 0));
      return true;
    }
    return false;
  }

  /// Consume a one-shot effect after the page has reacted to it.
  void clearEffect() => emit(state.copyWith(effect: WizardEffect.none));

  @override
  Future<void> close() {
    _watch?.cancel();
    return super.close();
  }
}
