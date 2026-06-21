// Web UI e2e: the owner login flow, driven in a real Chrome browser via
// integration_test + patrol_finders (the `$` API).
//
// Self-contained — a fake [OwnerAuthRepository] stands in for the backend and
// the AuthBloc runs with a null SupabaseClient (session hydration no-ops), so
// no network / Supabase is needed. This exercises the real LoginScreen +
// LoginFormPanel + AuthBloc wiring as the browser renders them.
//
// Run (needs chromedriver on :4444 — see scripts/web_e2e.sh):
//   flutter drive \
//     --driver=test_driver/integration_test.dart \
//     --target=integration_test/login_test.dart \
//     -d chrome
import 'package:dashboard/features/auth/bloc/auth_bloc.dart';
import 'package:dashboard/features/auth/repository/owner_auth_repository.dart';
import 'package:dashboard/features/auth/view/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:patrol_finders/patrol_finders.dart';

/// The one password the fake accepts; anything else is rejected like a real
/// `401 invalid_credentials`.
const _goodPassword = 'correct-password';

/// Fake auth repo — only [login] is real; the rest routes through noSuchMethod.
class _FakeAuthRepo implements OwnerAuthRepository {
  @override
  Future<OwnerLoginResult> login({
    required String email,
    required String password,
  }) async {
    if (password == _goodPassword) {
      return OwnerLoginResult(
        accessToken: 'access',
        refreshToken: 'refresh',
        userId: 'u1',
        email: email,
      );
    }
    throw const OwnerLoginException('invalid_credentials', statusCode: 401);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Future<void> _pump(PatrolTester $, _FakeAuthRepo repo) async {
  final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) =>
            const Scaffold(body: Center(child: Text('HOME'))),
      ),
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
    ],
  );

  await $.pumpWidget(
    BlocProvider<AuthBloc>(
      // Null SupabaseClient → hydrateSession() no-ops; the bloc still emits
      // AuthAuthenticated on a successful repo login.
      create: (_) => AuthBloc(ownerAuthRepository: repo),
      child: MaterialApp.router(routerConfig: router),
    ),
  );
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  patrolWidgetTest('login with valid credentials navigates to home', ($) async {
    await _pump($, _FakeAuthRepo());

    // Starts on the login screen (title + button both read "Đăng nhập").
    expect($('Đăng nhập'), findsWidgets);
    expect($('HOME'), findsNothing);
    await binding.takeScreenshot('01-login-screen');

    await $(TextFormField).at(0).enterText('owner@snb.com');
    await $(TextFormField).at(1).enterText(_goodPassword);
    await $(ElevatedButton).tap();
    await $.tester.pumpAndSettle();

    // AuthAuthenticated → context.go('/').
    expect($('HOME'), findsOneWidget);
    await binding.takeScreenshot('02-login-success-home');
  });

  patrolWidgetTest('wrong password shows the inline credentials error',
      ($) async {
    await _pump($, _FakeAuthRepo());

    await $(TextFormField).at(0).enterText('owner@snb.com');
    await $(TextFormField).at(1).enterText('wrong-password');
    await $(ElevatedButton).tap();
    await $.tester.pumpAndSettle();

    // AuthRejected('invalid_credentials') → mapped error, still on login.
    expect($('Email hoặc mật khẩu không đúng.'), findsOneWidget);
    expect($('HOME'), findsNothing);
    await binding.takeScreenshot('03-login-error');
  });

  patrolWidgetTest('empty email is blocked by form validation', ($) async {
    await _pump($, _FakeAuthRepo());

    // Submit with nothing filled — the form validator stops it before any
    // bloc event fires.
    await $(ElevatedButton).tap();
    await $.tester.pumpAndSettle();

    expect($('Vui lòng nhập email.'), findsOneWidget);
    expect($('HOME'), findsNothing);
  });
}
