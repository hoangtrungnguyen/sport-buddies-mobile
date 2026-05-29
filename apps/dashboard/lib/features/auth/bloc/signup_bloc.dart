// SignupBloc for the Owner Dashboard.
//
// State machine:
//   initial → SignupSubmitted (invalid input)  → rejected(validation_msg)
//   initial → SignupSubmitted (valid)           → submitting → success
//                                                            → rejected(api_code)
//
// Kept separate from [AuthBloc]: AuthBloc owns the global session/redirect
// state, whereas signup is a one-shot form flow that hands off to login on
// success. On `201` the API returns no session, so this bloc never emits an
// "authenticated" state.

import 'package:dashboard/features/auth/auth_validators.dart';
import 'package:dashboard/features/auth/bloc/signup_event.dart';
import 'package:dashboard/features/auth/bloc/signup_state.dart';
import 'package:dashboard/features/auth/repository/owner_auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

export 'signup_event.dart';
export 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  SignupBloc(this._repository) : super(const SignupInitial()) {
    on<SignupSubmitted>(_onSubmitted);
  }

  final OwnerAuthRepository _repository;

  Future<void> _onSubmitted(
    SignupSubmitted event,
    Emitter<SignupState> emit,
  ) async {
    final emailErr = validateEmail(event.email);
    if (emailErr != null) {
      emit(SignupRejected(emailErr));
      return;
    }
    final passErr = validateSignupPassword(event.password);
    if (passErr != null) {
      emit(SignupRejected(passErr));
      return;
    }
    final confirmErr =
        validateConfirmPassword(event.password, event.confirmPassword);
    if (confirmErr != null) {
      emit(SignupRejected(confirmErr));
      return;
    }

    emit(const SignupSubmitting());
    try {
      final result = await _repository.signup(
        email: event.email.trim(),
        password: event.password,
      );
      emit(SignupSuccess(
        email: result.email,
        requiresVerification: result.requiresVerification,
      ));
    } on OwnerSignupException catch (e, st) {
      emit(SignupRejected(e.code, stackTrace: st));
    }
  }
}
