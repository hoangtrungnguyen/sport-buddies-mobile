// AuthBloc for the Owner Dashboard.
//
// State machine:
//   initial → (AppStarted, has session + role=owner) → authenticated
//   initial → (AppStarted, no session)               → unauthenticated
//   initial → (AppStarted, has session, not owner)   → rejected('not_owner')
//   unauthenticated → LoginSubmitted → loading → authenticated | rejected
//   authenticated   → LogoutRequested → unauthenticated

import 'dart:async';

import 'package:dashboard/features/auth/bloc/auth_event.dart';
import 'package:dashboard/features/auth/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

export 'auth_event.dart';
export 'auth_state.dart';

String? validateEmail(String? email) {
  if (email == null || email.trim().isEmpty) return 'Vui lòng nhập email.';
  final re = RegExp(r'^[^@]+@[^@]+\.[^@]+');
  if (!re.hasMatch(email.trim())) return 'Email không hợp lệ.';
  return null;
}

String? validatePassword(String? password) {
  if (password == null || password.isEmpty) return 'Vui lòng nhập mật khẩu.';
  return null;
}

bool _isOwner(User user) {
  final role = user.appMetadata['role'] as String? ??
      user.userMetadata?['role'] as String? ??
      '';
  return role == 'owner';
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({SupabaseClient? supabaseClient})
      : _client = supabaseClient,
        super(const AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<AuthStateChanged>(_onAuthStateChanged);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<LogoutRequested>(_onLogoutRequested);

    final authStream = _client?.auth.onAuthStateChange;
    if (authStream != null) {
      _sub = authStream.listen(
        (s) => add(AuthEvent.authStateChanged(s.session)),
      );
    }
  }

  final SupabaseClient? _client;
  // ignore: cancel_subscriptions
  StreamSubscription<dynamic>? _sub;

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }

  void _onAppStarted(AppStarted event, Emitter<AuthState> emit) {
    final session = _client?.auth.currentSession;
    if (session == null) {
      emit(const AuthUnauthenticated());
      return;
    }
    final user = session.user;
    if (!_isOwner(user)) {
      emit(const AuthRejected('not_owner'));
      return;
    }
    emit(const AuthAuthenticated());
  }

  void _onAuthStateChanged(AuthStateChanged event, Emitter<AuthState> emit) {
    final session = event.session;
    if (session == null) {
      emit(const AuthUnauthenticated());
    } else {
      // Already validated role on login; just trust the session here.
      emit(const AuthAuthenticated());
    }
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    final emailErr = validateEmail(event.email);
    if (emailErr != null) {
      emit(AuthRejected(emailErr));
      return;
    }
    final passErr = validatePassword(event.password);
    if (passErr != null) {
      emit(AuthRejected(passErr));
      return;
    }

    emit(const AuthLoading());
    try {
      final client = _client;
      if (client != null) {
        final res = await client.auth.signInWithPassword(
          email: event.email.trim(),
          password: event.password,
        );
        final user = res.user;
        if (user != null && !_isOwner(user)) {
          await client.auth.signOut();
          emit(const AuthRejected('not_owner'));
          return;
        }
      }
      emit(const AuthAuthenticated());
    } on AuthException catch (e, st) {
      final msg = e.message.toLowerCase();
      if (msg.contains('invalid login') ||
          e.statusCode == '400' ||
          e.statusCode == '401') {
        emit(AuthRejected('invalid_credentials', stackTrace: st));
      } else {
        emit(AuthRejected(e.message, stackTrace: st));
      }
    }
  }

  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    final emailErr = validateEmail(event.email);
    if (emailErr != null) {
      emit(AuthRejected(emailErr));
      return;
    }
    emit(const AuthLoading());
    try {
      await _client?.auth.resetPasswordForEmail(event.email.trim());
      emit(const PasswordResetSent());
    } on AuthException catch (e, st) {
      emit(AuthRejected(e.message, stackTrace: st));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _client?.auth.signOut();
    emit(const AuthUnauthenticated());
  }
}
