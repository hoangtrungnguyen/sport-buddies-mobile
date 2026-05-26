// Tests for the GoRouter configuration (grava-144f.1.2/1.4 auth redirect +
// grava-654b.1.1 bookings).
//
// Redirect behaviour:
//   unauthenticated + any protected route → /login
//   authenticated   + /login or /signup   → /
//
// The router exposes seven routes:
//   /                    → HomePage (protected)
//   /login               → LoginScreen (public)
//   /signup              → SignUpScreen (public)
//   /forgot-password     → ForgotPasswordScreen (public)
//   /profile             → ProfileScreen (protected, later story)
//   /map                 → MapScreen (protected, later story)
//   /bookings/upcoming   → UpcomingBookingsPage (grava-654b.1.1)
//
// Note: in unit tests Supabase is not initialised, so
// `Supabase.instance.client.auth.currentSession` returns null — all widget
// tests run in the unauthenticated code-path unless Supabase is mocked.
import 'package:customer/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('AppRouter — buildRouter()', () {
    test('returns a GoRouter instance', () {
      final router = buildRouter();
      expect(router, isA<GoRouter>());
    });

    test(
        'GoRouter contains routes for "/", "/login", "/signup", "/forgot-password", "/profile", "/map", and "/bookings/upcoming"',
        () {
      final router = buildRouter();
      final routes = router.configuration.routes;
      final paths =
          routes.whereType<GoRoute>().map((r) => r.path).toList();
      expect(
        paths,
        containsAll([
          '/',
          '/login',
          '/signup',
          '/forgot-password',
          '/profile',
          '/map',
          '/bookings/upcoming',
        ]),
      );
    });

    // Without a Supabase session (tests run unauthenticated), the redirect
    // sends the user to /login. This exercises the auth guard (grava-144f.1.4).
    testWidgets(
        'unauthenticated: / redirects to /login (shows "Sign in")',
        (WidgetTester tester) async {
      final router = buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();
      // The redirect lands on /login which contains "Sign in".
      expect(find.text('Sign in'), findsWidgets);
    });

    testWidgets('/login resolves to a widget that shows "Sign in"',
        (WidgetTester tester) async {
      final router = buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      router.go('/login');
      await tester.pumpAndSettle();
      // "Sign in" appears in both the AppBar title and the submit button.
      expect(find.text('Sign in'), findsWidgets);
    });

    testWidgets('/signup resolves to a widget that shows "Create account"',
        (WidgetTester tester) async {
      final router = buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      router.go('/signup');
      await tester.pumpAndSettle();
      // "Create account" appears in both the AppBar title and the submit button.
      expect(find.text('Create account'), findsWidgets);
    });
  });

  group('HomePage widget', () {
    testWidgets('renders "SportBuddies — bootstrap OK"',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: HomePage()),
      );
      expect(find.text('SportBuddies — bootstrap OK'), findsOneWidget);
    });
  });
}
